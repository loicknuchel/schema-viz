module Views.Bootstrap exposing (..)

import Html exposing (Attribute, Html, div)
import Html.Attributes exposing (attribute, class)


type Color
    = Primary
    | Secondary
    | Success
    | Info
    | Warning
    | Danger
    | Light
    | Dark


button : Color -> List (Attribute msg) -> List (Html msg) -> Html msg
button color attrs children =
    Html.button ([ attribute "type" "button", class "btn", class ("btn-outline-" ++ colorToString color) ] ++ attrs) children


buttonGroup : String -> List (Html msg) -> Html msg
buttonGroup label buttons =
    div [ class "btn-group", attribute "role" "group", attribute "aria-label" label ] buttons


colorToString : Color -> String
colorToString color =
    case color of
        Primary ->
            "primary"

        Secondary ->
            "secondary"

        Success ->
            "success"

        Info ->
            "info"

        Warning ->
            "warning"

        Danger ->
            "danger"

        Light ->
            "light"

        Dark ->
            "dark"
