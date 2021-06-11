module Models exposing (..)

import Browser.Dom as Dom
import Draggable
import Http
import Libs.SchemaDecoders exposing (Schema, Table)


type Model
    = Loading
    | Failure Error
    | HasData Schema
    | HasSizes SizedSchema
    | Success UiSchema Menu DragState


type Msg
    = GotSchema (Result Http.Error Schema)
    | GotSizes (Result Dom.Error ( SizedSchema, WindowSize ))
    | GotLayout UiSchema
    | StartDragging DragId
    | StopDragging
    | OnDragBy Draggable.Delta
    | DragMsg (Draggable.Msg DragId)


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
    { id : Maybe DragId, drag : Draggable.State DragId }


type alias WindowSize =
    Size


type alias TableId =
    DragId


type alias DragId =
    String


type alias Color =
    String


type alias Error =
    String


colors =
    { red = "#E3342F", pink = "#F66D9B", orange = "#F6993F", yellow = "#FFED4A", green = "#4DC0B5", blue = "#3490DC", darkBlue = "#6574CD", purple = "#9561E2", grey = "#B8C2CC" }
