module Views.Menu exposing (viewMenu)

import AssocList as Dict
import FontAwesome.Icon exposing (viewIcon)
import FontAwesome.Solid as Icon
import Html exposing (Html, button, div, h5, text)
import Html.Attributes exposing (attribute, class, id, style, tabindex, type_)
import Html.Events exposing (onClick)
import Libs.Std exposing (listFilterMap)
import Models exposing (Msg(..))
import Models.Schema exposing (Schema, Table, TableStatus(..))
import Views.Bootstrap exposing (BsColor(..), bsButton, bsButtonGroup)
import Views.Helpers exposing (formatTableName)



-- menu view, can include Views.Helpers, Models or Libs modules. Nothing else from views.


viewMenu : Schema -> Html Msg
viewMenu schema =
    div [ class "offcanvas offcanvas-end", id "menu", attribute "data-bs-scroll" "true", attribute "data-bs-backdrop" "false", attribute "aria-labelledby" "menu-label", tabindex -1 ]
        [ div [ class "offcanvas-header" ]
            [ h5 [ class "offcanvas-title", id "menu-label" ] [ text "Menu" ]
            , button [ type_ "button", class "btn-close text-reset", attribute "data-bs-dismiss" "offcanvas", attribute "aria-label" "Close" ] []
            ]
        , div [ class "offcanvas-body" ]
            ([ div []
                [ bsButtonGroup "Toggle all"
                    [ bsButton Secondary [ onClick HideAllTables ] [ text "Hide all tables" ]
                    , bsButton Secondary [ onClick ShowAllTables ] [ text "Show all tables" ]
                    ]
                ]
             , text
                (String.fromInt (Dict.size schema.tables)
                    ++ " tables, "
                    ++ String.fromInt (Dict.foldl (\_ t c -> c + Dict.size t.columns) 0 schema.tables)
                    ++ " columns, "
                    ++ String.fromInt (List.length schema.relations)
                    ++ " relations"
                )
             ]
                ++ listFilterMap (\t -> not (t.state.status == Shown)) viewHiddenTable (Dict.values schema.tables)
            )
        ]


viewHiddenTable : Table -> Html Msg
viewHiddenTable table =
    div [ style "display" "flex", style "align-items" "center" ]
        [ div [ style "font-size" "0.9rem", style "opacity" "0.25", onClick (ShowTable table.id) ] [ viewIcon Icon.eye ]
        , text " "
        , div [ style "flex-grow" "1" ] [ text (formatTableName table.table table.schema) ]
        ]
