module Models exposing (..)

import Browser.Dom as Dom
import Draggable
import Http
import Libs.SchemaDecoders exposing (Schema, Table)
import Libs.Std exposing (WheelEvent)


conf :
    { zoom : { min : ZoomLevel, max : ZoomLevel, speed : Float }
    , colors : { red : Color, pink : Color, orange : Color, yellow : Color, green : Color, blue : Color, darkBlue : Color, purple : Color, grey : Color }
    }
conf =
    { zoom = { min = 0.2, max = 5, speed = 0.001 }
    , colors = { red = "#E3342F", pink = "#F66D9B", orange = "#F6993F", yellow = "#FFED4A", green = "#4DC0B5", blue = "#3490DC", darkBlue = "#6574CD", purple = "#9561E2", grey = "#B8C2CC" }
    }


type Model
    = Loading
    | Failure Error
    | HasData Schema
    | HasSizes SizedSchema
    | Success UiSchema Menu DragState


type Msg
    = GotSchema (Result Http.Error Schema)
    | GotSizes (Result Dom.Error ( SizedSchema, WindowSize ))
    | GotLayout UiSchema ZoomLevel CanvasPosition
    | StartDragging DragId
    | StopDragging
    | OnDragBy Draggable.Delta
    | DragMsg (Draggable.Msg DragId)
    | Zoom WheelEvent


type alias Menu =
    { id : DragId, position : Position }


type alias UiSchema =
    { tables : List UiTable }


type alias UiTable =
    { id : TableId, sql : Table, size : Size, color : Color, position : Position }


type alias SizedSchema =
    { tables : List SizedTable }


type alias SizedTable =
    { id : TableId, sql : Table, size : Size }


type alias Size =
    { width : Float, height : Float }


type alias Position =
    { left : Float, top : Float }


type alias DragState =
    { zoom : ZoomLevel, position : CanvasPosition, id : Maybe DragId, drag : Draggable.State DragId }


type alias WindowSize =
    Size


type alias TableId =
    DragId


type alias DragId =
    String


type alias Color =
    String


type alias ZoomLevel =
    Float


type alias ZoomDelta =
    Float


type alias CanvasPosition =
    Position


type alias Error =
    String
