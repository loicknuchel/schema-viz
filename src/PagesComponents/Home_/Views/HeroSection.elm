module PagesComponents.Home_.Views.HeroSection exposing (viewHeroSection)

import Gen.Route as Route
import Html exposing (Html, a, div, h1, img, p, span, text)
import Html.Attributes exposing (alt, class, href, src)


viewHeroSection : Html msg
viewHeroSection =
    div [ class "relative" ]
        [ div [ class "absolute inset-x-0 bottom-0 h-1/2 bg-gray-100" ] []
        , div [ class "max-w-7xl mx-auto sm:px-6 lg:px-8" ]
            [ div [ class "relative shadow-xl sm:rounded-2xl sm:overflow-hidden" ]
                [ div [ class "absolute inset-0" ]
                    [ img [ class "h-full w-full object-cover", src "https://images.unsplash.com/photo-1521737852567-6949f3f9f2b5?ixid=MXwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHw%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=2830&q=80&sat=-100", alt "People working on laptops" ] []
                    , div [ class "absolute inset-0 bg-gradient-to-r from-purple-800 to-indigo-700 mix-blend-multiply" ] []
                    ]
                , div [ class "relative px-4 py-16 sm:px-6 sm:py-24 lg:py-32 lg:px-8" ]
                    [ h1 [ class "text-center text-4xl font-extrabold tracking-tight sm:text-5xl lg:text-6xl" ]
                        [ span [ class "block text-white" ] [ text "Schema Viz" ] ]
                    , p [ class "mt-6 max-w-lg mx-auto text-center text-xl text-indigo-200 sm:max-w-3xl" ] [ text "Explore and understand your SQL schema" ]
                    , div [ class "mt-10 max-w-sm mx-auto sm:max-w-none sm:flex sm:justify-center" ]
                        [ div [ class "space-y-4 sm:space-y-0 sm:mx-auto sm:inline-grid sm:grid-cols-1 sm:gap-5" ]
                            [ a [ href (Route.toHref Route.App), class "flex items-center justify-center px-4 py-3 border border-transparent text-base font-medium rounded-md shadow-sm text-indigo-700 bg-white hover:bg-indigo-50 sm:px-8" ]
                                [ text "Explore your schema" ]
                            ]
                        ]
                    ]
                ]
            ]
        ]
