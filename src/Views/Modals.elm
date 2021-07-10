module Views.Modals exposing (viewConfirm, viewCreateLayoutModal, viewHelpModal, viewSchemaSwitchModal)

import AssocList as Dict
import Conf exposing (conf, schemaSamples)
import FileValue exposing (hiddenInputSingle)
import FontAwesome.Icon exposing (viewIcon)
import FontAwesome.Solid as Icon
import Html exposing (Html, a, br, button, div, h5, input, label, li, p, small, span, text, ul)
import Html.Attributes exposing (autofocus, class, disabled, for, href, id, style, tabindex, target, title, type_, value)
import Html.Events exposing (onClick, onInput)
import Libs.Std exposing (bText, codeText, cond, divIf, plural, role)
import Models exposing (Confirm, Msg(..), Switch, TimeInfo)
import Models.Schema exposing (LayoutName, Schema)
import Models.Utils exposing (HtmlId, Text)
import Time
import Views.Bootstrap exposing (BsColor(..), Toggle(..), ariaExpanded, ariaHidden, ariaLabel, ariaLabelledBy, bsBackdrop, bsButton, bsDismiss, bsKeyboard, bsToggle, bsToggleCollapseLink)
import Views.Helpers exposing (formatDate, onClickConfirm)


viewSchemaSwitchModal : TimeInfo -> Switch -> Schema -> List Schema -> Html Msg
viewSchemaSwitchModal time switch schema storedSchemas =
    modal conf.ids.schemaSwitchModal
        (cond (Dict.isEmpty schema.tables) (\_ -> "Schema Viz, easily explore your SQL schema!") (\_ -> "Load a new schema"))
        [ div [ style "text-align" "center" ] [ bText "⚠️ This app is currently being built", text ", you can use it but stored data may break sometimes ⚠️" ]
        , divIf (List.length storedSchemas > 0)
            [ class "row row-cols-1 row-cols-sm-2 row-cols-lg-3" ]
            (storedSchemas
                |> List.sortBy (\s -> negate (Time.posixToMillis s.info.updated))
                |> List.map
                    (\s ->
                        div [ class "col", style "margin-top" "1em" ]
                            [ div [ class "card h-100" ]
                                [ div [ class "card-body" ]
                                    [ h5 [ class "card-title" ] [ text s.name ]
                                    , p [ class "card-text" ]
                                        [ small [ class "text-muted" ]
                                            [ text (plural (List.length s.layouts) "No saved layout" "1 saved layout" "saved layouts")
                                            , br [] []
                                            , text ("Version from " ++ formatDate time (s.info.fileLastModified |> Maybe.withDefault s.info.created))
                                            ]
                                        ]
                                    ]
                                , div [ class "card-footer d-flex" ]
                                    [ a [ class "btn-text link-secondary me-auto", href "#", title "Delete this schema", bsToggle Tooltip, onClickConfirm ("You you really want to delete " ++ s.name ++ " schema ?") (DeleteSchema s) ] [ viewIcon Icon.trash ]
                                    , bsButton Primary [ onClick (UseSchema s) ] [ text "Use this schema" ]
                                    ]
                                ]
                            ]
                    )
            )
        , div [ style "margin-top" "1em" ]
            [ hiddenInputSingle "file-loader" [ ".sql,.json" ] FileSelected
            , label
                ([ for "file-loader", class "drop-zone" ]
                    ++ FileValue.onDrop
                        { onOver = FileDragOver
                        , onLeave = Just { id = "file-drop", msg = FileDragLeave }
                        , onDrop = FileDropped
                        }
                )
                [ if switch.loading then
                    span [ class "spinner-grow text-secondary", role "status" ] [ span [ class "visually-hidden" ] [ text "Loading..." ] ]

                  else
                    span [ class "title h5" ] [ text "Drop your schema here or click to browse" ]
                ]
            ]
        , div [ style "text-align" "center", style "margin-top" "1em" ]
            [ text "Or just try out with "
            , div [ class "dropdown", style "display" "inline-block" ]
                [ a [ id "schema-samples", href "#", bsToggle Dropdown, ariaExpanded False ] [ text "an example" ]
                , ul [ class "dropdown-menu", ariaLabelledBy "schema-samples" ]
                    (schemaSamples |> Dict.keys |> List.map (\name -> li [] [ a [ class "dropdown-item", href "#", onClick (LoadSampleData name) ] [ text name ] ]))
                ]
            ]
        , div [ style "margin-top" "1em" ]
            [ div [] [ a ([ class "text-muted" ] ++ bsToggleCollapseLink "get-schema-instructions") [ viewIcon Icon.angleRight, text " How to get my db schema ?" ] ]
            , div [ class "collapse", id "get-schema-instructions" ]
                [ div [ class "card card-body" ]
                    [ p [ class "card-text" ]
                        [ text "An "
                        , bText "SQL schema"
                        , text " is a SQL file with all the needed instructions to create your database, so it contains your database structure. Here are some ways to get it:"
                        , ul []
                            [ li [] [ bText "Export it", text " from your database: connect to your database using your favorite client and follow the instructions to extract the schema (ex: ", a [ href "https://stackoverflow.com/a/54504510/15051232" ] [ text "DBeaver" ], text ")" ]
                            , li [] [ bText "Find it", text " in your project: some frameworks like Rails store the schema in your project, so you may have it (ex: with Rails it's ", codeText "db/structure.sql", text " if you use the SQL version)" ]
                            ]
                        , text "If you have no idea on what I'm talking about just before, ask to the developers working on the project or your database administrator 😇"
                        ]
                    ]
                ]
            , div [] [ a ([ class "text-muted" ] ++ bsToggleCollapseLink "data-privacy") [ viewIcon Icon.angleRight, text " What about data privacy ?" ] ]
            , div [ class "collapse", id "data-privacy" ]
                [ div [ class "card card-body" ]
                    [ p [ class "card-text" ] [ text "Your application schema may be a sensitive information, but no worries with Schema Viz, everything stay on your machine. In fact, there is even no server at all!" ]
                    , p [ class "card-text" ] [ text "Your schema is read and ", bText "parsed in your browser", text ", and then saved with the layouts in your browser ", bText "local storage", text ". Nothing fancy ^^" ]
                    ]
                ]
            ]
        ]
        [ p [ class "fw-lighter fst-italic text-muted" ]
            [ bText "Schema Viz"
            , text " is an "
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


viewConfirm : Confirm -> Html Msg
viewConfirm confirm =
    div [ id conf.ids.confirm, class "modal fade", tabindex -1, bsBackdrop "static", bsKeyboard False, ariaLabelledBy (conf.ids.confirm ++ "-label"), ariaHidden True ]
        [ div [ class "modal-dialog modal-dialog-centered" ]
            [ div [ class "modal-content" ]
                [ div [ class "modal-header" ]
                    [ h5 [ class "modal-title", id (conf.ids.confirm ++ "-label") ] [ text "Confirm" ]
                    , button [ type_ "button", class "btn-close", bsDismiss Modal, ariaLabel "Close", onClick (OnConfirm False confirm.cmd) ] []
                    ]
                , div [ class "modal-body" ] [ confirm.content ]
                , div [ class "modal-footer" ]
                    [ button [ class "btn btn-secondary", bsDismiss Modal, onClick (OnConfirm False confirm.cmd) ] [ text "Cancel" ]
                    , button [ class "btn btn-primary", bsDismiss Modal, onClick (OnConfirm True confirm.cmd), autofocus True ] [ text "Ok" ]
                    ]
                ]
            ]
        ]


modal : HtmlId -> Text -> List (Html Msg) -> List (Html Msg) -> Html Msg
modal modalId title body footer =
    div [ id modalId, class "modal fade", tabindex -1, ariaLabelledBy (modalId ++ "-label"), ariaHidden True ]
        [ div [ class "modal-dialog modal-lg modal-dialog-scrollable" ]
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
