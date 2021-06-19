module Update exposing (..)

import AssocList as Dict
import Commands.GetSize exposing (getTableSize)
import Draggable
import Draggable.Events exposing (onDragBy, onDragEnd, onDragStart)
import Libs.Std exposing (WheelEvent)
import Models exposing (DragId, Model, Msg(..), State, Status(..), ZoomLevel, conf)
import Models.Schema exposing (Schema, Table, TableId(..), TableStatus(..), formatTableId)
import Models.Utils exposing (Color, Position, Size)
import Task



-- utility methods to get the update case down to one line


hideTable : Schema -> TableId -> Schema
hideTable schema id =
    visitTable id (setState (\state -> { state | status = Ready })) schema


showTable : Model -> TableId -> ( Model, Cmd Msg )
showTable model id =
    case Maybe.map (\t -> t.state.status) (getTable id model.schema) of
        Just Uninitialized ->
            ( { model | schema = visitTable id (setState (\state -> { state | status = Hidden })) model.schema }, getTableSize id )

        Just Ready ->
            ( { model | schema = visitTable id (setState (\state -> { state | status = Visible })) model.schema }, Cmd.none )

        Just Hidden ->
            ( setState (\state -> { state | status = Failure ("Can't show a Hidden table (" ++ formatTableId id ++ ")") }) model, Cmd.none )

        Just Visible ->
            ( model, Cmd.none )

        Nothing ->
            ( setState (\state -> { state | status = Failure ("Can't show table (" ++ formatTableId id ++ "), not found") }) model, Cmd.none )


updateTable : Schema -> TableId -> Size -> Position -> Color -> Schema
updateTable schema id size position color =
    visitTable id (setState (\state -> { state | status = Visible, size = size, position = position, color = color })) schema


hideAllTables : Schema -> Schema
hideAllTables schema =
    visitTables
        (setState
            (\state ->
                case state.status of
                    Uninitialized ->
                        state

                    Ready ->
                        state

                    Hidden ->
                        state

                    Visible ->
                        { state | status = Ready }
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

                    Ready ->
                        Just (Task.perform ShowTable (Task.succeed table.id))

                    _ ->
                        Nothing
            )
            (Dict.values model.schema.tables)
        )
    )


zoomCanvas : State -> WheelEvent -> State
zoomCanvas state wheel =
    let
        newZoom : ZoomLevel
        newZoom =
            (state.zoom + (wheel.delta.y * conf.zoom.speed)) |> clamp conf.zoom.min conf.zoom.max

        zoomFactor : Float
        zoomFactor =
            newZoom / state.zoom

        -- to zoom on cursor, works only if origin is top left (CSS property: "transform-origin: top left;")
        newLeft : Float
        newLeft =
            state.position.left - ((wheel.mouse.x - state.position.left) * (zoomFactor - 1))

        newTop : Float
        newTop =
            state.position.top - ((wheel.mouse.y - state.position.top) * (zoomFactor - 1))
    in
    { state | zoom = newZoom, position = Position newLeft newTop }


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
