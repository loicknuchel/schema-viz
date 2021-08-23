module PagesComponents.Home_.Views.FooterSection exposing (viewFooterSection)

import Html exposing (Html, a, div, footer, h2, p, span, text)
import Html.Attributes exposing (class, href, id)
import Libs.Html.Attributes exposing (ariaLabelledBy)
import Components.Atoms.SvgIcon as SvgIcon


twitterLink : String
twitterLink =
    "https://twitter.com/loicknuchel"


githubLink : String
githubLink =
    "https://github.com/loicknuchel/schema-viz"


viewFooterSection : Html msg
viewFooterSection =
    div []
        [ 
        ]
