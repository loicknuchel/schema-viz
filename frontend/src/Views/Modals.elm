module Views.Modals exposing (viewModals)

import AssocList as Dict
import Conf exposing (conf)
import FileValue exposing (hiddenInputSingle)
import Html exposing (Html, a, button, div, h5, input, label, li, p, text, ul)
import Html.Attributes exposing (autofocus, class, disabled, for, href, id, tabindex, target, type_, value)
import Html.Events exposing (onClick, onInput)
import Libs.Std exposing (bText, codeText, cond)
import Models exposing (Msg(..))
import Models.Schema exposing (LayoutName, Schema)
import Models.Utils exposing (HtmlId, Text)
import Views.Bootstrap exposing (BsColor(..), Toggle(..), ariaHidden, ariaLabel, ariaLabelledBy, bsButton, bsDismiss)


viewModals : Schema -> LayoutName -> List (Html Msg)
viewModals schema newLayout =
    [ viewSchemaSwitchModal schema
    , viewCreateLayoutModal newLayout
    , viewHelpModal
    ]


viewSchemaSwitchModal : Schema -> Html Msg
viewSchemaSwitchModal schema =
    modal conf.ids.schemaSwitchModal
        (cond (Dict.isEmpty schema.tables) (\_ -> "Welcome to Schema Viz") (\_ -> "Load a new schema"))
        [ div []
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
        , bsButton Primary [ onClick LoadSampleData ] [ text "Or try our sample schema" ]
        ]
        [ p [ class "fw-lighter fst-italic text-muted" ]
            [ text "Schema Viz is an "
            , a [ href "https://github.com/loicknuchel/schema-viz", target "_blank" ] [ text "open source tool" ]
            , text " done by "
            , a [ href "https://twitter.com/sbouaked", target "_blank" ] [ text "@sbouaked" ]
            , text " and "
            , a [ href "https://twitter.com/loicknuchel", target "_blank" ] [ text "@loicknuchel" ]
            ]
        ]


viewCreateLayoutModal : LayoutName -> Html Msg
viewCreateLayoutModal newLayout =
    modal conf.ids.newLayoutModal
        "Save layout"
        [ div [ class "row g-3 align-items-center" ]
            [ div [ class "col-auto" ] [ label [ class "col-form-label", for "new-layout-name" ] [ text "Layout name" ] ]
            , div [ class "col-auto" ] [ input [ type_ "text", class "form-control", id "new-layout-name", value newLayout, onInput NewLayout, autofocus True ] [] ]
            ]
        ]
        [ button [ type_ "button", class "btn btn-secondary", bsDismiss Modal ] [ text "Cancel" ]
        , button [ type_ "button", class "btn btn-primary", bsDismiss Modal, disabled (newLayout == ""), onClick (CreateLayout newLayout) ] [ text "Save layout" ]
        ]


viewHelpModal : Html Msg
viewHelpModal =
    modal conf.ids.helpModal
        "Schema Viz cheatsheet"
        [ ul []
            [ li [] [ text "In ", bText "search", text ", you can look for tables and columns, then click on one to show it" ]
            , li [] [ text "Not connected relations on the left are ", bText "incoming foreign keys", text ". Click on the column icon to see tables referencing it and then show them" ]
            , li [] [ text "Not connected relations on the right are ", bText "column foreign keys", text ". Click on the column icon to show referenced table" ]
            , li [] [ text "You can ", bText "hide/show a column", text " with a ", codeText "double click", text " on it" ]
            , li [] [ text "You can ", bText "zoom in/out", text " using scrolling action, ", bText "move tables", text " around by dragging them or even ", bText "move everything", text " by dragging the background" ]
            ]
        ]
        [ button [ type_ "button", class "btn btn-primary", bsDismiss Modal ] [ text "Thanks!" ] ]


modal : HtmlId -> Text -> List (Html Msg) -> List (Html Msg) -> Html Msg
modal modalId title body footer =
    div [ id modalId, class "modal fade", tabindex -1, ariaLabelledBy (modalId ++ "-label"), ariaHidden True ]
        [ div [ class "modal-dialog modal-lg modal-dialog-centered modal-dialog-scrollable" ]
            [ div [ class "modal-content" ]
                [ div [ class "modal-header" ]
                    [ h5 [ class "modal-title", id (modalId ++ "-label") ] [ text title ]
                    , button [ type_ "button", class "btn-close", bsDismiss Modal, ariaLabel "Close" ] []
                    ]
                , div [ class "modal-body" ] body
                , div [ class "modal-footer" ] footer
                ]
            ]
        ]
