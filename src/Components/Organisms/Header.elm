module Components.Organisms.Header exposing (headerSlice, headerChapter)

import ElmBook.Chapter exposing (..)
import ElmBook.ElmCSS exposing (Chapter)
import Gen.Route as Route
import Html.Styled exposing (Html, a, div, header, img, span, text)
import Html.Styled.Attributes exposing (alt, css, href, src)
import Tailwind.Breakpoints as Bp
import Tailwind.Utilities as Tw


headerSlice : String -> Html msg
headerSlice url =
    header
        []
        [ div
            [ css
                [ Tw.relative
                , Tw.bg_white
                ]
            ]
            [ div
                [ css
                    [ Tw.flex
                    , Tw.justify_between
                    , Tw.items_center
                    , Tw.max_w_7xl
                    , Tw.mx_auto
                    , Tw.px_4
                    , Tw.py_6
                    , Bp.lg
                        [ Tw.px_8
                        ]
                    , Bp.md
                        [ Tw.justify_start
                        , Tw.space_x_10
                        ]
                    , Bp.sm
                        [ Tw.px_6
                        ]
                    ]
                ]
                [ div
                    [ css
                        [ Tw.flex
                        , Tw.justify_start
                        , Bp.lg
                            [ Tw.w_0
                            , Tw.flex_1
                            ]
                        ]
                    ]
                    [ a
                        [ href (Route.toHref Route.Home_)
                        ]
                        [ span
                            [ css
                                [ Tw.sr_only
                                ]
                            ]
                            [ text "Schema Viz" ]
                        , img
                            [ css
                                [ Tw.h_8
                                , Tw.w_auto
                                , Bp.sm
                                    [ Tw.h_10
                                    ]
                                ]
                            , src url
                            , alt "Schema Viz"
                            ]
                            []
                        ]
                    ]
                ]
            ]
        ]


headerChapter : Chapter x
headerChapter =
    chapter "Slices.Header"
        |> renderComponentList
            [ ( "default", headerSlice "http://localhost:4000/assets/azimutt_logo.png")
            ]
