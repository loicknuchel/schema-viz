module Update exposing (dragConfig, dragItem, hideAllTables, hideTable, showAllTables, showTable, updateSizes, updateTable, zoomCanvas)

import AssocList as Dict exposing (Dict)
import Commands.InitializeTable exposing (initializeTable)
import Conf exposing (conf)
import Draggable
import Draggable.Events exposing (onDragBy, onDragEnd, onDragStart)
import Libs.Std exposing (WheelEvent, dictFromList, maybeFilter, setState)
import Models exposing (Canvas, DragId, Model, Msg(..), SizeChange, Status(..))
import Models.Schema exposing (Schema, Table, TableId, TableState, TableStatus(..))
import Models.Utils exposing (Area, Position, ZoomLevel)
import Ports exposing (activateTooltipsAndPopovers, observeTableSize, observeTablesSize)
import Views.Helpers exposing (formatTableId, parseTableId)



-- utility methods to get the update case down to one line


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
            ( { model | schema = model.schema |> visitTable id (setState (\state -> { state | status = Shown })) }, Cmd.batch [ observeTableSize id, activateTooltipsAndPopovers () ] )

        Just Shown ->
            ( model, Cmd.none )

        Nothing ->
            ( model |> setState (\state -> { state | status = Failure ("Can't show table (" ++ formatTableId id ++ "), not found") }), Cmd.none )


updateTable : TableId -> (TableState -> TableState) -> Schema -> Schema
updateTable id transform schema =
    schema |> visitTable id (setState transform)


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
                |> List.map
                    (\table ->
                        case table.state.status of
                            Uninitialized ->
                                ( Just table.id, setState (\state -> { state | status = Initializing }) table )

                            Initializing ->
                                ( Nothing, table )

                            Hidden ->
                                ( Just table.id, setState (\state -> { state | status = Shown }) table )

                            Shown ->
                                ( Nothing, table )
                    )
                |> List.unzip
    in
    ( { model | schema = model.schema |> setTables tables }, Cmd.batch [ observeTablesSize (cmds |> List.filterMap identity), activateTooltipsAndPopovers () ] )


updateSizes : List SizeChange -> Model -> ( Model, Cmd Msg )
updateSizes sizeChanges model =
    ( sizeChanges |> List.foldr updateSize model, Cmd.batch (sizeChanges |> List.filterMap (maybeChangeCmd model)) )


updateSize : SizeChange -> Model -> Model
updateSize change model =
    if change.id == conf.ids.erd then
        { model | canvas = model.canvas |> setSize (\_ -> change.size) }

    else
        { model | schema = model.schema |> updateTable (parseTableId change.id) (\state -> { state | size = change.size }) }


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
