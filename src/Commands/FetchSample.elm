module Commands.FetchSample exposing (loadSample)

import AssocList as Dict
import Conf exposing (schemaSamples)
import Http
import Models exposing (Msg(..))
import Ports exposing (toastError)



-- load external data needed by the app, should have the least possible behaviors, just pack everything in a Msg


loadSample : String -> Cmd Msg
loadSample name =
    schemaSamples
        |> Dict.get name
        |> Maybe.map (\path -> Http.get { url = path, expect = Http.expectString (GotSampleData name path) })
        |> Maybe.withDefault (toastError ("Unable to find '" ++ name ++ "' example"))
