module Commands.FetchData exposing (loadData)

import Decoders.SchemaDecoder exposing (JsonSchema, JsonTable, schemaDecoder)
import Http
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
    GotData (Result.map (\schema -> listZipWith buildTableId schema.tables) result)


buildTableId : JsonTable -> TableId
buildTableId table =
    TableId (SchemaName table.schema) (TableName table.table)
