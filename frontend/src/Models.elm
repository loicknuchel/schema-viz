module Models exposing (..)

import Browser.Dom as Dom
import Decoders.SchemaDecoder exposing (JsonTable)
import Draggable
import Http
import Libs.Std exposing (WheelEvent)
import Models.Schema exposing (Schema, TableId)
import Models.Utils exposing (Color, Position, Size)



-- main models and conf for app, the usual Model & Msg but also the ones not deserving their own file or not too generic


conf :
    { zoom : { min : ZoomLevel, max : ZoomLevel, speed : Float }
    , colors : { pink : Color, purple : Color, darkBlue : Color, blue : Color, turquoise : Color, lightBlue : Color, lightGreen : Color, green : Color, yellow : Color, orange : Color, red : Color, grey : Color }
    , defaultSchema : String
    , ids : { menu : String, erd : String }
    }
conf =
    { zoom = { min = 0.2, max = 5, speed = 0.001 }
    , colors = { pink = "#F66D9B", purple = "#9561E2", darkBlue = "#6574CD", blue = "#3490DC", turquoise = "#4DC0B5", lightBlue = "#22D3EE", lightGreen = "#84CC16", green = "#38C172", yellow = "#FFED4A", orange = "#F6993F", red = "#E3342F", grey = "#B8C2CC" }
    , defaultSchema = "public"
    , ids = { menu = "menu", erd = "erd" }
    }


type Model
    = Loading
    | Failure Error
    | HasData (List ( JsonTable, TableId ))
    | HasSizes (List ( JsonTable, TableId, Size )) WindowSize
    | Success Schema Menu UiState


type Msg
    = GotData (Result Http.Error (List ( JsonTable, TableId )))
    | GotSizes (Result Dom.Error ( List ( JsonTable, TableId, Size ), WindowSize ))
    | GotLayout Schema ZoomLevel CanvasPosition
    | StartDragging DragId
    | StopDragging
    | OnDragBy Draggable.Delta
    | DragMsg (Draggable.Msg DragId)
    | Zoom WheelEvent


type alias Menu =
    { position : Position }


type alias UiState =
    { zoom : ZoomLevel, position : CanvasPosition, id : Maybe DragId, drag : Draggable.State DragId }


type alias WindowSize =
    Size


type alias DragId =
    String


type alias ZoomLevel =
    Float


type alias ZoomDelta =
    Float


type alias CanvasPosition =
    Position


type alias Error =
    String
