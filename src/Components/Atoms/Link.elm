module Components.Atoms.Link exposing (firstChapter, linkButton)

import Components.Reset exposing (resetCSS)
import Css
import ElmBook.Actions exposing (logAction)
import ElmBook.Chapter exposing (..)
import ElmBook.ElmCSS exposing (Book, Chapter, book)
import Html.Styled exposing (Html, a, div, text)
import Html.Styled.Attributes as Attr
import Html.Styled.Events exposing (onClick)
import Tailwind.Breakpoints as Breakpoints
import Tailwind.Utilities as Tw


firstChapter : Chapter x
firstChapter =
    let
        href =
            "http://#"

        props =
            { label = "Click me!"
            , url = href
            }
    in
    chapter "Links"
        |> renderComponentList
            [ ( "Default", resetCSS (linkButton props) )
            ]


linkButton :
    { label : String
    , url : String
    }
    -> Html msg
linkButton props =
    div []
        [ -- This will give us the standard tailwind style-reset as well as the fonts
         div
            [ Attr.css
                [ Tw.mt_8
                , Tw.flex

                -- We use breakpoints like this
                -- However, you need to order your breakpoints from high to low :/
                , Breakpoints.lg [ Tw.mt_0, Tw.flex_shrink_0 ]
                ]
            ]
            [ div [ Attr.css [ Tw.inline_flex, Tw.rounded_md, Tw.shadow ] ]
                [ a
                    [ Attr.css
                        [ Tw.inline_flex
                        , Tw.items_center
                        , Tw.justify_center
                        , Tw.px_5
                        , Tw.py_3
                        , Tw.border
                        , Tw.border_transparent
                        , Tw.text_base
                        , Tw.font_medium
                        , Tw.rounded_md
                        , Tw.text_white
                        , Tw.bg_indigo_600

                        -- We can use hover styles via elm-css :)
                        , Css.hover [ Tw.bg_indigo_700 ]
                        ]
                    , Attr.href props.url
                    ]
                    [ text props.label ]
                ]
            ]
        ]
