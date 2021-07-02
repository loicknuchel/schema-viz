module Models exposing (Canvas, DragId, Error, Flags, Model, Msg(..), SizeChange, State, Status(..))

import Draggable
import FileValue exposing (File)
import Http
import JsonFormats.SchemaDecoder exposing (JsonTable)
import Libs.Std exposing (WheelEvent)
import Models.Schema exposing (ColumnRef, Schema, TableId, TableStatus(..))
import Models.Utils exposing (Position, Size, ZoomLevel)



-- main models for app, the usual Model & Msg but also the ones not deserving their own file or not too generic


type alias Flags =
    ()


type alias Model =
    { state : State, canvas : Canvas, schema : Schema }


type alias State =
    { status : Status, search : String, newLayout : Maybe String, dragId : Maybe DragId, drag : Draggable.State DragId }


type alias Canvas =
    { size : Size, zoom : ZoomLevel, position : Position }


type Status
    = Loading
    | Failure Error
    | Success


type Msg
    = GotData (Result Http.Error (List ( JsonTable, TableId )))
    | ChangedSearch String
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
    | NewLayout String
    | CreateLayout
    | LoadLayout String
    | UpdateLayout String
    | DeleteLayout String
    | FileSelected File
    | FileDragOver File (List File)
    | FileDragLeave
    | FileDropped File (List File)
    | FileRead ( File, String )


type alias DragId =
    String


type alias ZoomDelta =
    Float


type alias SizeChange =
    { id : String, size : Size }


type alias Error =
    String
