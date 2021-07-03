module Views.Menu exposing (viewMenu)

import AssocList as Dict
import FileValue exposing (hiddenInputSingle)
import Html exposing (Html, button, div, h5, label, text)
import Html.Attributes exposing (class, for, id, tabindex, type_)
import Html.Events exposing (onClick)
import Models exposing (Msg(..))
import Models.Schema exposing (Schema, TableStatus(..))
import Views.Bootstrap exposing (BsColor(..), Toggle(..), ariaLabel, ariaLabelledBy, bsBackdrop, bsButton, bsButtonGroup, bsDismiss, bsScroll)



-- menu view, can include Views.Helpers, Models or Libs modules. Nothing else from views.


viewMenu : Schema -> Html Msg
viewMenu schema =
    div []
        [ div [ class "offcanvas offcanvas-start", id "menu", bsScroll True, bsBackdrop False, ariaLabelledBy "menu-label", tabindex -1 ]
            [ div [ class "offcanvas-header" ]
                [ h5 [ class "offcanvas-title", id "menu-label" ] [ text "Menu" ]
                , button [ type_ "button", class "btn-close text-reset", bsDismiss Offcanvas, ariaLabel "Close" ] []
                ]
            , div [ class "offcanvas-body" ]
                [ text
                    ((schema.tables |> Dict.size |> String.fromInt)
                        ++ " tables, "
                        ++ (schema.tables |> Dict.foldl (\_ t c -> c + Dict.size t.columns) 0 |> String.fromInt)
                        ++ " columns, "
                        ++ (schema.relations |> List.length |> String.fromInt)
                        ++ " relations"
                    )
                , div []
                    [ bsButtonGroup "Toggle all"
                        [ bsButton Secondary [ onClick HideAllTables ] [ text "Hide all tables" ]
                        , bsButton Secondary [ onClick ShowAllTables ] [ text "Show all tables" ]
                        ]
                    ]
                , div []
                    [ hiddenInputSingle "file-loader" [ ".sql,.json" ] FileSelected
                    , label [ for "file-loader", class "btn btn-outline-primary" ] [ text "Click to load a file" ]
                    ]
                , div
                    (FileValue.onDrop
                        { onOver = FileDragOver
                        , onLeave = Just { id = "file-drop", msg = FileDragLeave }
                        , onDrop = FileDropped
                        }
                    )
                    [ text "Or drop a file here" ]
                ]
            ]
        ]
