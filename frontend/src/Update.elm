module Update exposing (..)

import AssocList as Dict exposing (Dict)
import Draggable
import Draggable.Events exposing (onDragBy, onDragEnd, onDragStart)
import Libs.SchemaDecoders exposing (TableId(..))
import Libs.Std exposing (WheelEvent)
import Models exposing (DragId, DragState, Menu, Model(..), Msg(..), Position, UiSchema, UiTable, ZoomLevel, conf)


dragConfig : Draggable.Config DragId Msg
dragConfig =
    Draggable.customConfig
        [ onDragStart StartDragging
        , onDragEnd StopDragging
        , onDragBy OnDragBy
        ]


dragItem : UiSchema -> Menu -> DragState -> Draggable.Delta -> Model
dragItem schema menu drag delta =
    case drag.id of
        Just id ->
            if id == menu.id then
                Success schema (updatePosition menu delta 1) drag

            else if id == "erd" then
                Success schema menu (updatePosition drag delta 1)

            else
                Success (updateTable (TableId id) (\table -> updatePosition table delta drag.zoom) schema) menu drag

        Nothing ->
            Failure "Can't OnDragBy when no drag id"


zoomCanvas : UiSchema -> Menu -> DragState -> WheelEvent -> Model
zoomCanvas schema menu drag wheel =
    let
        newZoom : ZoomLevel
        newZoom =
            (drag.zoom + (wheel.delta.y * conf.zoom.speed)) |> clamp conf.zoom.min conf.zoom.max

        zoomFactor : Float
        zoomFactor =
            newZoom / drag.zoom

        -- to zoom on cursor, works only if origin is top left (CSS property: "transform-origin: top left;")
        newLeft : Float
        newLeft =
            drag.position.left - ((wheel.mouse.x - drag.position.left) * (zoomFactor - 1))

        newTop : Float
        newTop =
            drag.position.top - ((wheel.mouse.y - drag.position.top) * (zoomFactor - 1))
    in
    Success schema menu { drag | zoom = newZoom, position = Position newLeft newTop }


updateTable : TableId -> (UiTable -> UiTable) -> UiSchema -> UiSchema
updateTable id transform schema =
    { schema | tables = Dict.update id (Maybe.map transform) schema.tables }


updatePosition : { m | position : Position } -> Draggable.Delta -> ZoomLevel -> { m | position : Position }
updatePosition item ( dx, dy ) zoom =
    { item | position = Position (item.position.left + (dx / zoom)) (item.position.top + (dy / zoom)) }