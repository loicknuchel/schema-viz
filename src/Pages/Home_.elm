module Pages.Home_ exposing (Model, Msg, page)

import Gen.Params.Home_ exposing (Params)
import Page exposing (Page)
import PagesComponents.Home_.View exposing (viewWebsite)
import Ports exposing (trackPage)
import Request exposing (Request)
import Shared
import View exposing (View)


page : Shared.Model -> Request.With Params -> Page.With Model msg
page _ _ =
    Page.element
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }


type alias Model =
    ()


type alias Msg =
    ()


init : ( Model, Cmd msg )
init =
    ( (), trackPage "home" )


update : msg -> Model -> ( Model, Cmd msg )
update _ model =
    ( model, Cmd.none )


view : Model -> View msg
view _ =
    { title = "Schema Viz"
    , body = viewWebsite
    }


subscriptions : Model -> Sub msg
subscriptions _ =
    Sub.none
