module Views.Navbar exposing (viewNavbar)

import AssocList as Dict
import FontAwesome.Icon exposing (viewIcon)
import FontAwesome.Solid as Icon
import Html exposing (Html, a, b, button, div, form, h5, img, input, label, li, nav, span, text, ul)
import Html.Attributes exposing (alt, autocomplete, autofocus, class, disabled, for, height, href, id, placeholder, src, style, tabindex, title, type_, value)
import Html.Events exposing (onClick, onInput)
import Libs.Std exposing (bText, codeText)
import Models exposing (Msg(..), Search)
import Models.Schema exposing (Column, ColumnName(..), Layout, LayoutName, Table, TableName(..), TableStatus(..))
import Models.Utils exposing (Text)
import Views.Bootstrap exposing (BsColor(..), Toggle(..), ariaExpanded, ariaHidden, ariaLabel, ariaLabelledBy, bsButton, bsDismiss, bsToggle, bsToggleCollapse, bsToggleDropdown, bsToggleModal, bsToggleOffcanvas)
import Views.Helpers exposing (extractColumnName, formatTableId)


viewNavbar : Search -> Maybe LayoutName -> Maybe LayoutName -> List Layout -> List Table -> Html Msg
viewNavbar search newLayout currentLayout layouts tables =
    div []
        [ nav [ class "navbar navbar-expand-md navbar-light bg-white shadow-sm", id "navbar" ]
            [ div [ class "container-fluid" ]
                [ a ([ href "#", class "navbar-brand" ] ++ bsToggleOffcanvas "menu") [ img [ src "assets/logo.png", alt "logo", height 24, class "d-inline-block align-text-top" ] [], text " Schema Viz" ]
                , button ([ type_ "button", class "navbar-toggler", ariaLabel "Toggle navigation" ] ++ bsToggleCollapse "navbar-content")
                    [ span [ class "navbar-toggler-icon" ] []
                    ]
                , div [ class "collapse navbar-collapse", id "navbar-content" ]
                    [ form [ class "d-flex" ]
                        [ div [ class "dropdown" ]
                            [ input ([ type_ "search", class "form-control", value search, placeholder "Search", ariaLabel "Search", autocomplete False, onInput ChangedSearch ] ++ bsToggleDropdown "search") []
                            , ul [ class "dropdown-menu" ]
                                (buildSuggestions search tables |> List.map (\s -> li [] [ a [ class "dropdown-item", style "cursor" "pointer", onClick s.msg ] s.content ]))
                            ]
                        ]
                    , ul [ class "navbar-nav me-auto" ]
                        [ li [ class "nav-item" ] [ a ([ href "#", class "nav-link" ] ++ bsToggleModal "help-modal") [ text "?" ] ]
                        ]
                    , viewLayoutButton currentLayout layouts
                    ]
                ]
            ]
        , viewCreateLayoutModal (newLayout |> Maybe.withDefault "")
        , viewHelpModal
        ]


viewLayoutButton : Maybe LayoutName -> List Layout -> Html Msg
viewLayoutButton currentLayout layouts =
    if List.isEmpty layouts then
        bsButton Primary ([ title "Save your current layout to reload it later" ] ++ bsToggleModal "new-layout-modal") [ text "Save layout" ]

    else
        div [ class "btn-group" ]
            ((currentLayout
                |> Maybe.map
                    (\layout ->
                        [ bsButton Primary [ onClick (UpdateLayout layout) ] [ text ("Update '" ++ layout ++ "'") ]
                        , bsButton Primary [ class "dropdown-toggle dropdown-toggle-split", bsToggle Dropdown, ariaExpanded False ] [ span [ class "visually-hidden" ] [ text "Toggle Dropdown" ] ]
                        ]
                    )
                |> Maybe.withDefault [ bsButton Primary [ class "dropdown-toggle", bsToggle Dropdown, ariaExpanded False ] [ text "Layouts" ] ]
             )
                ++ [ ul [ class "dropdown-menu dropdown-menu-end" ]
                        ([ li [] [ a ([ class "dropdown-item", href "#" ] ++ bsToggleModal "new-layout-modal") [ viewIcon Icon.plus, text " Create new layout" ] ] ]
                            ++ (layouts
                                    |> List.map
                                        (\l ->
                                            li []
                                                [ a [ class "dropdown-item", href "#" ]
                                                    [ span [ title "Load layout", bsToggle Tooltip, onClick (LoadLayout l.name) ] [ viewIcon Icon.upload ]
                                                    , text " "
                                                    , span [ title "Update layout with current one", bsToggle Tooltip, onClick (UpdateLayout l.name) ] [ viewIcon Icon.edit ]
                                                    , text " "
                                                    , span [ title "Delete layout", bsToggle Tooltip, onClick (DeleteLayout l.name) ] [ viewIcon Icon.trashAlt ]
                                                    , text " "
                                                    , span [ onClick (LoadLayout l.name) ] [ text (l.name ++ " (" ++ String.fromInt (Dict.size l.tables) ++ " tables)") ]
                                                    ]
                                                ]
                                        )
                               )
                        )
                   ]
            )


