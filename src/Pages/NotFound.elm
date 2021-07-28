module Pages.NotFound exposing (Model, Msg, page)

import Page
import Request exposing (Request)
import Shared
import View exposing (View)


page : Shared.Model -> Request -> Page.With Model Msg
page _ req =
    Page.sandbox
        { init = init req
        , update = update
        , view = view
        }


type alias Model =
    String


type alias Msg =
    ()


init : Request -> Model
init req =
    req.url.path |> addPrefixed "?" req.url.query |> addPrefixed "#" req.url.fragment


update : Msg -> Model -> Model
update _ model =
    model


view : Model -> View Msg
view model =
    View.placeholder ("Page not found " ++ model ++ ".")


addPrefixed : String -> Maybe String -> String -> String
addPrefixed prefix maybeSegment starter =
    case maybeSegment of
        Nothing ->
            starter

        Just segment ->
            starter ++ prefix ++ segment
