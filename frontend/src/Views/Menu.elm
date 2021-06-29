module Views.Menu exposing (viewMenu)

import AssocList as Dict
import Html exposing (Html, button, div, h5, text)
import Html.Attributes exposing (class, id, tabindex, type_)
import Html.Events exposing (onClick)
import Models exposing (Msg(..))
import Models.Schema exposing (Schema, TableStatus(..))
import Views.Bootstrap exposing (BsColor(..), Toggle(..), ariaLabel, ariaLabelledBy, bsBackdrop, bsButton, bsButtonGroup, bsDismiss, bsScroll)



-- menu view, can include Views.Helpers, Models or Libs modules. Nothing else from views.


viewMenu : Schema -> Html Msg
viewMenu schema =
    div [ class "offcanvas offcanvas-end", id "menu", bsScroll True, bsBackdrop False, ariaLabelledBy "menu-label", tabindex -1 ]
        [ div [ class "offcanvas-header" ]
            [ h5 [ class "offcanvas-title", id "menu-label" ] [ text "Menu" ]
            , button [ type_ "button", class "btn-close text-reset", bsDismiss Offcanvas, ariaLabel "Close" ] []
            ]
        , div [ class "offcanvas-body" ]
            [ div []
                [ bsButtonGroup "Toggle all"
                    [ bsButton Secondary [ onClick HideAllTables ] [ text "Hide all tables" ]
                    , bsButton Secondary [ onClick ShowAllTables ] [ text "Show all tables" ]
                    ]
                ]
            , text
                ((schema.tables |> Dict.size |> String.fromInt)
                    ++ " tables, "
                    ++ (schema.tables |> Dict.foldl (\_ t c -> c + Dict.size t.columns) 0 |> String.fromInt)
                    ++ " columns, "
                    ++ (schema.relations |> List.length |> String.fromInt)
                    ++ " relations"
                )
            ]
        ]
