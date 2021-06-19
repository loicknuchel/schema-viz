module Views.Menu exposing (viewMenu)

import AssocList as Dict
import FontAwesome.Icon exposing (viewIcon)
import FontAwesome.Solid as Icon
import Html exposing (Html, button, div, text)
import Html.Attributes exposing (class, style)
import Html.Events exposing (onClick)
import Libs.Std exposing (listFilterMap)
import Models exposing (Menu, Msg(..), conf)
import Models.Schema exposing (Schema, Table, TableStatus(..))
import Views.Helpers exposing (dragAttrs, formatTableName, placeAt)



-- menu view, can include Views.Helpers, Models or Libs modules. Nothing else from views.


viewMenu : Menu -> Schema -> Html Msg
viewMenu menu schema =
    div ([ class "menu", placeAt menu.position ] ++ dragAttrs conf.ids.menu)
        ([ div []
            [ text
                ("menu ("
                    ++ String.fromInt (Dict.size schema.tables)
                    ++ " tables, "
                    ++ String.fromInt (Dict.foldl (\_ t c -> c + Dict.size t.columns) 0 schema.tables)
                    ++ " columns, "
                    ++ String.fromInt (List.length schema.relations)
                    ++ " relations)"
                )
            ]
         , div [] [ button [ onClick HideAllTables ] [ text "hide all tables" ], button [ onClick ShowAllTables ] [ text "show all tables" ] ]
         ]
            ++ listFilterMap (\t -> not (t.state.status == Visible)) viewHiddenTable (Dict.values schema.tables)
        )


viewHiddenTable : Table -> Html Msg
viewHiddenTable table =
    div [ style "display" "flex", style "align-items" "center" ]
        [ div [ style "flex-grow" "1" ] [ text (formatTableName table) ]
        , div [ style "font-size" "0.9rem", style "opacity" "0.25", onClick (ShowTable table.id) ] [ viewIcon Icon.eye ]
        ]
