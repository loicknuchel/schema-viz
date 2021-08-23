module Components.Atoms.Link exposing (linkButton, linkButtonChapter)

import Css
import ElmBook.Chapter exposing (..)
import ElmBook.ElmCSS exposing (Chapter)
import Html.Styled exposing (Html, a, div, text)
import Html.Styled.Attributes as Attr
import Tailwind.Utilities as Tw


linkButtonChapter : Chapter x
linkButtonChapter =
    let
        href : String
        href =
            "#"

        props : { label : String, url : String }
        props =
            { label = "Click me!", url = href }
    in
    chapter "Links" |> renderComponentList [ ( "button Link", linkButton props ) ]


linkButton : { label : String, url : String } -> Html msg
linkButton props =
    div []
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
                    , Css.hover [ Tw.bg_indigo_700 ]
                    ]
                , Attr.href props.url
                ]
                [ text props.label ]
            ]
        ]
