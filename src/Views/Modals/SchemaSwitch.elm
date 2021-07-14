module Views.Modals.SchemaSwitch exposing (viewSchemaSwitchModal)

import AssocList as Dict
import Conf exposing (conf, schemaSamples)
import FileValue exposing (hiddenInputSingle)
import FontAwesome.Icon exposing (viewIcon)
import FontAwesome.Solid as Icon
import Html exposing (Html, a, br, div, h5, label, li, p, small, span, text, ul)
import Html.Attributes exposing (class, for, href, id, style, target, title)
import Html.Events exposing (onClick)
import Libs.Bootstrap exposing (BsColor(..), Toggle(..), ariaExpanded, ariaLabelledBy, bsButton, bsModal, bsToggle, bsToggleCollapseLink)
import Libs.Html exposing (bText, codeText, divIf)
import Libs.Html.Attributes exposing (role)
import Libs.String as S
import Models exposing (Msg(..), Switch, TimeInfo)
import Models.Schema exposing (Schema)
import Time
import Views.Helpers exposing (formatDate, onClickConfirm)



-- deps = { to = { only = [ "Libs.*", "Models.*", "Conf", "Views.Helpers" ] } }


viewSchemaSwitchModal : TimeInfo -> Switch -> String -> List Schema -> Html Msg
viewSchemaSwitchModal time switch title storedSchemas =
    bsModal conf.ids.schemaSwitchModal
        title
        [ viewWarning
        , viewSavedSchemas time storedSchemas
        , viewFileUpload switch
        , viewSampleSchemas
        , div [ style "margin-top" "1em" ] (viewGetSchemaInstructions ++ viewDataPrivacyExplanation)
        ]
        [ viewFooter ]


viewWarning : Html msg
viewWarning =
    div [ style "text-align" "center" ] [ bText "⚠️ This app is currently being built", text ", you can use it but stored data may break sometimes ⚠️" ]


viewSavedSchemas : TimeInfo -> List Schema -> Html Msg
viewSavedSchemas time storedSchemas =
    divIf (List.length storedSchemas > 0)
        [ class "row row-cols-1 row-cols-sm-2 row-cols-lg-3" ]
        (storedSchemas
            |> List.sortBy (\s -> negate (Time.posixToMillis s.info.updated))
            |> List.map
                (\s ->
                    div [ class "col", style "margin-top" "1em" ]
                        [ div [ class "card h-100" ]
                            [ div [ class "card-body" ]
                                [ h5 [ class "card-title" ] [ text s.id ]
                                , p [ class "card-text" ]
                                    [ small [ class "text-muted" ]
                                        [ text (S.plural (Dict.size s.layouts) "No saved layout" "1 saved layout" "saved layouts")
                                        , br [] []
                                        , text ("Version from " ++ formatDate time (s.info.file |> Maybe.map .lastModified |> Maybe.withDefault s.info.created))
                                        ]
                                    ]
                                ]
                            , div [ class "card-footer d-flex" ]
                                [ a [ class "btn-text link-secondary me-auto", href "#", title "Delete this schema", bsToggle Tooltip, onClickConfirm ("You you really want to delete " ++ s.id ++ " schema ?") (DeleteSchema s) ] [ viewIcon Icon.trash ]
                                , bsButton Primary [ onClick (UseSchema s) ] [ text "Use this schema" ]
                                ]
                            ]
                        ]
                )
        )


viewFileUpload : Switch -> Html Msg
viewFileUpload switch =
    div [ style "margin-top" "1em" ]
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


viewSampleSchemas : Html Msg
viewSampleSchemas =
    div [ style "text-align" "center", style "margin-top" "1em" ]
        [ text "Or just try out with "
        , div [ class "dropdown", style "display" "inline-block" ]
            [ a [ id "schema-samples", href "#", bsToggle Dropdown, ariaExpanded False ] [ text "an example" ]
            , ul [ class "dropdown-menu", ariaLabelledBy "schema-samples" ]
                (schemaSamples |> Dict.keys |> List.map (\name -> li [] [ a [ class "dropdown-item", href "#", onClick (LoadSampleData name) ] [ text name ] ]))
            ]
        ]


viewGetSchemaInstructions : List (Html msg)
viewGetSchemaInstructions =
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
    ]


viewDataPrivacyExplanation : List (Html msg)
viewDataPrivacyExplanation =
    [ div [] [ a ([ class "text-muted" ] ++ bsToggleCollapseLink "data-privacy") [ viewIcon Icon.angleRight, text " What about data privacy ?" ] ]
    , div [ class "collapse", id "data-privacy" ]
        [ div [ class "card card-body" ]
            [ p [ class "card-text" ] [ text "Your application schema may be a sensitive information, but no worries with Schema Viz, everything stay on your machine. In fact, there is even no server at all!" ]
            , p [ class "card-text" ] [ text "Your schema is read and ", bText "parsed in your browser", text ", and then saved with the layouts in your browser ", bText "local storage", text ". Nothing fancy ^^" ]
            ]
        ]
    ]


viewFooter : Html msg
viewFooter =
    p [ class "fw-lighter fst-italic text-muted" ]
        [ bText "Schema Viz"
        , text " is an "
        , a [ href "https://github.com/loicknuchel/schema-viz", target "_blank" ] [ text "open source tool" ]
        , text " done by "
        , a [ href "https://twitter.com/sbouaked", target "_blank" ] [ text "@sbouaked" ]
        , text " and "
        , a [ href "https://twitter.com/loicknuchel", target "_blank" ] [ text "@loicknuchel" ]
        ]
