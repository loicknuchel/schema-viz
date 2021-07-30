module PagesComponents.App.Views.Navbar exposing (viewNavbar)

import Conf exposing (conf)
import Dict exposing (Dict)
import FontAwesome.Icon exposing (viewIcon)
import FontAwesome.Solid as Icon
import Html exposing (Html, b, button, div, form, img, input, li, nav, span, text, ul)
import Html.Attributes exposing (alt, attribute, autocomplete, class, height, id, placeholder, src, title, type_, value)
import Html.Events exposing (onClick, onInput)
import Libs.Bootstrap exposing (BsColor(..), Toggle(..), ariaExpanded, ariaLabel, bsButton, bsToggle, bsToggleCollapse, bsToggleDropdown, bsToggleModal, bsToggleOffcanvas)
import Libs.Models exposing (Text)
import Libs.Ned as Ned
import Libs.Nel as Nel exposing (Nel)
import Models.Schema exposing (Column, Layout, LayoutName, SchemaId, Table, TableId, showTableId)
import PagesComponents.App.Models exposing (Msg(..), Search)
import PagesComponents.App.Views.Helpers exposing (extractColumnName)


viewNavbar : Search -> Maybe ( SchemaId, ( Dict TableId Table, Layout ), ( Maybe LayoutName, Dict LayoutName Layout ) ) -> List (Html Msg)
viewNavbar search schema =
    [ nav [ id "navbar", class "navbar navbar-expand-md navbar-light bg-white shadow-sm" ]
        [ div [ class "container-fluid" ]
            [ button ([ type_ "button", class "link navbar-brand" ] ++ bsToggleOffcanvas conf.ids.menu) [ img [ src "assets/logo.png", alt "logo", height 24, class "d-inline-block align-text-top" ] [], text " Schema Viz" ]
            , button ([ type_ "button", class "navbar-toggler", ariaLabel "Toggle navigation" ] ++ bsToggleCollapse "navbar-content")
                [ span [ class "navbar-toggler-icon" ] []
                ]
            , div [ class "collapse navbar-collapse", id "navbar-content" ]
                ([ viewSearchBar (schema |> Maybe.map (\( _, s, _ ) -> s)) search
                 , ul [ class "navbar-nav me-auto" ]
                    [ li [ class "nav-item" ] [ button ([ type_ "button", class "link nav-link" ] ++ bsToggleModal conf.ids.helpModal) [ text "?" ] ]
                    ]
                 ]
                    ++ (schema |> Maybe.map (\( id, ( tables, _ ), ( layoutName, layouts ) ) -> [ viewTitle id tables layoutName, viewLayoutButton layoutName layouts ]) |> Maybe.withDefault [])
                )
            ]
        ]
    ]


viewSearchBar : Maybe ( Dict TableId Table, Layout ) -> Search -> Html Msg
viewSearchBar schema search =
    schema
        |> Maybe.map
            (\( tables, layout ) ->
                form [ class "d-flex" ]
                    [ div [ class "dropdown" ]
                        [ input ([ type_ "text", class "form-control", value search, placeholder "Search", ariaLabel "Search", autocomplete False, onInput ChangedSearch, attribute "data-bs-auto-close" "false" ] ++ bsToggleDropdown conf.ids.searchInput) []
                        , ul [ class "dropdown-menu" ]
                            (buildSuggestions tables layout search
                                |> List.map (\suggestion -> li [] [ button [ type_ "button", class "dropdown-item", onClick suggestion.msg ] suggestion.content ])
                            )
                        ]
                    ]
            )
        |> Maybe.withDefault
            (form [ class "d-flex" ]
                [ div []
                    [ input [ type_ "text", class "form-control", value search, placeholder "Search", ariaLabel "Search", autocomplete False, onInput ChangedSearch, attribute "data-bs-auto-close" "false", id conf.ids.searchInput ] []
                    , ul [ class "dropdown-menu" ] []
                    ]
                ]
            )


viewTitle : SchemaId -> Dict TableId Table -> Maybe LayoutName -> Html msg
viewTitle id tables layoutName =
    div [ class "me-auto", title (String.fromInt (Dict.size tables) ++ " tables") ] [ text (id ++ (layoutName |> Maybe.map (\name -> " > " ++ name) |> Maybe.withDefault "")) ]


