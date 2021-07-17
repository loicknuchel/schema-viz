port module Ports exposing (activateTooltipsAndPopovers, click, dropSchema, hideModal, hideOffcanvas, hotkey, listenHotkeys, loadSchemas, observeSize, observeTableSize, observeTablesSize, onJsMessage, readFile, saveSchema, showModal, target, toastError, toastInfo)

import Dict exposing (Dict)
import FileValue exposing (File)
import Json.Decode as Decode exposing (Decoder, Value)
import Json.Encode as Encode
import JsonFormats.SchemaFormat exposing (decodeSchema, decodeSize, encodeSchema)
import Libs.Json.Decode as D
import Libs.Json.Encode as E
import Libs.List as L
import Libs.Models exposing (HtmlId, Text)
import Models exposing (JsMsg(..))
import Models.Schema exposing (Schema, SchemaId, TableId, tableIdAsHtmlId)
import Time



-- deps = { to = { only = [ "Libs.*", "Models.*" ] } }


click : HtmlId -> Cmd msg
click id =
    messageToJs (Click id)


showModal : HtmlId -> Cmd msg
showModal id =
    messageToJs (ShowModal id)


hideModal : HtmlId -> Cmd msg
hideModal id =
    messageToJs (HideModal id)


hideOffcanvas : HtmlId -> Cmd msg
hideOffcanvas id =
    messageToJs (HideOffcanvas id)


activateTooltipsAndPopovers : Cmd msg
activateTooltipsAndPopovers =
    messageToJs ActivateTooltipsAndPopovers


toastInfo : Text -> Cmd msg
toastInfo message =
    showToast { kind = "info", message = message }


toastError : Text -> Cmd msg
toastError message =
    showToast { kind = "error", message = message }


showToast : Toast -> Cmd msg
showToast toast =
    messageToJs (ShowToast toast)


loadSchemas : Cmd msg
loadSchemas =
    messageToJs LoadSchemas


saveSchema : Schema -> Cmd msg
saveSchema schema =
    messageToJs (SaveSchema schema)


dropSchema : Schema -> Cmd msg
dropSchema schema =
    messageToJs (DropSchema schema)


readFile : File -> Cmd msg
readFile file =
    messageToJs (ReadFile file)


observeSizes : List HtmlId -> Cmd msg
observeSizes ids =
    messageToJs (ObserveSizes ids)


observeSize : HtmlId -> Cmd msg
observeSize id =
    observeSizes [ id ]


observeTableSize : TableId -> Cmd msg
observeTableSize id =
    observeSizes [ tableIdAsHtmlId id ]


observeTablesSize : List TableId -> Cmd msg
observeTablesSize ids =
    observeSizes (List.map tableIdAsHtmlId ids)


listenHotkeys : Dict String Hotkey -> Cmd msg
listenHotkeys keys =
    messageToJs (ListenKeys keys)


type ElmMsg
    = Click HtmlId
    | ShowModal HtmlId
    | HideModal HtmlId
    | HideOffcanvas HtmlId
    | ActivateTooltipsAndPopovers
    | ShowToast Toast
    | LoadSchemas
    | SaveSchema Schema
    | DropSchema Schema
    | ReadFile File
    | ObserveSizes (List HtmlId)
    | ListenKeys (Dict String Hotkey)


type alias Toast =
    { kind : String, message : Text }


type alias Hotkey =
    { key : Maybe String, ctrl : Bool, shift : Bool, alt : Bool, meta : Bool, target : Maybe HotkeyTarget, preventDefault : Bool }


type alias HotkeyTarget =
    { id : Maybe String, class : Maybe String, tag : Maybe String }


hotkey : Hotkey
hotkey =
    { key = Nothing, ctrl = False, shift = False, alt = False, meta = False, target = Nothing, preventDefault = False }


target : HotkeyTarget
target =
    { id = Nothing, class = Nothing, tag = Nothing }


messageToJs : ElmMsg -> Cmd msg
messageToJs message =
    elmToJs (elmEncoder message)


onJsMessage : (JsMsg -> msg) -> Sub msg
onJsMessage callback =
    jsToElm
        (\value ->
            case Decode.decodeValue jsDecoder value of
                Ok message ->
                    callback message

                Err error ->
                    callback (Error error)
        )


