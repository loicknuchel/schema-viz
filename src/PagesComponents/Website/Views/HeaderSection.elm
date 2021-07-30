module PagesComponents.Website.Views.HeaderSection exposing (viewHeaderSection)

import Gen.Route as Route
import Html exposing (Html, a, div, header, img, span, text)
import Html.Attributes as Attr


viewHeaderSection : Html msg
viewHeaderSection =
    header []
        [ div
            [ Attr.class "relative bg-white"
            ]
            [ div
                [ Attr.class "flex justify-between items-center max-w-7xl mx-auto px-4 py-6 sm:px-6 md:justify-start md:space-x-10 lg:px-8"
                ]
                [ div
                    [ Attr.class "flex justify-start lg:w-0 lg:flex-1"
                    ]
                    [ a
                        [ Attr.href (Route.toHref Route.Home_)
                        ]
                        [ span
                            [ Attr.class "sr-only"
                            ]
                            [ text "Schemaviz" ]
                        , img
                            [ Attr.class "h-8 w-auto sm:h-10"
                            , Attr.src "assets/logo.png"
                            , Attr.alt "Schemaviz"
                            ]
                            []
                        ]
                    ]
                ]
            ]
        ]
