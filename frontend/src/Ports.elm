port module Ports exposing (activateTooltipsAndPopovers, click, fileRead, hideModal, hideOffcanvas, loadSchemas, observeSize, observeTableSize, observeTablesSize, readFile, saveSchema, schemasReceived, showModal, sizesReceiver, toastError, toastInfo)

import FileValue exposing (File)
import Json.Decode as Decode
import Json.Encode as Encode
import JsonFormats.SchemaFormat exposing (decodeSchema, encodeSchema)
import Libs.Std exposing (listResultCollect)
import Models exposing (SizeChange)
import Models.Schema exposing (Schema, TableId)
import Models.Utils exposing (FileContent, HtmlId, Text)
import Time
import Views.Helpers exposing (formatTableId)


port activateTooltipsAndPopovers : () -> Cmd msg


port observeSizes : List HtmlId -> Cmd msg


port sizesReceiver : (List SizeChange -> msg) -> Sub msg


observeSize : HtmlId -> Cmd msg
observeSize id =
    observeSizes [ id ]


observeTableSize : TableId -> Cmd msg
observeTableSize id =
    observeSizes [ formatTableId id ]


observeTablesSize : List TableId -> Cmd msg
observeTablesSize ids =
    observeSizes (List.map formatTableId ids)


port showModal : HtmlId -> Cmd msg


port hideModal : HtmlId -> Cmd msg


port hideOffcanvas : HtmlId -> Cmd msg


port click : HtmlId -> Cmd msg


type alias Toast =
    { kind : String, message : Text }


port showToast : Toast -> Cmd msg


toastInfo : Text -> Cmd msg
toastInfo message =
    showToast { kind = "info", message = message }


toastError : Text -> Cmd msg
toastError message =
    showToast { kind = "error", message = message }


port readTextFile : Decode.Value -> Cmd msg


port textFileRead : (( Decode.Value, FileContent ) -> msg) -> Sub msg


readFile : File -> Cmd msg
readFile file =
    readTextFile (FileValue.encode file)


fileRead : (( File, FileContent ) -> msg) -> Sub msg
fileRead callback =
    textFileRead
        (\( value, content ) ->
            callback
                ( value
                    |> Decode.decodeValue FileValue.decoder
                    |> Result.withDefault { value = Encode.null, name = "", mime = "", size = 0, lastModified = Time.millisToPosix 0 }
                , content
                )
        )


port loadSchemas : () -> Cmd msg


port schemasReceivedPort : (List ( String, Decode.Value ) -> msg) -> Sub msg


schemasReceived : (( List ( String, Decode.Error ), List Schema ) -> msg) -> Sub msg
schemasReceived callback =
    schemasReceivedPort
        (\list ->
            list
                |> List.map
                    (\( k, v ) ->
                        v
                            |> Decode.decodeValue decodeSchema
                            |> Result.mapError (\e -> ( k, e ))
                    )
                |> listResultCollect
                |> callback
        )


port saveSchemaPort : Encode.Value -> Cmd msg


saveSchema : Schema -> Cmd msg
saveSchema schema =
    saveSchemaPort (encodeSchema schema)
