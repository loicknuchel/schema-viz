module PagesComponents.App.Commands.LoadSample exposing (loadSample)

import Conf exposing (schemaSamples)
import Dict
import Http exposing (Response(..))
import PagesComponents.App.Models exposing (Msg(..))
import Ports exposing (toastError)
import Task exposing (Task)
import Time


loadSample : String -> Cmd Msg
loadSample name =
    schemaSamples
        |> Dict.get name
        |> Maybe.map (\( _, path ) -> Task.perform (\( now, body ) -> GotSampleData now name path body) (httpGet path))
        |> Maybe.withDefault (toastError ("Unable to find '" ++ name ++ "' example"))


httpGet : String -> Task Never ( Time.Posix, Result Http.Error String )
httpGet path =
    Time.now
        |> Task.andThen
            (\now ->
                Http.task
                    { method = "GET"
                    , headers = []
                    , url = path
                    , body = Http.emptyBody
                    , resolver = Http.stringResolver (\res -> Ok ( now, toResult res ))
                    , timeout = Nothing
                    }
            )


toResult : Response body -> Result Http.Error body
toResult response =
    case response of
        BadUrl_ url ->
            Err (Http.BadUrl url)

        Timeout_ ->
            Err Http.Timeout

        NetworkError_ ->
            Err Http.NetworkError

        BadStatus_ metadata _ ->
            Err (Http.BadStatus metadata.statusCode)

        GoodStatus_ _ body ->
            Ok body
