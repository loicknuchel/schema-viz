port module Ports exposing (JsMsg(..), activateTooltipsAndPopovers, click, dropSchema, hideModal, hideOffcanvas, loadSchemas, observeSize, observeTableSize, observeTablesSize, onJsMessage, readFile, saveSchema, showModal, toastError, toastInfo)

import FileValue exposing (File)
import Json.Decode as Decode exposing (Decoder, Value)
import Json.Encode as Encode
import JsonFormats.SchemaFormat exposing (decodeSchema, decodeSize, encodeSchema)
import Libs.Json.Decode as D
import Libs.List as L
import Models.Schema exposing (Schema, TableId, formatTableId)
import Models.Utils exposing (FileContent, HtmlId, SizeChange, Text)
import Time


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
    observeSizes [ formatTableId id ]


observeTablesSize : List TableId -> Cmd msg
observeTablesSize ids =
    observeSizes (List.map formatTableId ids)


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


type alias Toast =
    { kind : String, message : Text }


type JsMsg
    = SchemasLoaded ( List ( String, Decode.Error ), List Schema )
    | FileRead Time.Posix File FileContent
    | SizesChanged (List SizeChange)
    | Error Decode.Error


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


toastEncoder : Toast -> Value
toastEncoder toast =
    Encode.object [ ( "kind", toast.kind |> Encode.string ), ( "message", toast.message |> Encode.string ) ]


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

                    other ->
                        Decode.fail ("Not supported kind of JsMsg '" ++ other ++ "'")
            )


schemasDecoder : Decoder ( List ( String, Decode.Error ), List Schema )
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
