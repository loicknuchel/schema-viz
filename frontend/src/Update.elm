module Update exposing (dragConfig, dragItem, hideAllTables, hideTable, setState, showAllTables, showTable, updateSizes, updateTable, zoomCanvas)

import AssocList as Dict exposing (Dict)
import Commands.InitializeTable exposing (initializeTable)
import Draggable
import Draggable.Events exposing (onDragBy, onDragEnd, onDragStart)
import Libs.Std exposing (WheelEvent, maybeFilter)
import Models exposing (DragId, Model, Msg(..), SizeChange, Status(..), ZoomLevel, conf)
import Models.Schema exposing (Schema, Table, TableId(..), TableState, TableStatus(..), formatTableId)
import Models.Utils exposing (Position)
import Ports exposing (observeTableSize)
import Task



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
    ( model
    , Cmd.batch
        (List.filterMap
            (\table ->
                case table.state.status of
                    Uninitialized ->
                        Just (Task.perform ShowTable (Task.succeed table.id))

                    Hidden ->
                        Just (Task.perform ShowTable (Task.succeed table.id))

                    _ ->
                        Nothing
            )
            (Dict.values model.schema.tables)
        )
    )


updateSizes : List SizeChange -> Model -> ( Model, Cmd Msg )
updateSizes sizeChanges model =
    ( List.foldr (\change m -> { m | schema = updateTable (\s -> { s | size = change.size }) (TableId change.id) m.schema }) model sizeChanges
    , Cmd.batch (List.filterMap (\{ id, size } -> getInitTable id model.schema.tables |> Maybe.map (\t -> initializeTable t.id size model.state.windowSize)) sizeChanges)
    )


getInitTable : String -> Dict TableId Table -> Maybe Table
getInitTable id tables =
    Dict.get (TableId id) tables |> maybeFilter (\t -> t.state.status == Initializing)


zoomCanvas : WheelEvent -> Model -> Model
zoomCanvas wheel model =
    let
        newZoom : ZoomLevel
        newZoom =
            (model.state.zoom + (wheel.delta.y * conf.zoom.speed)) |> clamp conf.zoom.min conf.zoom.max

        zoomFactor : Float
        zoomFactor =
            newZoom / model.state.zoom

        -- to zoom on cursor, works only if origin is top left (CSS property: "transform-origin: top left;")
        newLeft : Float
        newLeft =
            model.state.position.left - ((wheel.mouse.x - model.state.position.left) * (zoomFactor - 1))

        newTop : Float
        newTop =
            model.state.position.top - ((wheel.mouse.y - model.state.position.top) * (zoomFactor - 1))

        newModel : Model
        newModel =
            setState (\state -> { state | zoom = newZoom, position = Position newLeft newTop }) model
    in
    newModel


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
                { model | menu = setPosition delta 1 model.menu }

            else if id == conf.ids.erd then
                { model | state = setPosition delta 1 model.state }

            else
                { model | schema = visitTable (TableId id) (setState (setPosition delta model.state.zoom)) model.schema }

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


setState : (state -> state) -> { item | state : state } -> { item | state : state }
setState transform item =
    { item | state = transform item.state }


setPosition : Draggable.Delta -> ZoomLevel -> { item | position : Position } -> { item | position : Position }
setPosition ( dx, dy ) zoom item =
    { item | position = Position (item.position.left + (dx / zoom)) (item.position.top + (dy / zoom)) }
