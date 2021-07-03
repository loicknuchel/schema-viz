module Models exposing (Canvas, DragId, Error, Flags, Model, Msg(..), Search, SizeChange, State, Status(..))

import Draggable
import FileValue exposing (File)
import Http
import JsonFormats.SchemaDecoder exposing (JsonSchema)
import Libs.Std exposing (WheelEvent)
import Models.Schema exposing (ColumnRef, LayoutName, Schema, TableId, TableStatus(..))
import Models.Utils exposing (FileContent, HtmlId, Position, Size, ZoomLevel)



-- main models for app, the usual Model & Msg but also the ones not deserving their own file or not too generic


type alias Flags =
    ()


type alias Model =
    { state : State, canvas : Canvas, schema : Schema }


type alias State =
    { status : Status, search : Search, newLayout : Maybe LayoutName, currentLayout : Maybe LayoutName, dragId : Maybe DragId, drag : Draggable.State DragId }


type alias Canvas =
    { size : Size, zoom : ZoomLevel, position : Position }


type Status
    = Loading
    | Failure Error
    | Success


type Msg
    = GotData (Result Http.Error JsonSchema)
    | ChangedSearch Search
    | SelectTable TableId
    | HideTable TableId
    | ShowTable TableId
    | InitializedTable TableId Size Position
    | SizesChanged (List SizeChange)
    | HideAllTables
    | ShowAllTables
    | HideColumn ColumnRef
    | ShowColumn ColumnRef Int
    | Zoom WheelEvent
    | DragMsg (Draggable.Msg DragId)
    | StartDragging DragId
    | StopDragging
    | OnDragBy Draggable.Delta
    | NewLayout LayoutName
    | CreateLayout LayoutName
    | LoadLayout LayoutName
    | UpdateLayout LayoutName
    | DeleteLayout LayoutName
    | FileSelected File
    | FileDragOver File (List File)
    | FileDragLeave
    | FileDropped File (List File)
    | FileRead ( File, FileContent )
    | Noop


type alias Search =
    String


type alias DragId =
    String


type alias ZoomDelta =
    Float


type alias SizeChange =
    { id : HtmlId, size : Size }


type alias Error =
    String
