module PagesComponents.Home_.Views.CtaSection exposing (viewCtaSection)

import Gen.Route as Route
import Html exposing (Html, a, div, h2, span, text)
import Html.Attributes exposing (class, href)


documentationLink : String
documentationLink =
    "https://github.com/loicknuchel/schema-viz"


viewCtaSection : Html msg
viewCtaSection =
    div [ class "bg-white" ]
        [ div [ class "max-w-4xl mx-auto py-16 px-4 sm:px-6 sm:py-24 lg:max-w-7xl lg:px-8 lg:flex lg:items-center lg:justify-between" ]
            [ h2 [ class "text-4xl font-extrabold tracking-tight text-gray-900" ]
                [ span [ class "block" ] [ text "Ready to explore your SQL schema?" ] ]
            , div [ class "mt-6 space-y-4 sm:space-y-0 sm:flex sm:space-x-5" ]
                [ a
                    [ href documentationLink
                    , class "flex items-center justify-center bg-gradient-to-r from-purple-600 to-indigo-600 bg-origin-border px-4 py-3 border border-transparent text-base font-medium rounded-md shadow-sm text-white hover:from-purple-700 hover:to-indigo-700"
                    ]
                    [ text "Learn more" ]
                , a
                    [ href (Route.toHref Route.App)
                    , class "flex items-center justify-center px-4 py-3 border border-transparent text-base font-medium rounded-md shadow-sm text-indigo-800 bg-indigo-50 hover:bg-indigo-100"
                    ]
                    [ text "Let's start!" ]
                ]
            ]
        ]
