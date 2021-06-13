module Models exposing (..)

import AssocList exposing (Dict)
import Browser.Dom as Dom
import Draggable
import Http
import Libs.SchemaDecoders exposing (Schema, Table, TableId)
import Libs.Std exposing (WheelEvent)


conf :
    { zoom : { min : ZoomLevel, max : ZoomLevel, speed : Float }
    , colors : { pink : Color, purple : Color, darkBlue : Color, blue : Color, turquoise : Color, lightBlue : Color, lightGreen : Color, green : Color, yellow : Color, orange : Color, red : Color, grey : Color }
    , defaultSchema : String
    }
conf =
    { zoom = { min = 0.2, max = 5, speed = 0.001 }
    , colors = { pink = "#F66D9B", purple = "#9561E2", darkBlue = "#6574CD", blue = "#3490DC", turquoise = "#4DC0B5", lightBlue = "#22D3EE", lightGreen = "#84CC16", green = "#38C172", yellow = "#FFED4A", orange = "#F6993F", red = "#E3342F", grey = "#B8C2CC" }
    , defaultSchema = "public"
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
    { tables : Dict TableId UiTable }


type alias UiTable =
    { id : TableId, sql : Table, size : Size, color : Color, position : Position }


type alias SizedSchema =
    { tables : Dict TableId SizedTable }


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
