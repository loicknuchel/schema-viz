module PagesComponents.App.Views.Modals.FindPath exposing (viewFindPathModal)

import Conf exposing (conf)
import Dict exposing (Dict)
import Html exposing (Html, b, br, button, div, label, li, ol, option, select, span, text)
import Html.Attributes exposing (class, disabled, for, id, selected, title, type_, value)
import Html.Events exposing (onClick, onInput)
import Libs.Bootstrap exposing (Toggle(..), bsDismiss, bsModal)
import Libs.Html.Attributes exposing (ariaHidden, role)
import Libs.Maybe as M
import Libs.Nel as Nel
import Models.FindPath as FindPath exposing (PathState(..))
import Models.Project exposing (Table, TableId, showColumnRef, showTableId, stringAsTableId, tableIdAsString)
import PagesComponents.App.Models exposing (Msg(..))


viewFindPathModal : Dict TableId Table -> FindPath.Model -> Html Msg
viewFindPathModal tables model =
    bsModal conf.ids.findPathModal
        "Find path"
        ([ div [ class "alert alert-warning", role "alert" ] [ text "This feature is experimental.", br [] [], text "Beware of ignoring hubs (ex: accounts or users tables, or created_by columns) so complexity don't explode and you browser doesn't go unresponsive." ]
         , div [ class "row" ]
            [ div [ class "col" ] [ selectCard "from" "From" "Starting table for the path" model.from FindPathFrom tables ]
            , div [ class "col" ] [ selectCard "to" "To" "Table you want to go to" model.to FindPathTo tables ]
            ]
         ]
            ++ viewPaths model
        )
        [ viewSearchButton model ]


selectCard : String -> String -> String -> Maybe TableId -> (Maybe TableId -> Msg) -> Dict TableId Table -> Html Msg
selectCard ref title description selectedValue buildMsg tables =
    div [ class "card" ]
        [ div [ class "card-body" ]
            [ label [ for (conf.ids.findPathModal ++ "-" ++ ref), class "form-label card-title h5" ] [ text title ]
            , selectInput ref selectedValue buildMsg tables
            , div [ id (conf.ids.findPathModal ++ "-" ++ ref ++ "-help"), class "form-text" ] [ text description ]
            ]
        ]


selectInput : String -> Maybe TableId -> (Maybe TableId -> Msg) -> Dict TableId Table -> Html Msg
selectInput ref selectedValue buildMsg tables =
    select
        [ class "form-select"
        , id (conf.ids.findPathModal ++ "-" ++ ref)
        , onInput (\id -> Just id |> M.filter (\i -> not (i == "")) |> Maybe.map stringAsTableId |> buildMsg)
        ]
        (option [ value "", selected (selectedValue == Nothing) ] [ text "-- Select a table" ]
            :: (tables
                    |> Dict.values
                    |> List.map
                        (\t ->
                            option
                                [ value (tableIdAsString t.id)
                                , selected (selectedValue |> M.contains t.id)
                                ]
                                [ text (showTableId t.id) ]
                        )
               )
        )


viewPaths : FindPath.Model -> List (Html msg)
viewPaths model =
    case ( model.from, model.to, model.result ) of
        ( Just from, Just to, Found result ) ->
            if result.from /= from || result.to /= to then
                [ div [ class "mt-3" ] [ text "Results out of sync with search 🤯" ] ]

            else if result.paths |> List.isEmpty then
                [ div [ class "mt-3" ] [ text "No path found" ] ]

            else
                [ div [ class "mt-3" ]
                    [ text ("Found " ++ String.fromInt (List.length result.paths) ++ " paths between tables ")
                    , b [] [ text (showTableId from) ]
                    , text " and "
                    , b [] [ text (showTableId to) ]
                    , text ":"
                    ]
                , ol [ class "list-group list-group-numbered mt-3" ] (result.paths |> List.sortBy Nel.length |> List.map (viewPath from))
                ]

        _ ->
            []


viewPath : TableId -> FindPath.Path -> Html msg
viewPath from path =
    li [ class "list-group-item" ]
        (span [] [ text (showTableId from) ]
            :: (path
                    |> Nel.toList
                    |> List.concatMap
                        (\s ->
                            [ text " > "
                            , case s.direction of
                                FindPath.Right ->
                                    span [ title (showColumnRef s.relation.src ++ " -> " ++ showColumnRef s.relation.ref) ] [ text (showTableId s.relation.ref.table) ]

                                FindPath.Left ->
                                    span [ title (showColumnRef s.relation.ref ++ " <- " ++ showColumnRef s.relation.src) ] [ text (showTableId s.relation.src.table) ]
                            ]
                        )
               )
        )


viewSearchButton : FindPath.Model -> Html Msg
viewSearchButton model =
    case ( model.from, model.to, model.result ) of
        ( Just from, Just to, Found res ) ->
            if from == res.from && to == res.to then
                button [ type_ "button", class "btn btn-primary", bsDismiss Modal ] [ text "Done" ]

            else
                button [ type_ "button", class "btn btn-primary", onClick FindPathSearch ] [ text "Search" ]

        ( Just _, Just _, Searching ) ->
            button [ type_ "button", class "btn btn-primary", disabled True ] [ span [ class "spinner-border spinner-border-sm", role "status", ariaHidden True ] [], text " Searching..." ]

        ( Just _, Just _, Empty ) ->
            button [ type_ "button", class "btn btn-primary", onClick FindPathSearch ] [ text "Search" ]

        _ ->
            button [ type_ "button", class "btn btn-primary", disabled True ] [ text "Search" ]
