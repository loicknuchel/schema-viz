module Models exposing (Canvas, DragId, Error, Flags, Menu, Model, Msg(..), SizeChange, State, Status(..), ZoomLevel, conf)

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
    , loading : { showTablesThreshold : Int }
    }
conf =
    { zoom = { min = 0.1, max = 5, speed = 0.001 }
    , colors = { pink = "#F66D9B", purple = "#9561E2", darkBlue = "#6574CD", blue = "#3490DC", turquoise = "#4DC0B5", lightBlue = "#22D3EE", lightGreen = "#84CC16", green = "#38C172", yellow = "#FFED4A", orange = "#F6993F", red = "#E3342F", grey = "#B8C2CC" }
    , defaultSchema = "public"
    , ids = { menu = "menu", erd = "erd" }
    , loading = { showTablesThreshold = 20 }
    }


type alias Flags =
    ()


type alias Model =
    { state : State, menu : Menu, canvas : Canvas, schema : Schema }


type alias State =
    { status : Status, dragId : Maybe DragId, drag : Draggable.State DragId }


type alias Menu =
    { position : Position }


type alias Canvas =
    { size : Size, zoom : ZoomLevel, position : Position }


type Status
    = Loading
    | Failure Error
    | Success


type Msg
    = GotData (Result Http.Error (List ( JsonTable, TableId )))
    | HideTable TableId
    | ShowTable TableId
    | InitializedTable TableId Size Position Color
    | SizesChanged (List SizeChange)
    | HideAllTables
    | ShowAllTables
    | Zoom WheelEvent
    | DragMsg (Draggable.Msg DragId)
    | StartDragging DragId
    | StopDragging
    | OnDragBy Draggable.Delta


type alias DragId =
    String


type alias ZoomLevel =
    Float


type alias ZoomDelta =
    Float


type alias SizeChange =
    { id : String, size : Size }


type alias Error =
    String
