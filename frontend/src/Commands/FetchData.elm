module Commands.FetchData exposing (loadData)

import Http
import JsonFormats.SchemaDecoder exposing (schemaDecoder)
import Models exposing (Msg(..))



-- load external data needed by the app, should have the least possible behaviors, just pack everything in a Msg


loadData : String -> Cmd Msg
loadData url =
    Http.get { url = url, expect = Http.expectJson GotData schemaDecoder }
