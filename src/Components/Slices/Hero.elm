module Components.Slices.Hero exposing (..)

import Components.Organisms.Header exposing (headerSlice)
import Css
import ElmBook.Chapter exposing (..)
import ElmBook.ElmCSS exposing (Chapter)
import Gen.Route as Route
import Html.Styled exposing (Html, a, button, div, h1, img, main_, nav, p, span, text)
import Html.Styled.Attributes as Attr exposing (alt, css, href, src)
import Svg.Styled as Svg exposing (path, svg)
import Svg.Styled.Attributes as SvgAttr
import Tailwind.Breakpoints as Bp
import Tailwind.Utilities as Tw


heroSlice =
    div []
        [ headerSlice "./assets/azimutt_logo.png"
        , div
            [ css
                [ Tw.relative
                ]
            ]
            [ div
                [ css
                    [ Tw.absolute
                    , Tw.inset_x_0
                    , Tw.bottom_0
                    , Tw.h_1over2
                    ]
                ]
                []
            , div
                [ css
                    [ Tw.max_w_7xl
                    , Tw.mx_auto
                    , Bp.lg
                        [ Tw.px_8
                        ]
                    , Bp.sm
                        [ Tw.px_6
                        ]
                    ]
                ]
                [ div
                    [ css
                        [ Tw.relative
                        , Tw.shadow_xl
                        , Bp.sm
                            [ Tw.rounded_2xl
                            , Tw.overflow_hidden
                            ]
                        ]
                    ]
                    [ div
                        [ css
                            [ Tw.absolute
                            , Tw.inset_0
                            ]
                        ]
                        [ img
                            [ css
                                [ Tw.h_full
                                , Tw.w_full
                                , Tw.object_cover
                                ]
                            , src "https://images.unsplash.com/photo-1521737852567-6949f3f9f2b5?ixid=MXwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHw%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=2830&q=80&sat=-100"
                            , alt "People working on laptops"
                            ]
                            []
                        , div
                            [ css
                                [ Tw.absolute
                                , Tw.inset_0
                                , Tw.bg_gradient_to_r
                                , Tw.from_green_200
                                , Tw.to_indigo_700
                                , Tw.mix_blend_multiply
                                ]
                            ]
                            []
                        ]
                    , div
                        [ css
                            [ Tw.relative
                            , Tw.px_4
                            , Tw.py_16
                            , Bp.lg
                                [ Tw.py_32
                                , Tw.px_8
                                ]
                            , Bp.sm
                                [ Tw.px_6
                                , Tw.py_24
                                ]
                            ]
                        ]
                        [ h1
                            [ css
                                [ Tw.text_center
                                , Tw.text_4xl
                                , Tw.font_extrabold
                                , Tw.tracking_tight
                                , Bp.lg
                                    [ Tw.text_6xl
                                    ]
                                , Bp.sm
                                    [ Tw.text_5xl
                                    ]
                                ]
                            ]
                            [ span
                                [ css
                                    [ Tw.block
                                    , Tw.text_white
                                    ]
                                ]
                                [ text "azimutt.app" ]
                            ]
                        , p
                            [ css
                                [ Tw.mt_6
                                , Tw.max_w_lg
                                , Tw.mx_auto
                                , Tw.text_center
                                , Tw.text_xl
                                , Tw.text_indigo_200
                                , Bp.sm
                                    [ Tw.max_w_3xl
                                    ]
                                ]
                            ]
                            [ text "Explore and understand your SQL schema" ]
                        , div
                            [ css
                                [ Tw.mt_10
                                , Tw.max_w_sm
                                , Tw.mx_auto
                                , Bp.sm
                                    [ Tw.max_w_none
                                    , Tw.flex
                                    , Tw.justify_center
                                    ]
                                ]
                            ]
                            [ div
                                [ css
                                    [ Tw.space_y_4
                                    , Bp.sm
                                        [ Tw.space_y_0
                                        , Tw.mx_auto
                                        , Tw.inline_grid
                                        , Tw.grid_cols_1
                                        , Tw.gap_5
                                        ]
                                    ]
                                ]
                                [ a
                                    [ href (Route.toHref Route.App)
                                    , css
                                        [ Tw.flex
                                        , Tw.items_center
                                        , Tw.justify_center
                                        , Tw.px_4
                                        , Tw.py_3
                                        , Tw.border
                                        , Tw.border_transparent
                                        , Tw.text_base
                                        , Tw.font_medium
                                        , Tw.rounded_md
                                        , Tw.shadow_sm
                                        , Tw.text_indigo_700
                                        , Tw.bg_white
                                        , Css.hover
                                            [ Tw.bg_indigo_50
                                            ]
                                        , Bp.sm
                                            [ Tw.px_8
                                            ]
                                        ]
                                    ]
                                    [ text "Explore your schema" ]
                                ]
                            ]
                        ]
                    ]
                ]
            ]
        ]


