module Update exposing (createLayout, deleteLayout, dragConfig, dragItem, hideAllTables, hideColumn, hideTable, loadLayout, showAllTables, showColumn, showTable, updateLayout, updateSchema, updateSizes, visitTable, visitTables, zoomCanvas)

import AssocList as Dict exposing (Dict)
import Commands.InitializeTable exposing (initializeTable)
import Conf exposing (conf)
import Draggable
import Draggable.Events exposing (onDragBy, onDragEnd, onDragStart)
import FileValue exposing (File)
import Json.Decode as Decode
import JsonFormats.SchemaDecoder exposing (schemaDecoder)
import Libs.Std exposing (WheelEvent, cond, dictFromList, listFind, maybeFilter, set, setSchema, setState)
import Mappers.SchemaMapper exposing (buildSchemaFromJson, buildSchemaFromSql)
import Models exposing (Canvas, DragId, Model, Msg(..), SizeChange, Status(..))
import Models.Schema exposing (Column, ColumnName, ColumnProps, Layout, LayoutName, Schema, Table, TableId, TableProps, TableStatus(..))
import Models.Utils exposing (Area, FileContent, Position, ZoomLevel)
import Ports exposing (activateTooltipsAndPopovers, observeTableSize, observeTablesSize)
import SqlParser.SchemaParser exposing (parseSchema)
import Views.Helpers exposing (formatTableId, parseTableId)



-- utility methods to get the update case down to one line


updateSchema : File -> FileContent -> Model -> Model
updateSchema file content model =
    if file.mime == "application/sql" then
        case parseSchema file.name content |> Result.map buildSchemaFromSql of
            Ok schema ->
                { model | schema = schema }

            Err _ ->
                model

    else if file.mime == "application/json" then
        case Decode.decodeString schemaDecoder content |> Result.map buildSchemaFromJson of
            Ok schema ->
                { model | schema = schema }

            Err _ ->
                model

    else
        model


hideTable : TableId -> Schema -> Schema
hideTable id schema =
    schema |> visitTable id (setState (\state -> { state | status = Hidden }))


