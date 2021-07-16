module Views.Menu exposing (viewMenu)

import AssocList as Dict exposing (Dict)
import Conf exposing (conf)
import Html exposing (Html, button, div, h5, text)
import Html.Attributes exposing (class, id, tabindex, type_)
import Html.Events exposing (onClick)
import Libs.Bootstrap exposing (BsColor(..), Toggle(..), ariaLabel, ariaLabelledBy, bsBackdrop, bsButton, bsButtonGroup, bsDismiss, bsScroll)
import Models exposing (Msg(..))
import Models.Schema exposing (RelationRef, Table, TableId)



-- deps = { to = { only = [ "Libs.*", "Models.*", "Conf", "Views.Helpers" ] } }


viewMenu : Maybe ( Dict TableId Table, Dict TableId (List RelationRef) ) -> List (Html Msg)
viewMenu schema =
    [ div [ id conf.ids.menu, class "offcanvas offcanvas-start", bsScroll True, bsBackdrop "false", ariaLabelledBy (conf.ids.menu ++ "-label"), tabindex -1 ]
        [ div [ class "offcanvas-header" ]
            [ h5 [ class "offcanvas-title", id (conf.ids.menu ++ "-label") ] [ text "Menu" ]
            , button [ type_ "button", class "btn-close text-reset", bsDismiss Offcanvas, ariaLabel "Close" ] []
            ]
        , div [ class "offcanvas-body" ]
            ([ div [] [ bsButton Primary [ onClick ChangeSchema ] [ text "Load a schema" ] ] ]
                ++ (schema
                        |> Maybe.map
                            (\( tables, relations ) ->
                                if Dict.isEmpty tables then
                                    []

                                else
                                    [ text
                                        ((tables |> Dict.size |> String.fromInt)
                                            ++ " tables, "
                                            ++ (tables |> Dict.foldl (\_ t c -> c + Dict.size t.columns) 0 |> String.fromInt)
                                            ++ " columns, "
                                            ++ (relations |> Dict.values |> List.map List.length |> List.sum |> String.fromInt)
                                            ++ " relations"
                                        )
                                    , div []
                                        [ bsButtonGroup "Toggle all"
                                            [ bsButton Secondary [ onClick HideAllTables ] [ text "Hide all tables" ]
                                            , bsButton Secondary [ onClick ShowAllTables ] [ text "Show all tables" ]
                                            ]
                                        ]
                                    ]
                            )
                        |> Maybe.withDefault []
                   )
            )
        ]
    ]
