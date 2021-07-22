module Models exposing (Confirm, DragId, Error, Errors, Flags, JsMsg(..), Model, Msg(..), Search, Switch, TimeInfo, initConfirm, initModel, initSwitch)

import Dict exposing (Dict)
import Draggable
import FileValue exposing (File)
import Html exposing (Html, text)
import Http
import Json.Decode as Decode
import Libs.Html.Events exposing (WheelEvent)
import Libs.Models exposing (FileContent, HtmlId, Text)
import Libs.Position exposing (Position)
import Libs.Size exposing (Size)
import Libs.Task as T
import Models.Schema exposing (ColumnRef, LayoutName, Schema, TableId)
import Models.Utils exposing (SizeChange, ZoomDelta)
import Time



-- deps = { to = { only = [ "Libs.*", "Models.*" ] } }
-- main models for app, the usual Model & Msg but also the ones not deserving their own file or not too generic


type alias Flags =
    ()


type alias Model =
    { time : TimeInfo
    , switch : Switch
    , storedSchemas : List Schema
    , schema : Maybe Schema
    , search : Search
    , newLayout : Maybe LayoutName
    , confirm : Confirm
    , sizes : Dict HtmlId Size
    , dragId : Maybe DragId
    , drag : Draggable.State DragId
    }


initModel : Model
initModel =
    { time = initTimeInfo
    , switch = initSwitch
    , storedSchemas = []
    , schema = Nothing
    , search = ""
    , newLayout = Nothing
    , confirm = initConfirm
    , sizes = Dict.empty
    , dragId = Nothing
    , drag = Draggable.init
    }


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
    | ShowTables (List TableId)
    | InitializedTable TableId Position
    | HideAllTables
    | ShowAllTables
    | HideColumn ColumnRef
    | ShowColumn ColumnRef Int
    | SortColumns TableId String
    | OnWheel WheelEvent
    | Zoom ZoomDelta
    | FitContent
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


type JsMsg
    = SchemasLoaded ( List ( String, Decode.Error ), List Schema )
    | FileRead Time.Posix File FileContent
    | SizesChanged (List SizeChange)
    | HotkeyUsed String
    | Error Decode.Error


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


type alias Confirm =
    { content : Html Msg, cmd : Cmd Msg }


initConfirm : Confirm
initConfirm =
    { content = text "No text", cmd = T.send Noop }


type alias Error =
    String


type alias Errors =
    List Error


type alias Search =
    String


type alias DragId =
    HtmlId