showTable : Model -> TableId -> ( Model, Cmd Msg )
showTable model id =
    case getTable id model.schema |> Maybe.map (\t -> t.state.status) of
        Just Uninitialized ->
            -- race condition problem when observe is performed before table is shown :(
            ( { model | schema = model.schema |> visitTable id (setState (\state -> { state | status = Initializing })) }, Cmd.batch [ observeTableSize id, activateTooltipsAndPopovers () ] )

        Just Initializing ->
            ( model, Cmd.none )

        Just Hidden ->
            ( { model | schema = model.schema |> visitTable id (setState (\state -> { state | status = Shown, selected = False })) }, Cmd.batch [ observeTableSize id, activateTooltipsAndPopovers () ] )

        Just Shown ->
            ( model, Cmd.none )

        Nothing ->
            ( model |> setState (\state -> { state | status = Failure ("Can't show table (" ++ formatTableId id ++ "), not found") }), Cmd.none )


hideColumn : ColumnName -> Dict ColumnName Column -> Dict ColumnName Column
hideColumn columnName columns =
    columns
        |> Dict.update columnName (Maybe.map (setState (\state -> { state | order = Nothing })))
        |> setSequentialOrder


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
        |> dictFromList .column


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


hideAllTables : Schema -> Schema
hideAllTables schema =
    schema
        |> visitTables
            (setState
                (\state ->
                    if state.status == Shown then
                        { state | status = Hidden }

                    else
                        state
                )
            )


showAllTables : Model -> ( Model, Cmd Msg )
showAllTables model =
    let
        ( cmds, tables ) =
            model.schema.tables
                |> Dict.values
                |> List.map showTableByState
                |> List.unzip
    in
    ( { model | schema = model.schema |> setTables tables }
    , Cmd.batch [ observeTablesSize (cmds |> List.filterMap identity), activateTooltipsAndPopovers () ]
    )


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


toLayout : LayoutName -> Model -> Layout
toLayout name model =
    { name = name
    , canvas = { zoom = model.canvas.zoom, position = model.canvas.position }
    , tables = model.schema.tables |> Dict.values |> List.filter (\t -> t.state.status == Shown) |> List.map tableToLayout |> Dict.fromList
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


createLayout : LayoutName -> Model -> Model
createLayout name model =
    model
        |> setState (\s -> { s | newLayout = Nothing, currentLayout = Just name })
        |> setSchema (\s -> { s | layouts = (model |> toLayout name) :: s.layouts })


loadLayout : LayoutName -> Model -> ( Model, Cmd Msg )
loadLayout name model =
    model.schema.layouts
        |> listFind (\layout -> layout.name == name)
        |> Maybe.map
            (\layout ->
                let
                    ( cmds, tables ) =
                        model.schema.tables
                            |> Dict.values
                            |> List.map (\table -> showTableWithLayout (layout.tables |> Dict.get table.id) table)
                            |> List.unzip
                in
                ( model
                    |> set (\m -> { m | canvas = { size = model.canvas.size, zoom = layout.canvas.zoom, position = layout.canvas.position } })
                    |> setSchema (setTables tables)
                    |> setState (\s -> { s | currentLayout = Just name })
                , Cmd.batch [ observeTablesSize (cmds |> List.filterMap identity), activateTooltipsAndPopovers () ]
                )
            )
        |> Maybe.withDefault ( model, Cmd.none )


updateLayout : LayoutName -> Model -> Model
updateLayout name model =
    model
        |> setSchema (\s -> { s | layouts = s.layouts |> List.map (\l -> cond (l.name == name) (\_ -> model |> toLayout name) (\_ -> l)) })
        |> setState (\s -> { s | currentLayout = Just name })


deleteLayout : LayoutName -> Model -> Model
deleteLayout name model =
    model
        |> setSchema (\s -> { s | layouts = s.layouts |> List.filter (\l -> not (l.name == name)) })
        |> setState
            (\s ->
                if s.currentLayout == Just name then
                    { s | currentLayout = Nothing }

                else
                    s
            )


showTableWithLayout : Maybe TableProps -> Table -> ( Maybe TableId, Table )
showTableWithLayout maybeProps table =
    case ( table.state.status, maybeProps ) of
        ( Uninitialized, Just props ) ->
            ( Just table.id, table |> setState (\state -> { state | status = Initializing }) |> setTableLayout props )

        ( Uninitialized, Nothing ) ->
            ( Nothing, table )

        ( Initializing, Just props ) ->
            ( Nothing, table |> setTableLayout props )

        ( Initializing, Nothing ) ->
            ( Nothing, table |> setState (\state -> { state | status = Uninitialized }) )

        ( Hidden, Just props ) ->
            ( Just table.id, table |> setState (\state -> { state | status = Shown, selected = False }) |> setTableLayout props )

        ( Hidden, Nothing ) ->
            ( Nothing, table )

        ( Shown, Just props ) ->
            ( Nothing, table |> setTableLayout props )

        ( Shown, Nothing ) ->
            ( Nothing, table |> setState (\state -> { state | status = Hidden }) )


setTableLayout : TableProps -> Table -> Table
setTableLayout props table =
    { table
        | state = table.state |> set (\state -> { state | position = props.position, color = props.color })
        , columns = table.columns |> Dict.map (\name column -> column |> setState (\state -> { state | order = props.columns |> Dict.get name |> Maybe.map .position }))
    }


updateSizes : List SizeChange -> Model -> ( Model, Cmd Msg )
updateSizes sizeChanges model =
    ( sizeChanges |> List.foldr updateSize model, Cmd.batch (sizeChanges |> List.filterMap (maybeChangeCmd model)) )


updateSize : SizeChange -> Model -> Model
updateSize change model =
    if change.id == conf.ids.erd then
        { model | canvas = model.canvas |> setSize (\_ -> change.size) }

    else
        { model | schema = model.schema |> visitTable (parseTableId change.id) (setState (\state -> { state | size = change.size })) }


maybeChangeCmd : Model -> SizeChange -> Maybe (Cmd Msg)
maybeChangeCmd model { id, size } =
    model.schema.tables |> getInitializingTable (parseTableId id) |> Maybe.map (\t -> t.id |> initializeTable size (getArea model.canvas))


getInitializingTable : TableId -> Dict TableId Table -> Maybe Table
getInitializingTable id tables =
    Dict.get id tables |> maybeFilter (\t -> t.state.status == Initializing)


getArea : Canvas -> Area
getArea canvas =
    { left = (0 - canvas.position.left) / canvas.zoom
    , right = (canvas.size.width - canvas.position.left) / canvas.zoom
    , top = (0 - canvas.position.top) / canvas.zoom
    , bottom = (canvas.size.height - canvas.position.top) / canvas.zoom
    }


zoomCanvas : WheelEvent -> Canvas -> Canvas
zoomCanvas wheel canvas =
    let
        newZoom : ZoomLevel
        newZoom =
            (canvas.zoom + (wheel.delta.y * conf.zoom.speed)) |> clamp conf.zoom.min conf.zoom.max

        zoomFactor : Float
        zoomFactor =
            newZoom / canvas.zoom

        -- to zoom on cursor, works only if origin is top left (CSS property: "transform-origin: top left;")
        newLeft : Float
        newLeft =
            canvas.position.left - ((wheel.mouse.x - canvas.position.left) * (zoomFactor - 1))

        newTop : Float
        newTop =
            canvas.position.top - ((wheel.mouse.y - canvas.position.top) * (zoomFactor - 1))
    in
    { canvas | zoom = newZoom, position = Position newLeft newTop }


dragConfig : Draggable.Config DragId Msg
dragConfig =
    Draggable.customConfig
        [ onDragStart StartDragging
        , onDragEnd StopDragging
        , onDragBy OnDragBy
        ]


dragItem : Model -> Draggable.Delta -> Model
dragItem model delta =
    case model.state.dragId of
        Just id ->
            if id == conf.ids.erd then
                { model | canvas = model.canvas |> updatePosition delta 1 }

            else
                { model | schema = model.schema |> visitTable (parseTableId id) (setState (updatePosition delta model.canvas.zoom)) }

        Nothing ->
            model |> setState (\state -> { state | status = Failure "Can't OnDragBy when no drag id" })



-- update helpers


visitTables : (Table -> Table) -> Schema -> Schema
visitTables transform schema =
    { schema | tables = schema.tables |> Dict.map (\_ table -> transform table) }


visitTable : TableId -> (Table -> Table) -> Schema -> Schema
visitTable id transform schema =
    { schema | tables = schema.tables |> Dict.update id (Maybe.map transform) }


getTable : TableId -> Schema -> Maybe Table
getTable id schema =
    schema.tables |> Dict.get id


setTables : List Table -> Schema -> Schema
setTables tables schema =
    { schema | tables = tables |> dictFromList .id }


setSize : (s -> s) -> { item | size : s } -> { item | size : s }
setSize transform item =
    { item | size = item.size |> transform }


updatePosition : Draggable.Delta -> ZoomLevel -> { item | position : Position } -> { item | position : Position }
updatePosition ( dx, dy ) zoom item =
    { item | position = Position (item.position.left + (dx / zoom)) (item.position.top + (dy / zoom)) }
