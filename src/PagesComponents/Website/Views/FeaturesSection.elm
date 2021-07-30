module PagesComponents.Website.Views.FeaturesSection exposing (viewFeaturesSection)

import Gen.Route as Route
import Html exposing (Html, a, blockquote, div, footer, h2, img, p, text)
import Html.Attributes as Attr


viewFeaturesSection : Html msg
viewFeaturesSection =
    div
        [ Attr.class "relative pt-16 pb-32 overflow-hidden"
        ]
        [ div
            [ Attr.attribute "aria-hidden" "true"
            , Attr.class "absolute inset-x-0 top-0 h-48 bg-gradient-to-b from-gray-100"
            ]
            []
        , div
            [ Attr.class "relative"
            ]
            [ div
                [ Attr.class "lg:mx-auto lg:max-w-7xl lg:px-8 lg:grid lg:grid-cols-2 lg:grid-flow-col-dense lg:gap-24"
                ]
                [ div
                    [ Attr.class "px-4 max-w-xl mx-auto sm:px-6 lg:py-16 lg:max-w-none lg:mx-0 lg:px-0"
                    ]
                    [ div []
                        [ div
                            [ Attr.class "mt-6"
                            ]
                            [ h2
                                [ Attr.class "text-3xl font-extrabold tracking-tight text-gray-900"
                                ]
                                [ text "See the big picture" ]
                            , p
                                [ Attr.class "mt-4 text-lg text-gray-500"
                                ]
                                [ text "Easily visualize your database schema and see how everything fits together. Having a living document of your app schema helps when architecting a new feature or onboarding a new team member." ]
                            , div
                                [ Attr.class "mt-6"
                                ]
                                [ a
                                    [ Attr.href (Route.toHref Route.App)
                                    , Attr.class "inline-flex bg-gradient-to-r from-purple-600 to-indigo-600 bg-origin-border px-4 py-2 border border-transparent text-base font-medium rounded-md shadow-sm text-white hover:from-purple-700 hover:to-indigo-700"
                                    ]
                                    [ text "Get started" ]
                                ]
                            ]
                        ]
                    , div
                        [ Attr.class "mt-8 border-t border-gray-200 pt-6"
                        ]
                        [ blockquote []
                            [ div []
                                [ p
                                    [ Attr.class "text-base text-gray-500"
                                    ]
                                    [ text "“Cras velit quis eros eget rhoncus lacus ultrices sed diam. Sit orci risus aenean curabitur donec aliquet. Mi venenatis in euismod ut.”" ]
                                ]
                            , footer
                                [ Attr.class "mt-3"
                                ]
                                [ div
                                    [ Attr.class "flex items-center space-x-3"
                                    ]
                                    [ div
                                        [ Attr.class "flex-shrink-0"
                                        ]
                                        [ img
                                            [ Attr.class "h-6 w-6 rounded-full"
                                            , Attr.src "https://loicknuchel.fr/assets/img/bg_header.jpg"
                                            , Attr.alt "Screenshoot of the app screen"
                                            ]
                                            []
                                        ]
                                    , div
                                        [ Attr.class "text-base font-medium text-gray-700"
                                        ]
                                        [ text "Loic Knuchel, Engineer Director @ Doctolib" ]
                                    ]
                                ]
                            ]
                        ]
                    ]
                , div
                    [ Attr.class "mt-12 sm:mt-16 lg:mt-0"
                    ]
                    [ div
                        [ Attr.class "pl-4 -mr-48 sm:pl-6 md:-mr-16 lg:px-0 lg:m-0 lg:relative lg:h-full"
                        ]
                        [ img
                            [ Attr.class "w-full rounded-xl shadow-xl ring-1 ring-black ring-opacity-5 lg:absolute lg:left-0 lg:h-full lg:w-auto lg:max-w-none"
                            , Attr.src "/assets/schema-viz-screenshot.png"
                            , Attr.alt "Inbox user interface"
                            ]
                            []
                        ]
                    ]
                ]
            ]
        ]
