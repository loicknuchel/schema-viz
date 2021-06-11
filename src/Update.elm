module Update exposing (..)

import Draggable
import Draggable.Events exposing (onDragBy, onDragEnd, onDragStart)
import Models exposing (DragId, DragState, Menu, Model(..), Msg(..), Position, TableId, UiSchema, UiTable)


dragConfig : Draggable.Config DragId Msg
dragConfig =
    Draggable.customConfig
        [ onDragStart StartDragging
        , onDragEnd StopDragging
        , onDragBy OnDragBy
        ]


dragItem : UiSchema -> Menu -> DragState -> Draggable.Delta -> ( Model, Cmd Msg )
dragItem schema menu drag delta =
    case drag.id of
        Just id ->
            if id == menu.id then
                ( Success schema (updatePosition menu delta) drag, Cmd.none )

            else
                ( Success (updateTable (\table -> updatePosition table delta) id schema) menu drag, Cmd.none )

        Nothing ->
            ( Failure "Can't OnDragBy when no drag id", Cmd.none )


updateTable : (UiTable -> UiTable) -> TableId -> UiSchema -> UiSchema
updateTable transform id schema =
    { schema
        | tables =
            List.map
                (\table ->
                    if table.id == id then
                        transform table

                    else
                        table
                )
                schema.tables
    }


updatePosition : { m | position : Position } -> Draggable.Delta -> { m | position : Position }
updatePosition item ( dx, dy ) =
    { item | position = Position (item.position.left + dx) (item.position.top + dy) }
