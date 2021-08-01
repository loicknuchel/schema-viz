module PagesComponents.Home_.Views.HeaderSection exposing (viewHeaderSection)

import Gen.Route as Route
import Html exposing (Html, a, div, header, img, span, text)
import Html.Attributes exposing (alt, class, href, src)


viewHeaderSection : Html msg
viewHeaderSection =
    header []
        [ div [ class "relative bg-white" ]
            [ div [ class "flex justify-between items-center max-w-7xl mx-auto px-4 py-6 sm:px-6 md:justify-start md:space-x-10 lg:px-8" ]
                [ div [ class "flex justify-start lg:w-0 lg:flex-1" ]
                    [ a [ href (Route.toHref Route.Home_) ]
                        [ span [ class "sr-only" ] [ text "Schema Viz" ]
                        , img [ class "h-8 w-auto sm:h-10", src "assets/logo.png", alt "Schema Viz" ] []
                        ]
                    ]
                ]
            ]
        ]
