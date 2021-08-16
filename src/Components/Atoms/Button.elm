module Components.Atoms.Button exposing (button, buttonChapter)

import ElmBook.Actions exposing (logAction)
import ElmBook.Chapter exposing (..)
import Html exposing (Html)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)



button :
    { label : String
    , disabled : Bool
    , onClick : msg
    }
    -> Html msg
button props =
    Html.button
        [ class "px-8 py-3 rounded-md bg-indigo-500"
        , disabled props.disabled
        , onClick props.onClick
        ]
        [ Html.text props.label ]



-- TODO Comprendre le x après Chapter


buttonChapter : Chapter x
buttonChapter =
    let
        props =
            { label = "Click me!"
            , disabled = False
            , onClick = logAction "Clicked button 2!"
            }
    in
    chapter "Buttons"
        |> renderComponentList
            [ ( "Default", button props )
            , ( "Disabled", button { props | disabled = True } )
            ]
