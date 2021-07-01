module Views.Menu exposing (viewMenu)

import AssocList as Dict
import FontAwesome.Icon exposing (viewIcon)
import FontAwesome.Solid as Icon
import Html exposing (Html, button, div, h5, input, label, span, text)
import Html.Attributes exposing (autofocus, class, disabled, for, id, tabindex, title, type_, value)
import Html.Events exposing (onClick, onInput)
import Models exposing (Msg(..))
import Models.Schema exposing (Schema, TableStatus(..))
import Views.Bootstrap exposing (BsColor(..), Toggle(..), ariaHidden, ariaLabel, ariaLabelledBy, bsBackdrop, bsButton, bsButtonGroup, bsDismiss, bsScroll, bsToggle, bsToggleModal)



-- menu view, can include Views.Helpers, Models or Libs modules. Nothing else from views.


viewMenu : Maybe String -> Schema -> Html Msg
viewMenu newLayout schema =
    div []
        [ div [ class "offcanvas offcanvas-end", id "menu", bsScroll True, bsBackdrop False, ariaLabelledBy "menu-label", tabindex -1 ]
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
                , bsButton Primary (bsToggleModal "new-layout-modal") [ text "Save layout" ]
                , div []
                    (schema.layouts
                        |> List.map
                            (\l ->
                                div []
                                    [ span [ title "Load schema", bsToggle Tooltip, onClick (LoadLayout l.name) ] [ viewIcon Icon.upload ]
                                    , text " "
                                    , span [ title "Save schema", bsToggle Tooltip, onClick (UpdateLayout l.name) ] [ viewIcon Icon.edit ]
                                    , text " "
                                    , span [ title "Delete schema", bsToggle Tooltip, onClick (DeleteLayout l.name) ] [ viewIcon Icon.trashAlt ]
                                    , text (" " ++ l.name ++ " (" ++ String.fromInt (Dict.size l.tables) ++ " tables)")
                                    ]
                            )
                    )
                ]
            ]
        , div [ class "modal fade", id "new-layout-modal", tabindex -1, ariaLabelledBy "new-layout-modal-label", ariaHidden True ]
            [ div [ class "modal-dialog modal-lg modal-dialog-centered modal-dialog-scrollable" ]
                [ div [ class "modal-content" ]
                    [ div [ class "modal-header" ]
                        [ h5 [ class "modal-title", id "new-layout-modal-label" ] [ text "Save layout" ]
                        , button [ type_ "button", class "btn-close", bsDismiss Modal, ariaLabel "Close" ] []
                        ]
                    , div [ class "modal-body" ]
                        [ div [ class "row g-3 align-items-center" ]
                            [ div [ class "col-auto" ] [ label [ class "col-form-label", for "new-layout-name" ] [ text "Layout name" ] ]
                            , div [ class "col-auto" ] [ input [ type_ "text", class "form-control", id "new-layout-name", value (newLayout |> Maybe.withDefault ""), onInput NewLayout, autofocus True ] [] ]
                            ]
                        ]
                    , div [ class "modal-footer" ]
                        [ button [ type_ "button", class "btn btn-secondary", bsDismiss Modal ] [ text "Cancel" ]
                        , button [ type_ "button", class "btn btn-primary", bsDismiss Modal, disabled (newLayout == Nothing), onClick CreateLayout ] [ text "Save layout" ]
                        ]
                    ]
                ]
            ]
        ]
