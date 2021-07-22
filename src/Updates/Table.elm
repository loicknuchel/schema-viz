module Updates.Table exposing (hideAllTables, hideColumn, hideTable, showAllTables, showColumn, showTable, showTables, sortColumns)

import Dict
import Libs.Bool exposing (cond)
import Libs.List as L
import Libs.Maybe as M
import Libs.Ned as Ned
import Models exposing (Msg)
import Models.Schema exposing (ColumnName, Layout, Schema, Table, TableId, extractColumnIndex, inIndexes, inPrimaryKey, inUniques, initTableProps, showTableId)
import Ports exposing (activateTooltipsAndPopovers, observeTableSize, observeTablesSize, toastError, toastInfo)
import Updates.Helpers exposing (setLayout)
import Views.Helpers exposing (extractColumnType)



-- deps = { to = { except = [ "Main", "Update", "Updates.*", "View", "Views.*" ] } }


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


showColumn : TableId -> ColumnName -> Int -> Layout -> Layout
showColumn table column index layout =
    { layout | tables = layout.tables |> Dict.update table (Maybe.map (\t -> { t | columns = t.columns |> L.addAt column index })) }


hideColumn : TableId -> ColumnName -> Layout -> Layout
hideColumn table column layout =
    { layout | tables = layout.tables |> Dict.update table (Maybe.map (\t -> { t | columns = t.columns |> List.filter (\c -> not (c == column)) })) }


sortColumns : TableId -> String -> Schema -> Schema
sortColumns id kind schema =
    schema.tables
        |> Dict.get id
        |> Maybe.map (\table -> schema |> setLayout (\l -> { l | tables = l.tables |> Dict.update id (Maybe.map (\t -> { t | columns = t.columns |> sortBy kind table })) }))
        |> Maybe.withDefault schema


sortBy : String -> Table -> List ColumnName -> List ColumnName
sortBy kind table columns =
    columns
        |> L.zipWith (\name -> table.columns |> Ned.get name)
        |> List.sortBy
            (\( name, col ) ->
                case ( kind, col ) of
                    ( "sql", Just c ) ->
                        ( extractColumnIndex c.index, "" )

                    ( "name", Just _ ) ->
                        ( 0, name )

                    ( "type", Just c ) ->
                        ( 0, extractColumnType c.kind )

                    ( "property", Just c ) ->
                        if name |> inPrimaryKey table |> M.isJust then
                            ( 0, name )

                        else if c.foreignKey |> M.isJust then
                            ( 1, name )

                        else if name |> inUniques table |> L.nonEmpty then
                            ( 2, name )

                        else if name |> inIndexes table |> L.nonEmpty then
                            ( 3, name )

                        else
                            ( 4, name )

                    _ ->
                        ( table.columns |> Ned.size, name )
            )
        |> List.map Tuple.first


performShowTable : TableId -> Table -> Schema -> Schema
performShowTable id table schema =
    schema |> setLayout (\l -> { l | tables = l.tables |> Dict.update id (\_ -> Just (l.hiddenTables |> Dict.get id |> Maybe.withDefault (initTableProps table))) })
