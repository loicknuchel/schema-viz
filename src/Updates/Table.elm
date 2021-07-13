module Updates.Table exposing (hideAllTables, hideColumn, hideTable, showAllTables, showColumn, showTable)

import AssocList as Dict exposing (Dict)
import Libs.Dict as D
import Models exposing (Msg)
import Models.Schema exposing (Column, ColumnName, Schema, Table, TableId, TableStatus(..), formatTableId)
import Ports exposing (activateTooltipsAndPopovers, observeTableSize, observeTablesSize, toastError, toastInfo)
import Updates.Helpers exposing (setState, updateTable, updateTables)



-- deps = { to = { except = [ "Main", "Update", "Updates.*", "View", "Views.*" ] } }


hideTable : TableId -> Schema -> Schema
hideTable id schema =
    schema |> updateTable id (setState (\state -> { state | status = Hidden }))


showTable : TableId -> Schema -> ( Schema, Cmd Msg )
showTable id schema =
    case schema.tables |> Dict.get id |> Maybe.map (\t -> t.state.status) of
        Just Uninitialized ->
            -- race condition problem when observe is performed before table is shown :(
            ( schema |> updateTable id (setState (\state -> { state | status = Initializing })), Cmd.batch [ observeTableSize id, activateTooltipsAndPopovers ] )

        Just Initializing ->
            ( schema, Cmd.none )

        Just Hidden ->
            ( schema |> updateTable id (setState (\state -> { state | status = Shown, selected = False })), Cmd.batch [ observeTableSize id, activateTooltipsAndPopovers ] )

        Just Shown ->
            ( schema, toastInfo ("Table <b>" ++ formatTableId id ++ "</b> is already shown") )

        Nothing ->
            ( schema, toastError ("Can't show table <b>" ++ formatTableId id ++ "</b>: not found") )


hideColumn : ColumnName -> Dict ColumnName Column -> Dict ColumnName Column
hideColumn columnName columns =
    columns
        |> Dict.update columnName (Maybe.map (setState (\state -> { state | order = Nothing })))
        |> setSequentialOrder


showColumn : ColumnName -> Int -> Dict ColumnName Column -> Dict ColumnName Column
showColumn columnName index columns =
    columns
        |> Dict.map
            (\_ column ->
                case column.state.order of
                    Just order ->
                        if order < index then
                            column

                        else
                            column |> setState (\state -> { state | order = Just (order + 1) })

                    Nothing ->
                        if column.column == columnName then
                            column |> setState (\state -> { state | order = Just index })

                        else
                            column
            )


setSequentialOrder : Dict ColumnName Column -> Dict ColumnName Column
setSequentialOrder columns =
    columns
        |> Dict.values
        |> List.sortBy (\c -> c.state.order |> Maybe.withDefault (Dict.size columns))
        |> List.indexedMap
            (\index column ->
                if column.state.order == Nothing then
                    column

                else
                    column |> setState (\state -> { state | order = Just index })
            )
        |> D.fromList .column


hideAllTables : Schema -> Schema
hideAllTables schema =
    schema
        |> updateTables
            (setState
                (\state ->
                    if state.status == Shown then
                        { state | status = Hidden }

                    else
                        state
                )
            )


showAllTables : Schema -> ( Schema, Cmd Msg )
showAllTables schema =
    let
        ( cmds, tables ) =
            schema.tables |> Dict.values |> List.map showTableByState |> List.unzip
    in
    ( { schema | tables = tables |> D.fromList .id }, Cmd.batch [ observeTablesSize (cmds |> List.filterMap identity), activateTooltipsAndPopovers ] )


showTableByState : Table -> ( Maybe TableId, Table )
showTableByState table =
    case table.state.status of
        Uninitialized ->
            ( Just table.id, table |> setState (\state -> { state | status = Initializing }) )

        Initializing ->
            ( Nothing, table )

        Hidden ->
            ( Just table.id, table |> setState (\state -> { state | status = Shown, selected = False }) )

        Shown ->
            ( Nothing, table )
