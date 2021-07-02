port module Ports exposing (activateTooltipsAndPopovers, fileRead, observeSize, observeTableSize, observeTablesSize, readFile, sizesReceiver)

import FileValue exposing (File)
import Json.Decode as Decode
import Json.Encode as Encode
import Models exposing (SizeChange)
import Models.Schema exposing (TableId)
import Time
import Views.Helpers exposing (formatTableId)


port activateTooltipsAndPopovers : () -> Cmd msg


port observeSizes : List String -> Cmd msg


port sizesReceiver : (List SizeChange -> msg) -> Sub msg


observeSize : String -> Cmd msg
observeSize id =
    observeSizes [ id ]


observeTableSize : TableId -> Cmd msg
observeTableSize id =
    observeSizes [ formatTableId id ]


observeTablesSize : List TableId -> Cmd msg
observeTablesSize ids =
    observeSizes (List.map formatTableId ids)


port readTextFile : Decode.Value -> Cmd msg


port textFileRead : (( Decode.Value, String ) -> msg) -> Sub msg


readFile : File -> Cmd msg
readFile file =
    readTextFile (FileValue.encode file)


fileRead : (( File, String ) -> msg) -> Sub msg
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
