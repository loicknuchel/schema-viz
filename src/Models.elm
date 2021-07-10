module Models exposing (Canvas, Confirm, DragId, Error, Errors, Flags, Model, Msg(..), Search, State, Switch, TimeInfo, initConfirm, initModel, initSwitch)

import Draggable
import FileValue exposing (File)
import Html exposing (Html, text)
import Http
import Libs.Std exposing (WheelEvent, send)
import Mappers.SchemaMapper exposing (emptySchema)
import Models.Schema exposing (ColumnRef, LayoutName, Schema, TableId, TableStatus(..))
import Models.Utils exposing (Position, Size, Text, ZoomLevel)
import Ports exposing (JsMsg)
import Time



-- main models for app, the usual Model & Msg but also the ones not deserving their own file or not too generic


type alias Flags =
    ()


type alias Model =
    { time : TimeInfo, switch : Switch, state : State, canvas : Canvas, schema : Schema, storedSchemas : List Schema, confirm : Confirm }


initModel : Model
initModel =
    { time = initTimeInfo, switch = initSwitch, state = initState, canvas = initCanvas, schema = emptySchema, storedSchemas = [], confirm = initConfirm }


type alias TimeInfo =
    { zone : Time.Zone, now : Time.Posix }


initTimeInfo : TimeInfo
initTimeInfo =
    { zone = Time.utc, now = Time.millisToPosix 0 }


type alias Switch =
    { loading : Bool }


initSwitch : Switch
initSwitch =
    { loading = False }


type alias State =
    { search : Search, newLayout : Maybe LayoutName, currentLayout : Maybe LayoutName, dragId : Maybe DragId, drag : Draggable.State DragId }


initState : State
initState =
    { search = "", newLayout = Nothing, currentLayout = Nothing, dragId = Nothing, drag = Draggable.init }


type alias Canvas =
    { size : Size, zoom : ZoomLevel, position : Position }


initCanvas : Canvas
initCanvas =
    { size = Size 0 0, zoom = 1, position = Position 0 0 }


type alias Confirm =
    { content : Html Msg, cmd : Cmd Msg }


initConfirm : Confirm
initConfirm =
    { content = text "No text", cmd = send Noop }


type Msg
    = TimeChanged Time.Posix
    | ZoneChanged Time.Zone
    | ChangeSchema
    | FileDragOver File (List File)
    | FileDragLeave
    | FileDropped File (List File)
    | FileSelected File
    | LoadSampleData String
    | GotSampleData Time.Posix String String (Result Http.Error Text)
    | DeleteSchema Schema
    | UseSchema Schema
    | ChangedSearch Search
    | SelectTable TableId
    | HideTable TableId
    | ShowTable TableId
    | InitializedTable TableId Size Position
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
    | OpenConfirm Confirm
    | OnConfirm Bool (Cmd Msg)
    | JsMessage JsMsg
    | Noop


type alias Error =
    String


type alias Errors =
    List Error


type alias Search =
    String


type alias DragId =
    String