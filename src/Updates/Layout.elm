module Updates.Layout exposing (createLayout, deleteLayout, loadLayout, updateLayout)

import AssocList as Dict
import Libs.Bool as B
import Libs.Dict as D
import Libs.List as L
import Models exposing (Msg)
import Models.Schema exposing (Column, ColumnName, ColumnProps, Layout, LayoutName, Schema, Table, TableId, TableProps, TableStatus(..))
import Ports exposing (activateTooltipsAndPopovers, observeTablesSize, saveSchema)
import Updates.Helpers exposing (map, setColumns, setLayouts, setState, setTables)



-- deps = { to = { except = [ "Main", "Update", "Updates.*", "View", "Views.*" ] } }


createLayout : LayoutName -> Schema -> ( Schema, Cmd Msg )
createLayout name schema =
    schema
        |> setState (\st -> { st | currentLayout = Just name })
        |> setLayouts (\l -> toLayout name schema :: l)
        |> map (\newSchema -> ( newSchema, Cmd.batch [ saveSchema newSchema, activateTooltipsAndPopovers ] ))


loadLayout : LayoutName -> Schema -> ( Schema, Cmd Msg )
loadLayout name schema =
    schema.layouts
        |> L.find (\layout -> layout.name == name)
        |> Maybe.map
            (\layout ->
                schema.tables
                    |> Dict.values
                    |> List.map (\table -> showTableWithLayout (layout.tables |> Dict.get table.id) table)
                    |> List.unzip
                    |> map
                        (\( cmds, tables ) ->
                            ( schema
                                |> setTables (\_ -> tables |> D.fromList .id)
                                |> setState (\st -> { st | currentLayout = Just layout.name, zoom = layout.canvas.zoom, position = layout.canvas.position })
                            , Cmd.batch [ observeTablesSize (cmds |> List.filterMap identity), activateTooltipsAndPopovers ]
                            )
                        )
            )
        |> Maybe.withDefault ( schema, Cmd.none )


updateLayout : LayoutName -> Schema -> ( Schema, Cmd Msg )
updateLayout name schema =
    schema
        |> setState (\st -> { st | currentLayout = Just name })
        |> setLayouts (List.map (\l -> B.lazyCond (l.name == name) (\_ -> schema |> toLayout name) (\_ -> l)))
        |> map (\newSchema -> ( newSchema, saveSchema newSchema ))


deleteLayout : LayoutName -> Schema -> ( Schema, Cmd Msg )
deleteLayout name schema =
    schema
        |> setState (\st -> B.cond (st.currentLayout == Just name) { st | currentLayout = Nothing } st)
        |> setLayouts (List.filter (\l -> not (l.name == name)))
        |> map (\newSchema -> ( newSchema, saveSchema newSchema ))


toLayout : LayoutName -> Schema -> Layout
toLayout name schema =
    { name = name
    , canvas = { zoom = schema.state.zoom, position = schema.state.position }
    , tables = schema.tables |> Dict.values |> List.filter (\t -> t.state.status == Shown) |> List.map tableToLayout |> Dict.fromList
    }


tableToLayout : Table -> ( TableId, TableProps )
tableToLayout table =
    ( table.id
    , { position = table.state.position
      , color = table.state.color
      , columns = table.columns |> Dict.values |> List.filterMap columnToLayout |> Dict.fromList
      }
    )


columnToLayout : Column -> Maybe ( ColumnName, ColumnProps )
columnToLayout column =
    Maybe.map (\order -> ( column.column, { position = order } )) column.state.order


showTableWithLayout : Maybe TableProps -> Table -> ( Maybe TableId, Table )
showTableWithLayout maybeProps table =
    case ( table.state.status, maybeProps ) of
        ( Uninitialized, Just props ) ->
            ( Just table.id, table |> setState (\s -> { s | status = Initializing }) |> setTableLayout props )

        ( Uninitialized, Nothing ) ->
            ( Nothing, table )

        ( Initializing, Just props ) ->
            ( Nothing, table |> setTableLayout props )

        ( Initializing, Nothing ) ->
            ( Nothing, table |> setState (\s -> { s | status = Uninitialized }) )

        ( Hidden, Just props ) ->
            ( Just table.id, table |> setState (\s -> { s | status = Shown, selected = False }) |> setTableLayout props )

        ( Hidden, Nothing ) ->
            ( Nothing, table )

        ( Shown, Just props ) ->
            ( Nothing, table |> setTableLayout props )

        ( Shown, Nothing ) ->
            ( Nothing, table |> setState (\s -> { s | status = Hidden }) )


setTableLayout : TableProps -> Table -> Table
setTableLayout props table =
    table
        |> setColumns (Dict.map (\name column -> column |> setState (\s -> { s | order = props.columns |> Dict.get name |> Maybe.map .position })))
        |> setState (\s -> { s | position = props.position, color = props.color })
