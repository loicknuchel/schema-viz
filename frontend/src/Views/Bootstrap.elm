module Views.Bootstrap exposing (..)

import Html exposing (Attribute, Html, div)
import Html.Attributes exposing (attribute, class, id)


type Color
    = Primary
    | Secondary
    | Success
    | Info
    | Warning
    | Danger
    | Light
    | Dark


dropdown : String -> (List (Attribute msg) -> Html msg) -> (List (Attribute msg) -> Html msg) -> Html msg
dropdown dropdownId toggleElement dropdownContent =
    -- TODO find a nice way to give the "dropdown-menu-end" option
    div [ class "dropdown" ]
        [ toggleElement [ attribute "data-bs-toggle" "dropdown", id dropdownId, attribute "aria-expanded" "false" ]
        , dropdownContent [ class "dropdown-menu dropdown-menu-end", attribute "aria-labelledby" dropdownId ]
        ]


button : Color -> List (Attribute msg) -> List (Html msg) -> Html msg
button color attrs children =
    -- TODO find a nice way to give the "outline" option
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
