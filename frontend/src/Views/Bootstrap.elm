module Views.Bootstrap exposing (BsColor(..), Toggle(..), ariaExpanded, ariaHidden, ariaLabel, ariaLabelledBy, bsBackdrop, bsButton, bsButtonGroup, bsDismiss, bsDropdown, bsScroll, bsToggle, bsToggleCollapse, bsToggleDropdown, bsToggleModal, bsToggleOffcanvas)

import Html exposing (Attribute, Html, div)
import Html.Attributes exposing (attribute, class, id, type_)
import Libs.Std exposing (role)
import Models.Utils exposing (HtmlId, Text)


type BsColor
    = Primary
    | Secondary
    | Success
    | Info
    | Warning
    | Danger
    | Light
    | Dark


type Toggle
    = Tooltip
    | Dropdown
    | Modal
    | Collapse
    | Offcanvas


toggleName : Toggle -> String
toggleName toggle =
    case toggle of
        Tooltip ->
            "tooltip"

        Dropdown ->
            "dropdown"

        Modal ->
            "modal"

        Collapse ->
            "collapse"

        Offcanvas ->
            "offcanvas"


bsToggle : Toggle -> Attribute msg
bsToggle kind =
    attribute "data-bs-toggle" (toggleName kind)


bsDismiss : Toggle -> Attribute msg
bsDismiss kind =
    attribute "data-bs-dismiss" (toggleName kind)


bsTarget : HtmlId -> Attribute msg
bsTarget targetId =
    attribute "data-bs-target" ("#" ++ targetId)


bsScroll : Bool -> Attribute msg
bsScroll value =
    case value of
        True ->
            attribute "data-bs-scroll" "true"

        False ->
            attribute "data-bs-scroll" "false"


bsBackdrop : Bool -> Attribute msg
bsBackdrop value =
    case value of
        True ->
            attribute "data-bs-backdrop" "true"

        False ->
            attribute "data-bs-backdrop" "false"


ariaExpanded : Bool -> Attribute msg
ariaExpanded value =
    case value of
        True ->
            attribute "aria-expanded" "true"

        False ->
            attribute "aria-expanded" "false"


ariaHidden : Bool -> Attribute msg
ariaHidden value =
    case value of
        True ->
            attribute "aria-hidden" "true"

        False ->
            attribute "aria-hidden" "false"


ariaControls : HtmlId -> Attribute msg
ariaControls targetId =
    attribute "aria-controls" targetId


ariaLabel : Text -> Attribute msg
ariaLabel text =
    attribute "aria-label" text


ariaLabelledBy : HtmlId -> Attribute msg
ariaLabelledBy targetId =
    attribute "aria-labelledby" targetId


bsToggleDropdown : HtmlId -> List (Attribute msg)
bsToggleDropdown eltId =
    [ bsToggle Dropdown, id eltId, ariaExpanded False ]


bsToggleModal : HtmlId -> List (Attribute msg)
bsToggleModal targetId =
    [ bsToggle Modal, bsTarget targetId ]


bsToggleCollapse : HtmlId -> List (Attribute msg)
bsToggleCollapse targetId =
    [ bsToggle Collapse, bsTarget targetId, ariaControls targetId, ariaExpanded False ]


bsToggleOffcanvas : HtmlId -> List (Attribute msg)
bsToggleOffcanvas targetId =
    [ bsToggle Offcanvas, bsTarget targetId, ariaControls targetId ]


bsDropdown : HtmlId -> List (Attribute msg) -> (List (Attribute msg) -> Html msg) -> (List (Attribute msg) -> Html msg) -> Html msg
bsDropdown dropdownId contentAttrs toggleElement dropdownContent =
    -- TODO find a nice way to give the "dropdown-menu-end" option
    div [ class "dropdown" ]
        [ toggleElement (bsToggleDropdown dropdownId)
        , dropdownContent ([ class "dropdown-menu", ariaLabelledBy dropdownId ] ++ contentAttrs)
        ]


bsButton : BsColor -> List (Attribute msg) -> List (Html msg) -> Html msg
bsButton color attrs children =
    -- TODO find a nice way to give the "outline" option
    Html.button ([ type_ "button", class "btn", class ("btn-outline-" ++ colorToString color) ] ++ attrs) children


bsButtonGroup : Text -> List (Html msg) -> Html msg
bsButtonGroup label buttons =
    div [ class "btn-group", role "group", ariaLabel label ] buttons


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
