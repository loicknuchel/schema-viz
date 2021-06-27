module Models exposing (Canvas, DragId, Error, Flags, Menu, Model, Msg(..), SizeChange, State, Status(..))

import Decoders.SchemaDecoder exposing (JsonTable)
import Draggable
import Http
import Libs.Std exposing (WheelEvent)
import Models.Schema exposing (Schema, TableId)
import Models.Utils exposing (Color, Position, Size, ZoomLevel)



-- main models for app, the usual Model & Msg but also the ones not deserving their own file or not too generic


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


type alias ZoomDelta =
    Float


type alias SizeChange =
    { id : String, size : Size }


type alias Error =
    String
