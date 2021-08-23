module Components.Slices.Feature exposing (featureChapter, featureListeSlice, featureSlice)

import Components.Atoms.SvgIcon as SvgIcon
import Css
import ElmBook.Chapter exposing (..)
import ElmBook.ElmCSS exposing (Chapter)
import Gen.Route as Route
import Html.Styled exposing (Html, a, blockquote, div, footer, h2, h3, img, p, span, text)
import Html.Styled.Attributes exposing (alt, css, href, src)
import Tailwind.Breakpoints as Bp
import Tailwind.Utilities as Tw


featureSlice : Html msg
featureSlice =
    div
        [ css
            [ Tw.relative
            , Tw.pt_16
            , Tw.pb_32
            , Tw.overflow_hidden
            ]
        ]
        [ div
            [ css
                [ Bp.lg
                    [ Tw.mx_auto
                    , Tw.max_w_7xl
                    , Tw.px_8
                    , Tw.grid
                    , Tw.grid_cols_2
                    , Tw.grid_flow_col_dense
                    , Tw.gap_24
                    ]
                ]
            ]
            [ div
                [ css
                    [ Tw.px_4
                    , Tw.max_w_xl
                    , Tw.mx_auto
                    , Bp.lg
                        [ Tw.py_16
                        , Tw.max_w_none
                        , Tw.mx_0
                        , Tw.px_0
                        ]
                    , Bp.sm
                        [ Tw.px_6
                        ]
                    ]
                ]
                [ div []
                    [ div
                        [ css
                            [ Tw.mt_6
                            ]
                        ]
                        [ h2
                            [ css
                                [ Tw.text_3xl
                                , Tw.font_extrabold
                                , Tw.tracking_tight
                                , Tw.text_gray_900
                                ]
                            ]
                            [ text "See the big picture" ]
                        , p
                            [ css
                                [ Tw.mt_4
                                , Tw.text_lg
                                , Tw.text_gray_500
                                ]
                            ]
                            [ text "Easily visualize your database schema and see how everything fits together. Having a living document of your app schema helps when architecting a new feature or onboarding a new team member." ]
                        , div
                            [ css
                                [ Tw.mt_6
                                ]
                            ]
                            [ a
                                [ href (Route.toHref Route.App)
                                , css
                                    [ Tw.inline_flex
                                    , Tw.bg_gradient_to_r
                                    , Tw.from_green_600
                                    , Tw.to_indigo_700
                                    , Tw.px_4
                                    , Tw.py_2
                                    , Tw.border
                                    , Tw.border_transparent
                                    , Tw.text_base
                                    , Tw.font_medium
                                    , Tw.rounded_md
                                    , Tw.shadow_sm
                                    , Tw.text_white
                                    , Css.hover
                                        [ Tw.from_green_700
                                        , Tw.to_indigo_600
                                        , Tw.text_white
                                        ]
                                    ]
                                ]
                                [ text "Get started" ]
                            ]
                        ]
                    ]
                , div
                    [ css
                        [ Tw.mt_8
                        , Tw.border_t
                        , Tw.border_gray_200
                        , Tw.pt_6
                        ]
                    ]
                    [ blockquote []
                        [ div []
                            [ p
                                [ css
                                    [ Tw.text_base
                                    , Tw.text_gray_500
                                    ]
                                ]
                                [ text "“Being able to see only the relevant tables/columns and follow relations (incoming and outgoing) was a real game changer when working with hundreds of tables”" ]
                            ]
                        , footer
                            [ css
                                [ Tw.mt_3
                                ]
                            ]
                            [ div
                                [ css
                                    [ Tw.flex
                                    , Tw.items_center
                                    , Tw.space_x_3
                                    ]
                                ]
                                [ div
                                    [ css
                                        [ Tw.flex_shrink_0
                                        ]
                                    ]
                                    [ img
                                        [ css
                                            [ Tw.h_6
                                            , Tw.w_6
                                            , Tw.rounded_full
                                            ]
                                        , src "https://loicknuchel.fr/assets/img/bg_header.jpg"
                                        , alt "Loïc Knuchel picture"
                                        ]
                                        []
                                    ]
                                , div
                                    [ css
                                        [ Tw.text_base
                                        , Tw.font_medium
                                        , Tw.text_gray_700
                                        ]
                                    ]
                                    [ text "Loïc Knuchel, Principal Engineer @ Doctolib" ]
                                ]
                            ]
                        ]
                    ]
                ]
            , div
                [ css
                    [ Tw.mt_12
                    , Bp.lg
                        [ Tw.mt_0
                        ]
                    , Bp.sm
                        [ Tw.mt_16
                        ]
                    ]
                ]
                [ div
                    [ css
                        [ Tw.pl_4
                        , Tw.neg_mr_48
                        , Bp.lg
                            [ Tw.px_0
                            , Tw.m_0
                            , Tw.relative
                            , Tw.h_full
                            ]
                        , Bp.md
                            [ Tw.neg_mr_16
                            ]
                        , Bp.sm
                            [ Tw.pl_6
                            ]
                        ]
                    ]
                    [ span
                        []
                        [ img
                            [ css
                                [ Tw.w_full
                                , Tw.rounded_xl
                                , Tw.shadow_xl
                                , Tw.ring_1
                                , Tw.ring_black
                                , Tw.ring_opacity_5
                                , Bp.lg
                                    [ Tw.absolute
                                    , Tw.left_0
                                    , Tw.h_full
                                    , Tw.w_auto
                                    , Tw.max_w_none
                                    ]
                                ]
                            , src "/public/screenshot.png"
                            , alt "Azimutt screenshot"
                            ]
                            []
                        , img
                            [ css
                                [ Tw.w_full
                                , Tw.rounded_xl
                                , Tw.shadow_xl
                                , Tw.ring_1
                                , Tw.ring_black
                                , Tw.ring_opacity_5
                                , Bp.lg
                                    [ Tw.absolute
                                    , Tw.left_0
                                    , Tw.h_full
                                    , Tw.w_auto
                                    , Tw.max_w_none
                                    ]
                                ]
                            , src "/public/screenshot-complex.png"
                            , alt "Azimutt screenshot"
                            ]
                            []
                        ]
                    ]
                ]
            ]
        ]


