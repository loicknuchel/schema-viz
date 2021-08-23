module Components.Atoms.Button exposing (button, buttonChapter)

import Css
import ElmBook exposing (Msg)
import ElmBook.Actions exposing (logAction)
import ElmBook.Chapter exposing (..)
import ElmBook.ElmCSS exposing (Chapter)
import Html.Styled as Styled
import Html.Styled.Attributes as Attr
import Html.Styled.Events as Events
import Tailwind.Utilities as Tw


button :
    { label : String
    , disabled : Bool
    , onClick : msg
    }
    -> Styled.Html msg
button props =
    Styled.button
        [ Attr.type_ "button"
        , Attr.disabled props.disabled
        , Events.onClick props.onClick
        , Attr.css
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
            , Css.focus
                [ Tw.outline_none
                , Tw.ring_2
                , Tw.ring_offset_2
                , Tw.ring_indigo_500
                ]
            , Css.hover
                [ Tw.bg_indigo_700
                ]
            ]
        ]
        [ Styled.text props.label ]


buttonChapter : Chapter x
buttonChapter =
    let
        props : { label : String, disabled : Bool, onClick : Msg state }
        props =
            { label = "Click me!"
            , disabled = False
            , onClick = logAction "Clicked button"
            }
    in
    chapter "Buttons"
        |> renderComponentList
            [ ( "default", button { props | onClick = logAction "Clicked default button" } )
            , ( "disabled", button { props | disabled = True } )
            ]