heroSimpleSlice =
    div
        [ css
            [ Tw.relative
            , Tw.bg_gray_50
            , Tw.overflow_hidden
            ]
        ]
        [ div
            [ css
                [ Tw.hidden
                , Bp.sm
                    [ Tw.block
                    , Tw.absolute
                    , Tw.inset_y_0
                    , Tw.h_full
                    , Tw.w_full
                    ]
                ]
            , Attr.attribute "aria-hidden" "true"
            ]
            [ div
                [ css
                    [ Tw.relative
                    , Tw.h_full
                    , Tw.max_w_7xl
                    , Tw.mx_auto
                    ]
                ]
                [ svg
                    [ SvgAttr.css
                        [ Tw.absolute
                        , Tw.right_full
                        , Tw.transform
                        , Tw.translate_y_1over4
                        , Tw.translate_x_1over4
                        , Bp.lg
                            [ Tw.translate_x_1over2
                            ]
                        ]
                    , SvgAttr.width "404"
                    , SvgAttr.height "784"
                    , SvgAttr.fill "none"
                    , SvgAttr.viewBox "0 0 404 784"
                    ]
                    [ Svg.defs []
                        [ Svg.pattern
                            [ SvgAttr.id "f210dbf6-a58d-4871-961e-36d5016a0f49"
                            , SvgAttr.x "0"
                            , SvgAttr.y "0"
                            , SvgAttr.width "20"
                            , SvgAttr.height "20"
                            , SvgAttr.patternUnits "userSpaceOnUse"
                            ]
                            [ Svg.rect
                                [ SvgAttr.x "0"
                                , SvgAttr.y "0"
                                , SvgAttr.width "4"
                                , SvgAttr.height "4"
                                , SvgAttr.css
                                    [ Tw.text_gray_200
                                    ]
                                , SvgAttr.fill "currentColor"
                                ]
                                []
                            ]
                        ]
                    , Svg.rect
                        [ SvgAttr.width "404"
                        , SvgAttr.height "784"
                        , SvgAttr.fill "url(#f210dbf6-a58d-4871-961e-36d5016a0f49)"
                        ]
                        []
                    ]
                , svg
                    [ SvgAttr.css
                        [ Tw.absolute
                        , Tw.left_full
                        , Tw.transform
                        , Tw.neg_translate_y_3over4
                        , Tw.neg_translate_x_1over4
                        , Bp.lg
                            [ Tw.neg_translate_x_1over2
                            ]
                        , Bp.md
                            [ Tw.neg_translate_y_1over2
                            ]
                        ]
                    , SvgAttr.width "404"
                    , SvgAttr.height "784"
                    , SvgAttr.fill "none"
                    , SvgAttr.viewBox "0 0 404 784"
                    ]
                    [ Svg.defs []
                        [ Svg.pattern
                            [ SvgAttr.id "5d0dd344-b041-4d26-bec4-8d33ea57ec9b"
                            , SvgAttr.x "0"
                            , SvgAttr.y "0"
                            , SvgAttr.width "20"
                            , SvgAttr.height "20"
                            , SvgAttr.patternUnits "userSpaceOnUse"
                            ]
                            [ Svg.rect
                                [ SvgAttr.x "0"
                                , SvgAttr.y "0"
                                , SvgAttr.width "4"
                                , SvgAttr.height "4"
                                , SvgAttr.css
                                    [ Tw.text_gray_200
                                    ]
                                , SvgAttr.fill "currentColor"
                                ]
                                []
                            ]
                        ]
                    , Svg.rect
                        [ SvgAttr.width "404"
                        , SvgAttr.height "784"
                        , SvgAttr.fill "url(#5d0dd344-b041-4d26-bec4-8d33ea57ec9b)"
                        ]
                        []
                    ]
                ]
            ]
        , div
            [ css
                [ Tw.relative
                , Tw.pt_6
                , Tw.pb_16
                , Bp.sm
                    [ Tw.pb_24
                    ]
                ]
            ]
            [ div []
                [ div
                    [ css
                        [ Tw.max_w_7xl
                        , Tw.mx_auto
                        , Tw.px_4
                        , Bp.sm
                            [ Tw.px_6
                            ]
                        ]
                    ]
                    [ nav
                        [ css
                            [ Tw.relative
                            , Tw.flex
                            , Tw.items_center
                            , Tw.justify_between
                            , Bp.md
                                [ Tw.justify_center
                                ]
                            , Bp.sm
                                [ Tw.h_10
                                ]
                            ]
                        , Attr.attribute "aria-label" "Global"
                        ]
                        [ div
                            [ css
                                [ Tw.flex
                                , Tw.items_center
                                , Tw.flex_1
                                , Bp.md
                                    [ Tw.absolute
                                    , Tw.inset_y_0
                                    , Tw.left_0
                                    ]
                                ]
                            ]
                            [ div
                                [ css
                                    [ Tw.flex
                                    , Tw.items_center
                                    , Tw.justify_between
                                    , Tw.w_full
                                    , Bp.md
                                        [ Tw.w_auto
                                        ]
                                    ]
                                ]
                                [ a
                                    [ Attr.href "#"
                                    ]
                                    [ span
                                        [ css
                                            [ Tw.sr_only
                                            ]
                                        ]
                                        [ text "Workflow" ]
                                    , img
                                        [ css
                                            [ Tw.h_8
                                            , Tw.w_auto
                                            , Bp.sm
                                                [ Tw.h_10
                                                ]
                                            ]
                                        , Attr.src "https://tailwindui.com/img/logos/workflow-mark-indigo-600.svg"
                                        , Attr.alt ""
                                        ]
                                        []
                                    ]
                                , div
                                    [ css
                                        [ Tw.neg_mr_2
                                        , Tw.flex
                                        , Tw.items_center
                                        , Bp.md
                                            [ Tw.hidden
                                            ]
                                        ]
                                    ]
                                    [ button
                                        [ Attr.type_ "button"
                                        , css
                                            [ Tw.bg_gray_50
                                            , Tw.rounded_md
                                            , Tw.p_2
                                            , Tw.inline_flex
                                            , Tw.items_center
                                            , Tw.justify_center
                                            , Tw.text_gray_400
                                            , Css.focus
                                                [ Tw.outline_none
                                                , Tw.ring_2
                                                , Tw.ring_inset
                                                , Tw.ring_indigo_500
                                                ]
                                            , Css.hover
                                                [ Tw.text_gray_500
                                                , Tw.bg_gray_100
                                                ]
                                            ]
                                        , Attr.attribute "aria-expanded" "false"
                                        ]
                                        [ span
                                            [ css
                                                [ Tw.sr_only
                                                ]
                                            ]
                                            [ text "Open main menu" ]
                                        , {- Heroicon name: outline/menu -}
                                          svg
                                            [ SvgAttr.css
                                                [ Tw.h_6
                                                , Tw.w_6
                                                ]
                                            , SvgAttr.fill "none"
                                            , SvgAttr.viewBox "0 0 24 24"
                                            , SvgAttr.stroke "currentColor"
                                            , Attr.attribute "aria-hidden" "true"
                                            ]
                                            [ path
                                                [ SvgAttr.strokeLinecap "round"
                                                , SvgAttr.strokeLinejoin "round"
                                                , SvgAttr.strokeWidth "2"
                                                , SvgAttr.d "M4 6h16M4 12h16M4 18h16"
                                                ]
                                                []
                                            ]
                                        ]
                                    ]
                                ]
                            ]
                        , div
                            [ css
                                [ Tw.hidden
                                , Bp.md
                                    [ Tw.flex
                                    , Tw.space_x_10
                                    ]
                                ]
                            ]
                            [ a
                                [ Attr.href "#"
                                , css
                                    [ Tw.font_medium
                                    , Tw.text_gray_500
                                    , Css.hover
                                        [ Tw.text_gray_900
                                        ]
                                    ]
                                ]
                                [ text "Product" ]
                            , a
                                [ Attr.href "#"
                                , css
                                    [ Tw.font_medium
                                    , Tw.text_gray_500
                                    , Css.hover
                                        [ Tw.text_gray_900
                                        ]
                                    ]
                                ]
                                [ text "Features" ]
                            , a
                                [ Attr.href "#"
                                , css
                                    [ Tw.font_medium
                                    , Tw.text_gray_500
                                    , Css.hover
                                        [ Tw.text_gray_900
                                        ]
                                    ]
                                ]
                                [ text "Marketplace" ]
                            , a
                                [ Attr.href "#"
                                , css
                                    [ Tw.font_medium
                                    , Tw.text_gray_500
                                    , Css.hover
                                        [ Tw.text_gray_900
                                        ]
                                    ]
                                ]
                                [ text "Company" ]
                            ]
                        , div
                            [ css
                                [ Tw.hidden
                                , Bp.md
                                    [ Tw.absolute
                                    , Tw.flex
                                    , Tw.items_center
                                    , Tw.justify_end
                                    , Tw.inset_y_0
                                    , Tw.right_0
                                    ]
                                ]
                            ]
                            [ span
                                [ css
                                    [ Tw.inline_flex
                                    , Tw.rounded_md
                                    , Tw.shadow
                                    ]
                                ]
                                [ a
                                    [ Attr.href "#"
                                    , css
                                        [ Tw.inline_flex
                                        , Tw.items_center
                                        , Tw.px_4
                                        , Tw.py_2
                                        , Tw.border
                                        , Tw.border_transparent
                                        , Tw.text_base
                                        , Tw.font_medium
                                        , Tw.rounded_md
                                        , Tw.text_indigo_600
                                        , Tw.bg_white
                                        , Css.hover
                                            [ Tw.bg_gray_50
                                            ]
                                        ]
                                    ]
                                    [ text "Log in" ]
                                ]
                            ]
                        ]
                    ]
                , {-
                     Mobile menu, show/hide based on menu open state.

                     Entering: "duration-150 ease-out"
                       From: "opacity-0 scale-95"
                       To: "opacity-100 scale-100"
                     Leaving: "duration-100 ease-in"
                       From: "opacity-100 scale-100"
                       To: "opacity-0 scale-95"
                  -}
                  div
                    [ css
                        [ Tw.absolute
                        , Tw.top_0
                        , Tw.inset_x_0
                        , Tw.p_2
                        , Tw.transition
                        , Tw.transform
                        , Tw.origin_top_right
                        , Bp.md
                            [ Tw.hidden
                            ]
                        ]
                    ]
                    [ div
                        [ css
                            [ Tw.rounded_lg
                            , Tw.shadow_md
                            , Tw.bg_white
                            , Tw.ring_1
                            , Tw.ring_black
                            , Tw.ring_opacity_5
                            , Tw.overflow_hidden
                            ]
                        ]
                        [ div
                            [ css
                                [ Tw.px_5
                                , Tw.pt_4
                                , Tw.flex
                                , Tw.items_center
                                , Tw.justify_between
                                ]
                            ]
                            [ div []
                                [ img
                                    [ css
                                        [ Tw.h_8
                                        , Tw.w_auto
                                        ]
                                    , Attr.src "./assets/azimutt_logo.svg"
                                    , Attr.alt ""
                                    ]
                                    []
                                ]
                            , div
                                [ css
                                    [ Tw.neg_mr_2
                                    ]
                                ]
                                [ button
                                    [ Attr.type_ "button"
                                    , css
                                        [ Tw.bg_white
                                        , Tw.rounded_md
                                        , Tw.p_2
                                        , Tw.inline_flex
                                        , Tw.items_center
                                        , Tw.justify_center
                                        , Tw.text_gray_400
                                        , Css.focus
                                            [ Tw.outline_none
                                            , Tw.ring_2
                                            , Tw.ring_inset
                                            , Tw.ring_indigo_500
                                            ]
                                        , Css.hover
                                            [ Tw.text_gray_500
                                            , Tw.bg_gray_100
                                            ]
                                        ]
                                    ]
                                    [ span
                                        [ css
                                            [ Tw.sr_only
                                            ]
                                        ]
                                        [ text "Close menu" ]
                                    , {- Heroicon name: outline/x -}
                                      svg
                                        [ SvgAttr.css
                                            [ Tw.h_6
                                            , Tw.w_6
                                            ]
                                        , SvgAttr.fill "none"
                                        , SvgAttr.viewBox "0 0 24 24"
                                        , SvgAttr.stroke "currentColor"
                                        , Attr.attribute "aria-hidden" "true"
                                        ]
                                        [ path
                                            [ SvgAttr.strokeLinecap "round"
                                            , SvgAttr.strokeLinejoin "round"
                                            , SvgAttr.strokeWidth "2"
                                            , SvgAttr.d "M6 18L18 6M6 6l12 12"
                                            ]
                                            []
                                        ]
                                    ]
                                ]
                            ]
                        , div
                            [ css
                                [ Tw.px_2
                                , Tw.pt_2
                                , Tw.pb_3
                                ]
                            ]
                            [ a
                                [ Attr.href "#"
                                , css
                                    [ Tw.block
                                    , Tw.px_3
                                    , Tw.py_2
                                    , Tw.rounded_md
                                    , Tw.text_base
                                    , Tw.font_medium
                                    , Tw.text_gray_700
                                    , Css.hover
                                        [ Tw.text_gray_900
                                        , Tw.bg_gray_50
                                        ]
                                    ]
                                ]
                                [ text "Product" ]
                            , a
                                [ Attr.href "#"
                                , css
                                    [ Tw.block
                                    , Tw.px_3
                                    , Tw.py_2
                                    , Tw.rounded_md
                                    , Tw.text_base
                                    , Tw.font_medium
                                    , Tw.text_gray_700
                                    , Css.hover
                                        [ Tw.text_gray_900
                                        , Tw.bg_gray_50
                                        ]
                                    ]
                                ]
                                [ text "Features" ]
                            , a
                                [ Attr.href "#"
                                , css
                                    [ Tw.block
                                    , Tw.px_3
                                    , Tw.py_2
                                    , Tw.rounded_md
                                    , Tw.text_base
                                    , Tw.font_medium
                                    , Tw.text_gray_700
                                    , Css.hover
                                        [ Tw.text_gray_900
                                        , Tw.bg_gray_50
                                        ]
                                    ]
                                ]
                                [ text "Marketplace" ]
                            , a
                                [ Attr.href "#"
                                , css
                                    [ Tw.block
                                    , Tw.px_3
                                    , Tw.py_2
                                    , Tw.rounded_md
                                    , Tw.text_base
                                    , Tw.font_medium
                                    , Tw.text_gray_700
                                    , Css.hover
                                        [ Tw.text_gray_900
                                        , Tw.bg_gray_50
                                        ]
                                    ]
                                ]
                                [ text "Company" ]
                            ]
                        , a
                            [ Attr.href "#"
                            , css
                                [ Tw.block
                                , Tw.w_full
                                , Tw.px_5
                                , Tw.py_3
                                , Tw.text_center
                                , Tw.font_medium
                                , Tw.text_indigo_600
                                , Tw.bg_gray_50
                                , Css.hover
                                    [ Tw.bg_gray_100
                                    ]
                                ]
                            ]
                            [ text "Log in" ]
                        ]
                    ]
                ]
            , main_
                [ css
                    [ Tw.mt_16
                    , Tw.mx_auto
                    , Tw.max_w_7xl
                    , Tw.px_4
                    , Bp.sm
                        [ Tw.mt_24
                        ]
                    ]
                ]
                [ div
                    [ css
                        [ Tw.text_center
                        ]
                    ]
                    [ h1
                        [ css
                            [ Tw.text_4xl
                            , Tw.tracking_tight
                            , Tw.font_extrabold
                            , Tw.text_gray_900
                            , Bp.md
                                [ Tw.text_6xl
                                ]
                            , Bp.sm
                                [ Tw.text_5xl
                                ]
                            ]
                        ]
                        [ span
                            [ css
                                [ Tw.block
                                , Bp.xl
                                    [ Tw.inline
                                    ]
                                ]
                            ]
                            [ text "Data to enrich your" ]
                        , span
                            [ css
                                [ Tw.block
                                , Tw.text_indigo_600
                                , Bp.xl
                                    [ Tw.inline
                                    ]
                                ]
                            ]
                            [ text "online business" ]
                        ]
                    , p
                        [ css
                            [ Tw.mt_3
                            , Tw.max_w_md
                            , Tw.mx_auto
                            , Tw.text_base
                            , Tw.text_gray_500
                            , Bp.md
                                [ Tw.mt_5
                                , Tw.text_xl
                                , Tw.max_w_3xl
                                ]
                            , Bp.sm
                                [ Tw.text_lg
                                ]
                            ]
                        ]
                        [ text "Anim aute id magna aliqua ad ad non deserunt sunt. Qui irure qui lorem cupidatat commodo. Elit sunt amet fugiat veniam occaecat fugiat aliqua." ]
                    , div
                        [ css
                            [ Tw.mt_5
                            , Tw.max_w_md
                            , Tw.mx_auto
                            , Bp.md
                                [ Tw.mt_8
                                ]
                            , Bp.sm
                                [ Tw.flex
                                , Tw.justify_center
                                ]
                            ]
                        ]
                        [ div
                            [ css
                                [ Tw.rounded_md
                                , Tw.shadow
                                ]
                            ]
                            [ a
                                [ Attr.href "#"
                                , css
                                    [ Tw.w_full
                                    , Tw.flex
                                    , Tw.items_center
                                    , Tw.justify_center
                                    , Tw.px_8
                                    , Tw.py_3
                                    , Tw.border
                                    , Tw.border_transparent
                                    , Tw.text_base
                                    , Tw.font_medium
                                    , Tw.rounded_md
                                    , Tw.text_white
                                    , Tw.bg_indigo_600
                                    , Css.hover
                                        [ Tw.bg_indigo_700
                                        ]
                                    , Bp.md
                                        [ Tw.py_4
                                        , Tw.text_lg
                                        , Tw.px_10
                                        ]
                                    ]
                                ]
                                [ text "Get started" ]
                            ]
                        , div
                            [ css
                                [ Tw.mt_3
                                , Tw.rounded_md
                                , Tw.shadow
                                , Bp.sm
                                    [ Tw.mt_0
                                    , Tw.ml_3
                                    ]
                                ]
                            ]
                            [ a
                                [ Attr.href "#"
                                , css
                                    [ Tw.w_full
                                    , Tw.flex
                                    , Tw.items_center
                                    , Tw.justify_center
                                    , Tw.px_8
                                    , Tw.py_3
                                    , Tw.border
                                    , Tw.border_transparent
                                    , Tw.text_base
                                    , Tw.font_medium
                                    , Tw.rounded_md
                                    , Tw.text_indigo_600
                                    , Tw.bg_white
                                    , Css.hover
                                        [ Tw.bg_gray_50
                                        ]
                                    , Bp.md
                                        [ Tw.py_4
                                        , Tw.text_lg
                                        , Tw.px_10
                                        ]
                                    ]
                                ]
                                [ text "Live demo" ]
                            ]
                        ]
                    ]
                ]
            ]
        ]


heroChapter : Chapter x
heroChapter =
    chapter "Slices.Hero"
        |> renderComponentList
            [ ( "withImage",  heroSlice )
            , ( "simple",  heroSimpleSlice )
            ]