elmEncoder : ElmMsg -> Value
elmEncoder elm =
    case elm of
        Click id ->
            Encode.object [ ( "kind", "Click" |> Encode.string ), ( "id", id |> Encode.string ) ]

        ShowModal id ->
            Encode.object [ ( "kind", "ShowModal" |> Encode.string ), ( "id", id |> Encode.string ) ]

        HideModal id ->
            Encode.object [ ( "kind", "HideModal" |> Encode.string ), ( "id", id |> Encode.string ) ]

        HideOffcanvas id ->
            Encode.object [ ( "kind", "HideOffcanvas" |> Encode.string ), ( "id", id |> Encode.string ) ]

        ActivateTooltipsAndPopovers ->
            Encode.object [ ( "kind", "ActivateTooltipsAndPopovers" |> Encode.string ) ]

        ShowToast toast ->
            Encode.object [ ( "kind", "ShowToast" |> Encode.string ), ( "toast", toast |> toastEncoder ) ]

        LoadSchemas ->
            Encode.object [ ( "kind", "LoadSchemas" |> Encode.string ) ]

        SaveSchema schema ->
            Encode.object [ ( "kind", "SaveSchema" |> Encode.string ), ( "schema", schema |> encodeSchema ) ]

        DropSchema schema ->
            Encode.object [ ( "kind", "DropSchema" |> Encode.string ), ( "schema", schema |> encodeSchema ) ]

        ReadFile file ->
            Encode.object [ ( "kind", "ReadFile" |> Encode.string ), ( "file", file |> FileValue.encode ) ]

        ObserveSizes ids ->
            Encode.object [ ( "kind", "ObserveSizes" |> Encode.string ), ( "ids", ids |> Encode.list Encode.string ) ]

        ListenKeys keys ->
            Encode.object [ ( "kind", "ListenKeys" |> Encode.string ), ( "keys", keys |> Encode.dict identity hotkeyEncoder ) ]


toastEncoder : Toast -> Value
toastEncoder toast =
    Encode.object [ ( "kind", toast.kind |> Encode.string ), ( "message", toast.message |> Encode.string ) ]


hotkeyEncoder : Hotkey -> Value
hotkeyEncoder key =
    Encode.object
        [ ( "key", key.key |> E.maybe Encode.string )
        , ( "ctrl", key.ctrl |> Encode.bool )
        , ( "shift", key.shift |> Encode.bool )
        , ( "alt", key.alt |> Encode.bool )
        , ( "meta", key.meta |> Encode.bool )
        , ( "target", key.target |> E.maybe hotkeyTargetEncoder )
        , ( "preventDefault", key.preventDefault |> Encode.bool )
        ]


hotkeyTargetEncoder : HotkeyTarget -> Value
hotkeyTargetEncoder t =
    Encode.object
        [ ( "id", t.id |> E.maybe Encode.string )
        , ( "class", t.class |> E.maybe Encode.string )
        , ( "tag", t.tag |> E.maybe Encode.string )
        ]


jsDecoder : Decoder JsMsg
jsDecoder =
    Decode.field "kind" Decode.string
        |> Decode.andThen
            (\kind ->
                case kind of
                    "SchemasLoaded" ->
                        Decode.field "schemas" schemasDecoder |> Decode.map SchemasLoaded

                    "FileRead" ->
                        Decode.map3 FileRead
                            (Decode.field "now" Decode.int |> Decode.map Time.millisToPosix)
                            (Decode.field "file" FileValue.decoder)
                            (Decode.field "content" Decode.string)

                    "SizesChanged" ->
                        Decode.field "sizes"
                            (Decode.map2 (\id size -> { id = id, size = size })
                                (Decode.field "id" Decode.string)
                                (Decode.field "size" decodeSize)
                                |> Decode.list
                            )
                            |> Decode.map SizesChanged

                    "HotkeyUsed" ->
                        Decode.field "id" Decode.string |> Decode.map HotkeyUsed

                    other ->
                        Decode.fail ("Not supported kind of JsMsg '" ++ other ++ "'")
            )


schemasDecoder : Decoder ( List ( SchemaId, Decode.Error ), List Schema )
schemasDecoder =
    Decode.list (D.tuple Decode.string Decode.value)
        |> Decode.map
            (\list ->
                list
                    |> List.map
                        (\( k, v ) ->
                            v
                                |> Decode.decodeValue (decodeSchema [])
                                |> Result.mapError (\e -> ( k, e ))
                        )
                    |> L.resultCollect
            )


port elmToJs : Value -> Cmd msg


port jsToElm : (Value -> msg) -> Sub msg
