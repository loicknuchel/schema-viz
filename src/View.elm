module View exposing (viewApp)

import Conf exposing (conf)
import Dict exposing (Dict)
import FontAwesome.Styles as Icon
import Html exposing (Attribute, Html, div)
import Html.Attributes exposing (class, id, style)
import Libs.Dict as D
import Libs.Html.Events exposing (onWheel)
import Libs.List as L
import Libs.Maybe as M
import Libs.Models exposing (HtmlId)
import Libs.Ned as Ned
import Models exposing (Model, Msg(..))
import Models.Schema exposing (ColumnRef, Layout, Relation, RelationRef, RelationTarget, Table, TableId, outgoingRelations, tableIdAsHtmlId)
import Models.Utils exposing (Position, Size, ZoomLevel)
import Views.Helpers exposing (dragAttrs, sizeAttrs)
import Views.Menu exposing (viewMenu)
import Views.Modals.Confirm exposing (viewConfirm)
import Views.Modals.CreateLayout exposing (viewCreateLayoutModal)
import Views.Modals.HelpInstructions exposing (viewHelpModal)
import Views.Modals.SchemaSwitch exposing (viewSchemaSwitchModal)
import Views.Navbar exposing (viewNavbar)
import Views.Relation exposing (viewRelation)
import Views.Table exposing (viewTable)



-- deps = { to = { only = [ "Libs.*", "Models.*", "Views.*", "Conf" ] } }
-- view entry point, can include any module from Views, Models or Libs


viewApp : Model -> List (Html Msg)
viewApp model =
    [ Icon.css ]
        ++ viewNavbar model.search (model.schema |> Maybe.map (\s -> ( ( s.tables, s.layout ), ( s.layoutName, s.layouts ) )))
        ++ viewMenu (model.schema |> Maybe.map (\s -> ( s.tables, s.incomingRelations )))
        ++ [ viewErd model.sizes (model.schema |> Maybe.map (\s -> ( s.tables, s.incomingRelations, s.layout ))) ]
        ++ [ viewSchemaSwitchModal model.time model.switch (model.schema |> Maybe.map (\_ -> "Schema Viz, easily explore your SQL schema!") |> Maybe.withDefault "Load a new schema") model.storedSchemas
           , viewCreateLayoutModal model.newLayout
           , viewHelpModal
           , viewConfirm model.confirm
           , viewToasts
           ]


viewErd : Dict HtmlId Size -> Maybe ( Dict TableId Table, Dict TableId (List RelationRef), Layout ) -> Html Msg
viewErd sizes schema =
    div ([ id conf.ids.erd, class "erd", onWheel OnWheel ] ++ sizeAttrs (sizes |> Dict.get conf.ids.erd |> Maybe.withDefault (Size 0 0)) ++ dragAttrs conf.ids.erd)
        [ div [ class "canvas", schema |> Maybe.map (\( _, _, layout ) -> placeAndZoom layout.canvas.zoom layout.canvas.position) |> Maybe.withDefault (placeAndZoom 1 (Position 0 0)) ]
            (schema
                |> Maybe.map
                    (\( tables, incomingRelations, layout ) ->
                        -- display all shown tables
                        (layout.tables
                            |> Dict.toList
                            |> L.filterZip (\( id, _ ) -> tables |> Dict.get id)
                            |> List.map (\( ( id, p ), t ) -> ( ( t, p ), ( incomingRelations |> D.getOrElse id [] |> buildRelations tables layout sizes, sizes |> Dict.get (tableIdAsHtmlId id) ) ))
                            |> List.map (\( ( table, props ), ( rels, size ) ) -> viewTable layout.canvas.zoom table props rels size)
                        )
                            -- display all incoming relations for shown tables
                            ++ (layout.tables
                                    |> Dict.toList
                                    |> List.filterMap (\( id, _ ) -> incomingRelations |> Dict.get id)
                                    |> List.concatMap (buildRelations tables layout sizes)
                                    |> List.map viewRelation
                               )
                            -- display outgoing relations of shown table which refer to a hidden table
                            ++ (layout.tables
                                    |> Dict.toList
                                    |> List.filterMap (\( id, _ ) -> tables |> Dict.get id)
                                    |> List.concatMap outgoingRelations
                                    |> List.filter (\r -> not (layout.tables |> Dict.member r.ref.table))
                                    |> List.filterMap (buildRelation tables layout sizes)
                                    |> List.map viewRelation
                               )
                    )
                |> Maybe.withDefault []
            )
        ]


viewToasts : Html Msg
viewToasts =
    div [ id "toast-container", class "toast-container position-fixed bottom-0 end-0 p-3" ] []



-- view helpers


placeAndZoom : ZoomLevel -> Position -> Attribute msg
placeAndZoom zoom pan =
    style "transform" ("translate(" ++ String.fromFloat pan.left ++ "px, " ++ String.fromFloat pan.top ++ "px) scale(" ++ String.fromFloat zoom ++ ")")


buildRelations : Dict TableId Table -> Layout -> Dict HtmlId Size -> List RelationRef -> List Relation
buildRelations tables layout sizes rels =
    rels |> List.filterMap (buildRelation tables layout sizes)


buildRelation : Dict TableId Table -> Layout -> Dict HtmlId Size -> RelationRef -> Maybe Relation
buildRelation tables layout sizes rel =
    Maybe.map2 (\src ref -> { key = rel.key, src = src, ref = ref })
        (buildRelationTarget tables layout sizes rel.src)
        (buildRelationTarget tables layout sizes rel.ref)


buildRelationTarget : Dict TableId Table -> Layout -> Dict HtmlId Size -> ColumnRef -> Maybe RelationTarget
buildRelationTarget tables layout sizes ref =
    (tables |> Dict.get ref.table |> M.andThenZip (\table -> table.columns |> Ned.get ref.column))
        |> Maybe.map (\( table, column ) -> { table = table, column = column, props = M.zip (layout.tables |> Dict.get ref.table) (sizes |> Dict.get (tableIdAsHtmlId ref.table)) })
