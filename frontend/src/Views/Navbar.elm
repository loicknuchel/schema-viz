module Views.Navbar exposing (viewNavbar)

import AssocList as Dict
import FontAwesome.Icon exposing (viewIcon)
import FontAwesome.Solid as Icon
import Html exposing (Html, a, b, button, div, form, img, input, li, nav, span, text, ul)
import Html.Attributes exposing (alt, attribute, autocomplete, class, height, href, id, placeholder, src, style, type_, value)
import Html.Events exposing (onClick, onInput)
import Models exposing (Msg(..))
import Models.Schema exposing (Column, ColumnName(..), Table, TableName(..), TableStatus(..))
import Views.Helpers exposing (extractColumnName, formatTableId)


viewNavbar : String -> List Table -> Html Msg
viewNavbar search tables =
    nav [ class "navbar navbar-expand-md navbar-light bg-white shadow-sm", id "navbar" ]
        [ div [ class "container-fluid" ]
            [ a [ href "#", class "navbar-brand" ] [ img [ src "assets/logo.png", alt "logo", height 24, class "d-inline-block align-text-top" ] [], text " Schema Viz" ]
            , button [ type_ "button", class "navbar-toggler", attribute "data-bs-toggle" "collapse", attribute "data-bs-target" "#navbar-content", attribute "aria-controls" "navbar-content", attribute "aria-expanded" "false", attribute "aria-label" "Toggle navigation" ]
                [ span [ class "navbar-toggler-icon" ] []
                ]
            , div [ class "collapse navbar-collapse", id "navbar-content" ]
                [ ul [ class "navbar-nav me-auto" ]
                    [ li [ class "nav-item" ] [ a [ href "#", class "nav-link", attribute "data-bs-toggle" "offcanvas", attribute "data-bs-target" "#menu", attribute "aria-controls" "menu" ] [ text "Toggle menu" ] ]
                    ]
                , form [ class "d-flex" ]
                    [ div [ class "dropdown" ]
                        [ input [ type_ "search", class "form-control", id "search", value search, placeholder "Search", attribute "aria-label" "Search", attribute "data-bs-toggle" "dropdown", autocomplete False, onInput ChangedSearch ] []
                        , ul [ class "dropdown-menu dropdown-menu-end" ]
                            (buildSuggestions search tables |> List.map (\s -> li [] [ a [ class "dropdown-item", style "cursor" "pointer", onClick s.msg ] s.content ]))
                        ]
                    ]
                ]
            ]
        ]


type alias Suggestion =
    { priority : Float, content : List (Html Msg), msg : Msg }


buildSuggestions : String -> List Table -> List Suggestion
buildSuggestions search tables =
    tables |> List.concatMap (asSuggestions search) |> List.sortBy .priority |> List.take 30


asSuggestions : String -> Table -> List Suggestion
asSuggestions search table =
    { priority = 0 - matchStrength search table
    , content = viewIcon Icon.angleRight :: text " " :: highlightMatch search (formatTableId table.id)
    , msg = ShowTable table.id
    }
        :: (table.columns |> Dict.values |> List.filterMap (columnSuggestion search table))


columnSuggestion : String -> Table -> Column -> Maybe Suggestion
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


highlightMatch : String -> String -> List (Html msg)
highlightMatch search value =
    value |> String.split search |> List.map text |> List.foldr (\i acc -> b [] [ text search ] :: i :: acc) [] |> List.drop 1


matchStrength : String -> Table -> Float
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


exactMatch : String -> String -> Float
exactMatch search text =
    if text == search then
        3

    else
        0


matchAtBeginning : String -> String -> Float
matchAtBeginning search text =
    if not (search == "") && String.startsWith search text then
        2

    else
        0


matchNotAtBeginning : String -> String -> Float
matchNotAtBeginning search text =
    if not (search == "") && String.contains search text && not (String.startsWith search text) then
        1

    else
        0


columnMatchingBonus : String -> Table -> Float
columnMatchingBonus search table =
    let
        columnNames : List String
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


shortNameBonus : String -> Float
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