viewCreateLayoutModal : LayoutName -> Html Msg
viewCreateLayoutModal newLayout =
    div [ class "modal fade", id "new-layout-modal", tabindex -1, ariaLabelledBy "new-layout-modal-label", ariaHidden True ]
        [ div [ class "modal-dialog modal-lg modal-dialog-centered modal-dialog-scrollable" ]
            [ div [ class "modal-content" ]
                [ div [ class "modal-header" ]
                    [ h5 [ class "modal-title", id "new-layout-modal-label" ] [ text "Save layout" ]
                    , button [ type_ "button", class "btn-close", bsDismiss Modal, ariaLabel "Close" ] []
                    ]
                , div [ class "modal-body" ]
                    [ div [ class "row g-3 align-items-center" ]
                        [ div [ class "col-auto" ] [ label [ class "col-form-label", for "new-layout-name" ] [ text "Layout name" ] ]
                        , div [ class "col-auto" ] [ input [ type_ "text", class "form-control", id "new-layout-name", value newLayout, onInput NewLayout, autofocus True ] [] ]
                        ]
                    ]
                , div [ class "modal-footer" ]
                    [ button [ type_ "button", class "btn btn-secondary", bsDismiss Modal ] [ text "Cancel" ]
                    , button [ type_ "button", class "btn btn-primary", bsDismiss Modal, disabled (newLayout == ""), onClick (CreateLayout newLayout) ] [ text "Save layout" ]
                    ]
                ]
            ]
        ]


viewHelpModal : Html Msg
viewHelpModal =
    div [ class "modal fade", id "help-modal", tabindex -1, ariaLabelledBy "help-modal-label", ariaHidden True ]
        [ div [ class "modal-dialog modal-lg modal-dialog-centered modal-dialog-scrollable" ]
            [ div [ class "modal-content" ]
                [ div [ class "modal-header" ]
                    [ h5 [ class "modal-title", id "help-modal-label" ] [ text "Schema Viz cheatsheet" ]
                    , button [ type_ "button", class "btn-close", bsDismiss Modal, ariaLabel "Close" ] []
                    ]
                , div [ class "modal-body" ]
                    [ ul []
                        [ li [] [ text "In ", bText "search", text ", you can look for tables and columns, then click on one to show it" ]
                        , li [] [ text "Not connected relations on the left are ", bText "incoming foreign keys", text ". Click on the column icon to see tables referencing it and then show them" ]
                        , li [] [ text "Not connected relations on the right are ", bText "column foreign keys", text ". Click on the column icon to show referenced table" ]
                        , li [] [ text "You can ", bText "hide/show a column", text " with a ", codeText "double click", text " on it" ]
                        , li [] [ text "You can ", bText "zoom in/out", text " using scrolling action, ", bText "move tables", text " around by dragging them or even ", bText "move everything", text " by dragging the background" ]
                        ]
                    ]
                , div [ class "modal-footer" ]
                    [ button [ type_ "button", class "btn btn-primary", bsDismiss Modal ] [ text "Thanks!" ]
                    ]
                ]
            ]
        ]


type alias Suggestion =
    { priority : Float, content : List (Html Msg), msg : Msg }


buildSuggestions : Search -> List Table -> List Suggestion
buildSuggestions search tables =
    tables |> List.concatMap (asSuggestions search) |> List.sortBy .priority |> List.take 30


asSuggestions : Search -> Table -> List Suggestion
asSuggestions search table =
    { priority = 0 - matchStrength search table
    , content = viewIcon Icon.angleRight :: text " " :: highlightMatch search (formatTableId table.id)
    , msg = ShowTable table.id
    }
        :: (table.columns |> Dict.values |> List.filterMap (columnSuggestion search table))


columnSuggestion : Search -> Table -> Column -> Maybe Suggestion
columnSuggestion search table column =
    case column.column of
        ColumnName name ->
            if name == search then
                Just
                    { priority = 0 - 0.5
                    , content = viewIcon Icon.angleDoubleRight :: [ text (" " ++ formatTableId table.id ++ "."), b [] [ text (extractColumnName column.column) ] ]
                    , msg = ShowTable table.id
                    }

            else
                Nothing


highlightMatch : Search -> Text -> List (Html msg)
highlightMatch search value =
    value |> String.split search |> List.map text |> List.foldr (\i acc -> b [] [ text search ] :: i :: acc) [] |> List.drop 1


matchStrength : Search -> Table -> Float
matchStrength search table =
    case table.table of
        TableName name ->
            exactMatch search name
                + matchAtBeginning search name
                + matchNotAtBeginning search name
                + tableShownMalus table
                + columnMatchingBonus search table
                + (5 * manyColumnBonus table)
                + shortNameBonus name


exactMatch : Search -> Text -> Float
exactMatch search text =
    if text == search then
        3

    else
        0


matchAtBeginning : Search -> Text -> Float
matchAtBeginning search text =
    if not (search == "") && String.startsWith search text then
        2

    else
        0


matchNotAtBeginning : Search -> Text -> Float
matchNotAtBeginning search text =
    if not (search == "") && String.contains search text && not (String.startsWith search text) then
        1

    else
        0


columnMatchingBonus : Search -> Table -> Float
columnMatchingBonus search table =
    let
        columnNames : List Text
        columnNames =
            Dict.values table.columns |> List.map (\c -> extractColumnName c.column)
    in
    if not (search == "") then
        if columnNames |> List.any (\columnName -> not (exactMatch search columnName == 0)) then
            0.5

        else if columnNames |> List.any (\columnName -> not (matchAtBeginning search columnName == 0)) then
            0.2

        else if columnNames |> List.any (\columnName -> not (matchNotAtBeginning search columnName == 0)) then
            0.1

        else
            0

    else
        0


shortNameBonus : Text -> Float
shortNameBonus name =
    if String.length name == 0 then
        0

    else
        1 / toFloat (String.length name)


manyColumnBonus : Table -> Float
manyColumnBonus table =
    -1 / toFloat (Dict.size table.columns)


tableShownMalus : Table -> Float
tableShownMalus table =
    if table.state.status == Shown then
        -2

    else
        0
