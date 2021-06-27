module Views.Navbar exposing (viewNavbar)

import AssocList as Dict
import FontAwesome.Icon exposing (viewIcon)
import FontAwesome.Solid as Icon
import Html exposing (Html, a, b, button, div, form, img, input, li, nav, span, text, ul)
import Html.Attributes exposing (alt, attribute, autocomplete, class, height, href, id, placeholder, src, style, type_, value)
import Html.Events exposing (onClick, onInput)
import Models exposing (Msg(..))
import Models.Schema exposing (Table, TableName(..))
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
                        [ input [ type_ "search", class "form-control", id "search", value search, onInput ChangedSearch, placeholder "Search", attribute "aria-label" "Search", attribute "data-bs-toggle" "dropdown", autocomplete False ] []
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
    tables |> List.map (asSuggestion search) |> List.sortBy .priority |> List.take 30


asSuggestion : String -> Table -> Suggestion
asSuggestion search table =
    { priority = 0 - matchStrength search table
    , content = viewIcon Icon.angleRight :: text " " :: highlightMatch search (formatTableId table.id)
    , msg = ShowTable table.id
    }


highlightMatch : String -> String -> List (Html msg)
highlightMatch search value =
    -- [ span [] [ text value ] ]
    List.drop 1 (List.foldr (\i acc -> b [] [ text search ] :: i :: acc) [] (List.map text (String.split search value)))


matchStrength : String -> Table -> Float
matchStrength search table =
    case table.table of
        TableName name ->
            exactMatchAtBeginning search name
                + exactMatchNotAtBeginning search name
                + hasColumnMatching search table
                + shortNameBonus name
                + (5 * manyColumnBonus table)


exactMatchAtBeginning : String -> String -> Float
exactMatchAtBeginning search text =
    if not (search == "") && String.startsWith search text then
        2

    else
        0


exactMatchNotAtBeginning : String -> String -> Float
exactMatchNotAtBeginning search text =
    if not (search == "") && String.contains search text && not (String.startsWith search text) then
        1

    else
        0


hasColumnMatching : String -> Table -> Float
hasColumnMatching search table =
    if not (search == "") && List.any (\c -> not (exactMatchAtBeginning search (extractColumnName c.column) == 0)) (Dict.values table.columns) then
        0.5

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
