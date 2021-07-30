module PagesComponents.Website.Views.LogoCloudSection exposing (viewLogoCloudSection)

import Html exposing (Html, div, img, p, text)
import Html.Attributes as Attr


viewLogoCloudSection : Html msg
viewLogoCloudSection =
    div
        [ Attr.class "bg-gray-100"
        ]
        [ div
            [ Attr.class "max-w-7xl mx-auto py-16 px-4 sm:px-6 lg:px-8"
            ]
            [ p
                [ Attr.class "text-center text-sm font-semibold uppercase text-gray-500 tracking-wide"
                ]
                [ text "Trusted by over 5 very average small businesses" ]
            , div
                [ Attr.class "mt-6 grid grid-cols-2 gap-8 md:grid-cols-6 lg:grid-cols-5"
                ]
                [ div
                    [ Attr.class "col-span-1 flex justify-center md:col-span-2 lg:col-span-1"
                    ]
                    [ img
                        [ Attr.class "h-12"
                        , Attr.src "https://tailwindui.com/img/logos/tuple-logo-gray-400.svg"
                        , Attr.alt "Tuple"
                        ]
                        []
                    ]
                , div
                    [ Attr.class "col-span-1 flex justify-center md:col-span-2 lg:col-span-1"
                    ]
                    [ img
                        [ Attr.class "h-12"
                        , Attr.src "https://tailwindui.com/img/logos/mirage-logo-gray-400.svg"
                        , Attr.alt "Mirage"
                        ]
                        []
                    ]
                , div
                    [ Attr.class "col-span-1 flex justify-center md:col-span-2 lg:col-span-1"
                    ]
                    [ img
                        [ Attr.class "h-12"
                        , Attr.src "https://tailwindui.com/img/logos/statickit-logo-gray-400.svg"
                        , Attr.alt "StaticKit"
                        ]
                        []
                    ]
                , div
                    [ Attr.class "col-span-1 flex justify-center md:col-span-2 md:col-start-2 lg:col-span-1"
                    ]
                    [ img
                        [ Attr.class "h-12"
                        , Attr.src "https://tailwindui.com/img/logos/transistor-logo-gray-400.svg"
                        , Attr.alt "Transistor"
                        ]
                        []
                    ]
                , div
                    [ Attr.class "col-span-2 flex justify-center md:col-span-2 md:col-start-4 lg:col-span-1"
                    ]
                    [ img
                        [ Attr.class "h-12"
                        , Attr.src "https://tailwindui.com/img/logos/workcation-logo-gray-400.svg"
                        , Attr.alt "Workcation"
                        ]
                        []
                    ]
                ]
            ]
        ]