featureListeSlice : Html msg
featureListeSlice =
    div
        [ css
            [ Tw.bg_gradient_to_r
            , Tw.from_green_800
            , Tw.to_indigo_700
            ]
        ]
        [ div
            [ css
                [ Tw.max_w_4xl
                , Tw.mx_auto
                , Tw.px_4
                , Tw.py_16
                , Bp.lg
                    [ Tw.max_w_7xl
                    , Tw.pt_24
                    , Tw.px_8
                    ]
                , Bp.sm
                    [ Tw.px_6
                    , Tw.pt_20
                    , Tw.pb_24
                    ]
                ]
            ]
            [ h2
                [ css
                    [ Tw.text_3xl
                    , Tw.font_extrabold
                    , Tw.text_white
                    , Tw.tracking_tight
                    ]
                ]
                [ text "Explore your SQL schema like never before" ]
            , p
                [ css
                    [ Tw.mt_4
                    , Tw.max_w_3xl
                    , Tw.text_lg
                    , Tw.text_purple_200
                    ]
                ]
                [ text "Ac tincidunt sapien vehicula erat auctor pellentesque rhoncus. Et magna sit morbi lobortis. Blandit aliquam sit nisl euismod mattis in." ]
            , div
                [ css
                    [ Tw.mt_12
                    , Tw.grid
                    , Tw.grid_cols_1
                    , Tw.gap_x_6
                    , Tw.gap_y_12
                    , Tw.text_white
                    , Bp.lg
                        [ Tw.mt_16
                        , Tw.grid_cols_3
                        , Tw.gap_x_8
                        , Tw.gap_y_16
                        ]
                    , Bp.sm
                        [ Tw.grid_cols_2
                        ]
                    ]
                ]
                [ item SvgIcon.inbox
                    "Partial display"
                    [ text """Maybe the less impressive but most useful feature when you work with a schema with 20, 40 or even 400 or 1000 tables!
                           Seeing only what you need is vital to understand how it works. This is true for tables but also for columns and relations!""" ]
                , item SvgIcon.documentSearch
                    "Search"
                    [ text """Search is awesome, don't know where to start? Just type a few words and you will have related tables and columns ranked by relevance.
                           Looking at table and column names, but also comments, keys or relations (soon).""" ]
                , item SvgIcon.photograph
                    "Layouts"
                    [ text """Your database is probably supporting many use cases, why not save them to move from one to an other ?
                           Layouts are here for that: select tables and columns related to a feature and save them as a layout. So you can easily switch between them.""" ]
                , item SvgIcon.link
                    "Relation exploration"
                    [ text """Start from a table and look at its relations to display more.
                           Outgoing, of course (foreign keys), but incoming ones also (foreign keys from other tables)!""" ]
                , item SvgIcon.link
                    "Relation search (soon)"
                    [ text """Did you ever ask how to join two tables ?
                           Azimutt can help showing all the possible path between tables. But also between a table and a column!""" ]
                , item SvgIcon.link
                    "Lorem Ipsum"
                    [ text """You came this far ??? Awesome! You seem quite interested and ready to dig in ^^
                           The best you can do now is to """, a [ href (Route.toHref Route.App) ] [ text "try it out" ], text " right away :D" ]
                ]
            ]
        ]


item : Html msg -> String -> List (Html msg) -> Html msg
item icon title description =
    div []
        [ div []
            [ span
                [ css
                    [ Tw.flex
                    , Tw.items_center
                    , Tw.justify_center
                    , Tw.h_12
                    , Tw.w_12
                    , Tw.rounded_md
                    , Tw.bg_white
                    , Tw.bg_opacity_10
                    ]
                ]
                [ icon ]
            ]
        , div
            [ css
                [ Tw.mt_6
                ]
            ]
            [ h3
                [ css
                    [ Tw.text_lg
                    , Tw.font_medium
                    , Tw.text_white
                    ]
                ]
                [ text title ]
            , p
                [ css
                    [ Tw.mt_2
                    , Tw.text_base
                    , Tw.text_purple_200
                    ]
                ]
                description
            ]
        ]


featureChapter : Chapter x
featureChapter =
    chapter "Feature"
        |> renderComponentList
            [ ( "default", featureSlice )
            , ( "list", featureListeSlice )
            ]
