module Commands.FetchData exposing (loadData)

import Http
import JsonFormats.SchemaDecoder exposing (JsonSchema, JsonTable, schemaDecoder)
import Libs.Std exposing (listZipWith)
import Models exposing (Msg(..))
import Models.Schema exposing (SchemaName(..), TableId(..), TableName(..))



-- load external data needed by the app, should have the least possible behaviors, just pack everything in a Msg


loadData : String -> Cmd Msg
loadData url =
    Http.get { url = url, expect = Http.expectJson buildMsg schemaDecoder }



-- data transformations


buildMsg : Result Http.Error JsonSchema -> Msg
buildMsg result =
    GotData (result |> Result.map (\schema -> schema.tables |> listZipWith buildTableId))


buildTableId : JsonTable -> TableId
buildTableId table =
    TableId (SchemaName table.schema) (TableName table.table)
