module PagesComponents.App.Views.Modals.FindPath exposing (viewFindPathModal)

import Conf exposing (conf)
import Dict exposing (Dict)
import Html exposing (Html, b, br, button, div, label, li, ol, option, select, span, text)
import Html.Attributes exposing (class, for, id, selected, title, type_, value)
import Html.Events exposing (onBlur, onInput)
import Libs.Bootstrap exposing (Toggle(..), bsDismiss, bsModal)
import Libs.Html.Attributes exposing (role)
import Libs.Maybe as M
import Libs.Nel as Nel
import Models.FindPath as FindPath
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
            ++ (Maybe.map3 viewPaths model.from model.to model.paths |> Maybe.withDefault [])
        )
        [ button [ type_ "button", class "btn btn-primary", bsDismiss Modal ] [ text "Done" ] ]


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
        , onBlur FindPathCompute
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


viewPaths : TableId -> TableId -> List FindPath.Path -> List (Html msg)
viewPaths from to paths =
    if paths |> List.isEmpty then
        [ div [ class "mt-3" ] [ text "No path found" ] ]

    else
        [ div [ class "mt-3" ]
            [ text ("Found " ++ String.fromInt (List.length paths) ++ " paths between tables ")
            , b [] [ text (showTableId from) ]
            , text " and "
            , b [] [ text (showTableId to) ]
            , text ":"
            ]
        , ol [ class "list-group list-group-numbered mt-3" ] (paths |> List.sortBy Nel.length |> List.map (viewPath from))
        ]


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