viewLayoutButton : Maybe LayoutName -> Dict LayoutName Layout -> Html Msg
viewLayoutButton currentLayout layouts =
    if Dict.isEmpty layouts then
        bsButton Primary ([ title "Save your current layout to reload it later" ] ++ bsToggleModal conf.ids.newLayoutModal) [ text "Save layout" ]

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
                        ([ li [] [ button ([ type_ "button", class "dropdown-item" ] ++ bsToggleModal conf.ids.newLayoutModal) [ viewIcon Icon.plus, text " Create new layout" ] ] ]
                            ++ (layouts
                                    |> Dict.toList
                                    |> List.sortBy (\( name, _ ) -> name)
                                    |> List.map
                                        (\( name, l ) ->
                                            li []
                                                [ button [ type_ "button", class "dropdown-item" ]
                                                    [ span [ title "Load layout", bsToggle Tooltip, onClick (LoadLayout name) ] [ viewIcon Icon.upload ]
                                                    , text " "
                                                    , span [ title "Update layout with current one", bsToggle Tooltip, onClick (UpdateLayout name) ] [ viewIcon Icon.edit ]
                                                    , text " "
                                                    , span [ title "Delete layout", bsToggle Tooltip, onClick (DeleteLayout name) ] [ viewIcon Icon.trashAlt ]
                                                    , text " "
                                                    , span [ onClick (LoadLayout name) ] [ text (name ++ " (" ++ String.fromInt (Dict.size l.tables) ++ " tables)") ]
                                                    ]
                                                ]
                                        )
                               )
                        )
                   ]
            )


type alias Suggestion =
    { priority : Float, content : List (Html Msg), msg : Msg }


buildSuggestions : Dict TableId Table -> Layout -> Search -> List Suggestion
buildSuggestions tables layout search =
    tables |> Dict.values |> List.concatMap (asSuggestions layout search) |> List.sortBy .priority |> List.take 30


asSuggestions : Layout -> Search -> Table -> List Suggestion
asSuggestions layout search table =
    { priority = 0 - matchStrength table layout search
    , content = viewIcon Icon.angleRight :: text " " :: highlightMatch search (showTableId table.id)
    , msg = ShowTable table.id
    }
        :: (table.columns |> Ned.values |> Nel.filterMap (columnSuggestion search table))


columnSuggestion : Search -> Table -> Column -> Maybe Suggestion
columnSuggestion search table column =
    if column.name == search then
        Just
            { priority = 0 - 0.5
            , content = viewIcon Icon.angleDoubleRight :: [ text (" " ++ showTableId table.id ++ "."), b [] [ text (extractColumnName column.name) ] ]
            , msg = ShowTable table.id
            }

    else
        Nothing


highlightMatch : Search -> Text -> List (Html msg)
highlightMatch search value =
    value |> String.split search |> List.map text |> List.foldr (\i acc -> b [] [ text search ] :: i :: acc) [] |> List.drop 1


matchStrength : Table -> Layout -> Search -> Float
matchStrength table layout search =
    exactMatch search table.table
        + matchAtBeginning search table.table
        + matchNotAtBeginning search table.table
        + tableShownMalus layout table
        + columnMatchingBonus search table
        + (5 * manyColumnBonus table)
        + shortNameBonus table.table


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
        columnNames : Nel Text
        columnNames =
            table.columns |> Ned.values |> Nel.map (\c -> extractColumnName c.name)
    in
    if not (search == "") then
        if columnNames |> Nel.any (\columnName -> not (exactMatch search columnName == 0)) then
            0.5

        else if columnNames |> Nel.any (\columnName -> not (matchAtBeginning search columnName == 0)) then
            0.2

        else if columnNames |> Nel.any (\columnName -> not (matchNotAtBeginning search columnName == 0)) then
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
    let
        size : Int
        size =
            Ned.size table.columns
    in
    if size == 0 then
        -0.3

    else
        -1 / toFloat size


tableShownMalus : Layout -> Table -> Float
tableShownMalus layout table =
    if layout.tables |> Dict.member table.id then
        -2

    else
        0