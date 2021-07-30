module PagesComponents.Website.Views.CtaSection exposing (viewCtaSection)

import Html exposing (Html, a, div, h2, span, text)
import Html.Attributes as Attr
import Gen.Route as Route

documentationLink: String
documentationLink = "https://github.com/loicknuchel/schema-viz"
viewCtaSection : Html msg
viewCtaSection =
    div
        [ Attr.class "bg-white"
        ]
        [ div
            [ Attr.class "max-w-4xl mx-auto py-16 px-4 sm:px-6 sm:py-24 lg:max-w-7xl lg:px-8 lg:flex lg:items-center lg:justify-between"
            ]
            [ h2
                [ Attr.class "text-4xl font-extrabold tracking-tight text-gray-900"
                ]
                [ span
                    [ Attr.class "block"
                    ]
                    [ text "Ready to understand your SQL schema?" ]
                ]
            , div
                [ Attr.class "mt-6 space-y-4 sm:space-y-0 sm:flex sm:space-x-5"
                ]
                [ a
                    [ Attr.href documentationLink
                    , Attr.class "flex items-center justify-center bg-gradient-to-r from-purple-600 to-indigo-600 bg-origin-border px-4 py-3 border border-transparent text-base font-medium rounded-md shadow-sm text-white hover:from-purple-700 hover:to-indigo-700"
                    ]
                    [ text "Learn more" ]
                , a
                    [ Attr.href (Route.toHref Route.App)
                    , Attr.class "flex items-center justify-center px-4 py-3 border border-transparent text-base font-medium rounded-md shadow-sm text-indigo-800 bg-indigo-50 hover:bg-indigo-100"
                    ]
                    [ text "Explore your schema" ]
                ]
            ]
        ]
