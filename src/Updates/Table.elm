module Updates.Table exposing (hideAllTables, hideColumn, hideTable, showAllTables, showColumn, showTable)

import Dict
import Libs.List as L
import Libs.Maybe as M
import Models exposing (Msg)
import Models.Schema exposing (ColumnName, Layout, Schema, TableId, initTableProps, showTableId)
import Ports exposing (activateTooltipsAndPopovers, observeTableSize, observeTablesSize, toastError, toastInfo)
import Updates.Helpers exposing (setLayout)



-- deps = { to = { except = [ "Main", "Update", "Updates.*", "View", "Views.*" ] } }


hideTable : TableId -> Layout -> Layout
hideTable id layout =
    { layout
        | tables = layout.tables |> Dict.update id (\_ -> Nothing)
        , hiddenTables = layout.hiddenTables |> Dict.update id (\_ -> layout.tables |> Dict.get id)
    }


showTable : TableId -> Schema -> ( Schema, Cmd Msg )
showTable id schema =
    case schema.tables |> Dict.get id of
        Just table ->
            if schema.layout.tables |> Dict.member id then
                ( schema, toastInfo ("Table <b>" ++ showTableId id ++ "</b> already shown") )

            else
                ( schema |> setLayout (\l -> { l | tables = l.tables |> Dict.update id (\_ -> Just (l.hiddenTables |> Dict.get id |> Maybe.withDefault (initTableProps table))) })
                , Cmd.batch [ observeTableSize id, activateTooltipsAndPopovers ]
                )

        Nothing ->
            ( schema, toastError ("Can't show table <b>" ++ showTableId id ++ "</b>: not found") )


hideColumn : TableId -> ColumnName -> Layout -> Layout
hideColumn table column layout =
    { layout | tables = layout.tables |> Dict.update table (Maybe.map (\t -> { t | columns = t.columns |> List.filter (\c -> not (c == column)) })) }


showColumn : TableId -> ColumnName -> Int -> Layout -> Layout
showColumn table column index layout =
    { layout | tables = layout.tables |> Dict.update table (Maybe.map (\t -> { t | columns = t.columns |> L.addAt column index })) }


hideAllTables : Layout -> Layout
hideAllTables layout =
    { layout
        | tables = Dict.empty
        , hiddenTables = Dict.union layout.tables layout.hiddenTables
    }


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
