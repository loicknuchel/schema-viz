module Pages.Home_ exposing (page)

import Html exposing (Html)
import Page exposing (Page)
import PagesComponents.Website.View exposing (viewWebsite)
import Request exposing (Request)
import Shared
import View exposing (View)


page : Shared.Model -> Request -> Page
page shared req =
    Page.static
        { view = view
        }


view : View msg
view =
    { title = "Schema Viz"
    , body = viewWebsite
    }
