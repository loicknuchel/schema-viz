module Update exposing (dragConfig, dragItem, hideAllTables, hideTable, setState, showAllTables, showTable, updateSizes, updateTable, zoomCanvas)

import AssocList as Dict exposing (Dict)
import Commands.InitializeTable exposing (initializeTable)
import Draggable
import Draggable.Events exposing (onDragBy, onDragEnd, onDragStart)
import Libs.Std exposing (WheelEvent, dictFromList, maybeFilter)
import Models exposing (Canvas, DragId, Model, Msg(..), SizeChange, Status(..), ZoomLevel, conf)
import Models.Schema exposing (Schema, Table, TableId(..), TableState, TableStatus(..), formatTableId)
import Models.Utils exposing (Area, Position)
import Ports exposing (observeTableSize, observeTablesSize)



-- utility methods to get the update case down to one line


hideTable : Schema -> TableId -> Schema
hideTable schema id =
    visitTable id (setState (\state -> { state | status = Hidden })) schema


showTable : Model -> TableId -> ( Model, Cmd Msg )
showTable model id =
    case Maybe.map (\t -> t.state.status) (getTable id model.schema) of
        Just Uninitialized ->
            -- race condition problem when observe is performed before table is shown :(
            ( { model | schema = visitTable id (setState (\state -> { state | status = Initializing })) model.schema }, observeTableSize id )

        Just Initializing ->
            ( setState (\state -> { state | status = Failure ("Can't show an Initializing table (" ++ formatTableId id ++ ")") }) model, Cmd.none )

        Just Hidden ->
            ( { model | schema = visitTable id (setState (\state -> { state | status = Shown })) model.schema }, observeTableSize id )

        Just Shown ->
            ( setState (\state -> { state | status = Failure ("Table (" ++ formatTableId id ++ ") is already Shown") }) model, Cmd.none )

        Nothing ->
            ( setState (\state -> { state | status = Failure ("Can't show table (" ++ formatTableId id ++ "), not found") }) model, Cmd.none )


updateTable : (TableState -> TableState) -> TableId -> Schema -> Schema
updateTable transform id schema =
    visitTable id (setState transform) schema


hideAllTables : Schema -> Schema
hideAllTables schema =
    visitTables
        (setState
            (\state ->
                if state.status == Shown then
                    { state | status = Hidden }

                else
                    state
            )
        )
        schema


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
    ( { model | schema = setTables tables model.schema }, observeTablesSize (List.filterMap identity cmds) )


updateSizes : List SizeChange -> Model -> ( Model, Cmd Msg )
updateSizes sizeChanges model =
    ( List.foldr updateSize model sizeChanges, Cmd.batch (List.filterMap (maybeChangeCmd model) sizeChanges) )


updateSize : SizeChange -> Model -> Model
updateSize change model =
    if change.id == conf.ids.erd then
        { model | canvas = setSize (\_ -> change.size) model.canvas }

    else
        { model | schema = updateTable (\s -> { s | size = change.size }) (TableId change.id) model.schema }


maybeChangeCmd : Model -> SizeChange -> Maybe (Cmd Msg)
maybeChangeCmd model { id, size } =
    getInitializingTable id model.schema.tables |> Maybe.map (\t -> initializeTable size (getArea model.canvas) t.id)


getArea : Canvas -> Area
getArea canvas =
    { left = (0 - canvas.position.left) / canvas.zoom
    , right = (canvas.size.width - canvas.position.left) / canvas.zoom
    , top = (0 - canvas.position.top) / canvas.zoom
    , bottom = (canvas.size.height - canvas.position.top) / canvas.zoom
    }


getInitializingTable : String -> Dict TableId Table -> Maybe Table
getInitializingTable id tables =
    Dict.get (TableId id) tables |> maybeFilter (\t -> t.state.status == Initializing)


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
            if id == conf.ids.menu then
                { model | menu = updatePosition delta 1 model.menu }

            else if id == conf.ids.erd then
                { model | canvas = updatePosition delta 1 model.canvas }

            else
                { model | schema = visitTable (TableId id) (setState (updatePosition delta model.canvas.zoom)) model.schema }

        Nothing ->
            setState (\state -> { state | status = Failure "Can't OnDragBy when no drag id" }) model



-- update helpers


visitTables : (Table -> Table) -> Schema -> Schema
visitTables transform schema =
    { schema | tables = Dict.map (\_ table -> transform table) schema.tables }


visitTable : TableId -> (Table -> Table) -> Schema -> Schema
visitTable id transform schema =
    { schema | tables = Dict.update id (Maybe.map transform) schema.tables }


getTable : TableId -> Schema -> Maybe Table
getTable id schema =
    Dict.get id schema.tables


setTables : List Table -> Schema -> Schema
setTables tables schema =
    { schema | tables = dictFromList .id tables }


setState : (s -> s) -> { item | state : s } -> { item | state : s }
setState transform item =
    { item | state = transform item.state }


setSize : (s -> s) -> { item | size : s } -> { item | size : s }
setSize transform item =
    { item | size = transform item.size }


updatePosition : Draggable.Delta -> ZoomLevel -> { item | position : Position } -> { item | position : Position }
updatePosition ( dx, dy ) zoom item =
    { item | position = Position (item.position.left + (dx / zoom)) (item.position.top + (dy / zoom)) }
