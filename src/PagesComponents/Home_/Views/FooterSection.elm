module PagesComponents.Home_.Views.FooterSection exposing (viewFooterSection)

import Html exposing (Html, a, div, footer, h2, p, span, text)
import Html.Attributes exposing (class, href, id)
import Libs.Html.Attributes exposing (ariaLabelledBy)
import PagesComponents.Home_.Views.Helpers.SvgIcon as SvgIcon


twitterLink : String
twitterLink =
    "https://twitter.com/loicknuchel"


githubLink : String
githubLink =
    "https://github.com/loicknuchel/schema-viz"


viewFooterSection : Html msg
viewFooterSection =
    div []
        [ footer [ class "bg-white", ariaLabelledBy "footer-heading" ]
            [ h2 [ id "footer-heading", class "sr-only" ] [ text "Footer" ]
            , div [ class "max-w-7xl mx-auto pt-2 pb-8 px-4 sm:px-6 lg:px-8" ]
                [ div [ class " pt-4 md:flex md:items-center md:justify-between" ]
                    [ div [ class "flex space-x-6 md:order-2" ]
                        [ a [ href twitterLink, class "text-gray-400 hover:text-gray-500" ]
                            [ span [ class "sr-only" ] [ text "Twitter" ], SvgIcon.twitter ]
                        , a [ href githubLink, class "text-gray-400 hover:text-gray-500" ]
                            [ span [ class "sr-only" ] [ text "GitHub" ], SvgIcon.github ]
                        ]
                    , p [ class "mt-8 text-base text-gray-400 md:mt-0 md:order-1" ]
                        [ text "Made and hosted in the EU 🇪🇺, build by @loicknuchel and @sbouaked" ]
                    ]
                ]
            ]
        ]
