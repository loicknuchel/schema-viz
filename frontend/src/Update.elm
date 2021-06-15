module Update exposing (..)

import AssocList as Dict
import Draggable
import Draggable.Events exposing (onDragBy, onDragEnd, onDragStart)
import Libs.Std exposing (WheelEvent)
import Models exposing (DragId, Menu, Model(..), Msg(..), UiState, ZoomLevel, conf)
import Models.Schema exposing (Schema, Table, TableId(..), TableState)
import Models.Utils exposing (Position)



-- utility methods to get the update case down to one line


dragConfig : Draggable.Config DragId Msg
dragConfig =
    Draggable.customConfig
        [ onDragStart StartDragging
        , onDragEnd StopDragging
        , onDragBy OnDragBy
        ]


dragItem : Schema -> Menu -> UiState -> Draggable.Delta -> Model
dragItem schema menu drag delta =
    case drag.id of
        Just id ->
            if id == conf.ids.menu then
                Success schema (setPosition delta 1 menu) drag

            else if id == conf.ids.erd then
                Success schema menu (setPosition delta 1 drag)

            else
                Success (visitTable (TableId id) (setState (setPosition delta drag.zoom)) schema) menu drag

        Nothing ->
            Failure "Can't OnDragBy when no drag id"


zoomCanvas : Schema -> Menu -> UiState -> WheelEvent -> Model
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


hideTable : Schema -> Menu -> UiState -> TableId -> Model
hideTable schema menu drag id =
    Success (visitTable id (setState (\state -> { state | show = False })) schema) menu drag


showTable : Schema -> Menu -> UiState -> TableId -> Model
showTable schema menu drag id =
    Success (visitTable id (setState (\state -> { state | show = True })) schema) menu drag



-- update helpers


visitTables : (Table -> Table) -> Schema -> Schema
visitTables transform schema =
    { schema
        | tables = Dict.map (\_ table -> transform table) schema.tables
        , relations = List.map (\( fk, ( st, sc ), ( rt, rc ) ) -> ( fk, ( transform st, sc ), ( transform rt, rc ) )) schema.relations
    }


visitTable : TableId -> (Table -> Table) -> Schema -> Schema
visitTable id transform schema =
    { schema
        | tables = Dict.update id (Maybe.map transform) schema.tables
        , relations = List.map (\( fk, ( st, sc ), ( rt, rc ) ) -> ( fk, ( cond id transform st, sc ), ( cond id transform rt, rc ) )) schema.relations
    }


cond : TableId -> (Table -> Table) -> Table -> Table
cond id transform table =
    if table.id == id then
        transform table

    else
        table


setState : (TableState -> TableState) -> Table -> Table
setState stateTransform table =
    { table | state = stateTransform table.state }


setPosition : Draggable.Delta -> ZoomLevel -> { m | position : Position } -> { m | position : Position }
setPosition ( dx, dy ) zoom item =
    { item | position = Position (item.position.left + (dx / zoom)) (item.position.top + (dy / zoom)) }
