module PagesComponents.App.Updates.Table exposing (hideAllTables, hideColumn, hideColumns, hideTable, showAllTables, showColumn, showColumns, showTable, showTables, sortColumns)

import Dict
import Libs.Bool exposing (cond)
import Libs.List as L
import Libs.Maybe as M
import Libs.Ned as Ned
import Libs.Nel as Nel
import Models.Schema exposing (ColumnName, Layout, Schema, Table, TableId, extractColumnIndex, extractColumnType, inIndexes, inPrimaryKey, inUniques, initTableProps, showTableId, withNullableInfo)
import PagesComponents.App.Models exposing (Msg)
import PagesComponents.App.Updates.Helpers exposing (setLayout)
import Ports exposing (activateTooltipsAndPopovers, observeTableSize, observeTablesSize, toastError, toastInfo)


showTable : TableId -> Schema -> ( Schema, Cmd Msg )
showTable id schema =
    case schema.tables |> Dict.get id of
        Just table ->
            if schema.layout.tables |> Dict.member id then
                ( schema, toastInfo ("Table <b>" ++ showTableId id ++ "</b> already shown") )

            else
                ( schema |> performShowTable id table, Cmd.batch [ observeTableSize id, activateTooltipsAndPopovers ] )

        Nothing ->
            ( schema, toastError ("Can't show table <b>" ++ showTableId id ++ "</b>: not found") )


showTables : List TableId -> Schema -> ( Schema, Cmd Msg )
showTables ids schema =
    ids
        |> L.zipWith (\id -> schema.tables |> Dict.get id)
        |> List.foldr
            (\( id, maybeTable ) ( s, ( found, shown, notFound ) ) ->
                case maybeTable of
                    Just table ->
                        if schema.layout.tables |> Dict.member id then
                            ( s, ( found, id :: shown, notFound ) )

                        else
                            ( s |> performShowTable id table, ( id :: found, shown, notFound ) )

                    Nothing ->
                        ( s, ( found, shown, id :: notFound ) )
            )
            ( schema, ( [], [], [] ) )
        |> (\( s, ( found, shown, notFound ) ) ->
                ( s
                , Cmd.batch
                    (cond (found |> List.isEmpty) [] [ observeTablesSize found, activateTooltipsAndPopovers ]
                        ++ cond (shown |> List.isEmpty) [] [ toastInfo ("Tables " ++ (shown |> List.map showTableId |> String.join ", ") ++ " are ealready shown") ]
                        ++ cond (notFound |> List.isEmpty) [] [ toastInfo ("Can't show tables " ++ (notFound |> List.map showTableId |> String.join ", ") ++ ": can't found them") ]
                    )
                )
           )


showAllTables : Schema -> ( Schema, Cmd Msg )
showAllTables schema =
    ( schema
        |> setLayout
            (\l ->
                { l
                    | tables = schema.tables |> Dict.map (\id t -> l.tables |> Dict.get id |> M.orElse (l.hiddenTables |> Dict.get id) |> Maybe.withDefault (initTableProps t))
                    , hiddenTables = Dict.empty
                }
            )
    , Cmd.batch [ observeTablesSize (schema.tables |> Dict.keys |> List.filter (\id -> not (schema.layout.tables |> Dict.member id))), activateTooltipsAndPopovers ]
    )


hideTable : TableId -> Layout -> Layout
hideTable id layout =
    { layout
        | tables = layout.tables |> Dict.update id (\_ -> Nothing)
        , hiddenTables = layout.hiddenTables |> Dict.update id (\_ -> layout.tables |> Dict.get id)
    }


hideAllTables : Layout -> Layout
hideAllTables layout =
    { layout
        | tables = Dict.empty
        , hiddenTables = Dict.union layout.tables layout.hiddenTables
    }


showColumn : TableId -> ColumnName -> Layout -> Layout
showColumn table column layout =
    { layout | tables = layout.tables |> Dict.update table (Maybe.map (\t -> { t | columns = t.columns |> L.addAt column (t.columns |> List.length) })) }


hideColumn : TableId -> ColumnName -> Layout -> Layout
hideColumn table column layout =
    { layout | tables = layout.tables |> Dict.update table (Maybe.map (\t -> { t | columns = t.columns |> List.filter (\c -> not (c == column)) })) }


sortColumns : TableId -> String -> Schema -> Schema
sortColumns id kind schema =
    updateColumns id
        (\table columns ->
            columns
                |> L.zipWith (\name -> table.columns |> Ned.get name)
                |> List.sortBy
                    (\( name, col ) ->
                        case ( kind, col ) of
                            ( "property", Just c ) ->
                                if name |> inPrimaryKey table |> M.isJust then
                                    ( 0 + sortOffset c.nullable, name )

                                else if c.foreignKey |> M.isJust then
                                    ( 1 + sortOffset c.nullable, name )

                                else if name |> inUniques table |> L.nonEmpty then
                                    ( 2 + sortOffset c.nullable, name )

                                else if name |> inIndexes table |> L.nonEmpty then
                                    ( 3 + sortOffset c.nullable, name )

                                else
                                    ( 4 + sortOffset c.nullable, name )

                            ( "name", Just _ ) ->
                                ( 0, name )

                            ( "sql", Just c ) ->
                                ( toFloat (extractColumnIndex c.index), "" )

                            ( "type", Just c ) ->
                                ( 0, extractColumnType c.kind |> withNullableInfo c.nullable )

                            _ ->
                                ( toFloat (table.columns |> Ned.size), name )
                    )
                |> List.map Tuple.first
        )
        schema


sortOffset : Bool -> Float
sortOffset b =
    if b then
        0.5

    else
        0


hideColumns : TableId -> String -> Schema -> Schema
hideColumns id kind schema =
    updateColumns id
        (\table columns ->
            columns
                |> L.zipWith (\name -> table.columns |> Ned.get name)
                |> List.filter
                    (\( name, col ) ->
                        case ( kind, col ) of
                            ( "regular", Just c ) ->
                                (name |> inPrimaryKey table |> M.isJust)
                                    || (c.foreignKey |> M.isJust)
                                    || (name |> inUniques table |> L.nonEmpty)
                                    || (name |> inIndexes table |> L.nonEmpty)

                            ( "nullable", Just c ) ->
                                not c.nullable

                            ( "all", _ ) ->
                                False

                            _ ->
                                False
                    )
                |> List.map Tuple.first
        )
        schema


showColumns : TableId -> String -> Schema -> Schema
showColumns id kind schema =
    updateColumns id
        (\table columns ->
            columns
                ++ (table.columns
                        |> Ned.values
                        |> Nel.filter (\c -> not (columns |> List.member c.name))
                        |> List.filter
                            (\_ ->
                                case kind of
                                    "all" ->
                                        True

                                    _ ->
                                        False
                            )
                        |> List.map .name
                   )
        )
        schema


updateColumns : TableId -> (Table -> List ColumnName -> List ColumnName) -> Schema -> Schema
updateColumns id update schema =
    schema.tables
        |> Dict.get id
        |> Maybe.map (\table -> schema |> setLayout (\l -> { l | tables = l.tables |> Dict.update id (Maybe.map (\t -> { t | columns = t.columns |> update table })) }))
        |> Maybe.withDefault schema


performShowTable : TableId -> Table -> Schema -> Schema
performShowTable id table schema =
    schema |> setLayout (\l -> { l | tables = l.tables |> Dict.update id (\_ -> Just (l.hiddenTables |> Dict.get id |> Maybe.withDefault (initTableProps table))) })
