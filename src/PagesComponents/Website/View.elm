module PagesComponents.Website.View exposing (..)

import Css.Global
import FontAwesome.Styles as Icon
import Html exposing (Html)
import Html.Attributes exposing (..)
import Html.Styled as SHtml
import PagesComponents.Website.Views.HeaderSection exposing (viewHeader)


viewWebsite : List (Html msg)
viewWebsite =
    [ Icon.css ]
        ++ [ viewHeader ]
