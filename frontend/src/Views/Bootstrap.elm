module Views.Bootstrap exposing (BsColor(..), bsButton, bsButtonGroup, bsDropdown)

import Html exposing (Attribute, Html, div)
import Html.Attributes exposing (attribute, class, id)


type BsColor
    = Primary
    | Secondary
    | Success
    | Info
    | Warning
    | Danger
    | Light
    | Dark


bsDropdown : String -> (List (Attribute msg) -> Html msg) -> (List (Attribute msg) -> Html msg) -> Html msg
bsDropdown dropdownId toggleElement dropdownContent =
    -- TODO find a nice way to give the "dropdown-menu-end" option
    div [ class "dropdown" ]
        [ toggleElement [ attribute "data-bs-toggle" "dropdown", id dropdownId, attribute "aria-expanded" "false" ]
        , dropdownContent [ class "dropdown-menu dropdown-menu-end", attribute "aria-labelledby" dropdownId ]
        ]


bsButton : BsColor -> List (Attribute msg) -> List (Html msg) -> Html msg
bsButton color attrs children =
    -- TODO find a nice way to give the "outline" option
    Html.button ([ attribute "type" "button", class "btn", class ("btn-outline-" ++ colorToString color) ] ++ attrs) children


bsButtonGroup : String -> List (Html msg) -> Html msg
bsButtonGroup label buttons =
    div [ class "btn-group", attribute "role" "group", attribute "aria-label" label ] buttons


colorToString : BsColor -> String
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
