module PagesComponents.App.Views.Erd exposing (viewErd)

import Conf exposing (conf)
import Dict exposing (Dict)
import Html exposing (Attribute, Html, div)
import Html.Attributes exposing (class, id, style)
import Libs.Html.Events exposing (onWheel)
import Libs.List as L
import Libs.Maybe as M
import Libs.Models exposing (HtmlId, ZoomLevel)
import Libs.Ned as Ned
import Libs.Nel as Nel exposing (Nel)
import Libs.Position exposing (Position)
import Libs.Size exposing (Size)
import Models.Schema exposing (ColumnRef, Layout, Relation, RelationRef, RelationTarget, Table, TableId, outgoingRelations, tableIdAsHtmlId, viewportSize)
import PagesComponents.App.Models exposing (Hover, Msg(..))
import PagesComponents.App.Views.Erd.Relation exposing (viewRelation)
import PagesComponents.App.Views.Erd.Table exposing (viewTable)
import PagesComponents.App.Views.Helpers exposing (dragAttrs, sizeAttr)


viewErd : Hover -> Dict HtmlId Size -> Maybe ( Dict TableId Table, Dict TableId (Nel RelationRef), Layout ) -> Html Msg
viewErd hover sizes schema =
    div ([ id conf.ids.erd, class "erd", sizeAttr (viewportSize sizes |> Maybe.withDefault (Size 0 0)), onWheel OnWheel ] ++ dragAttrs conf.ids.erd)
        [ div [ class "canvas", schema |> Maybe.map (\( _, _, layout ) -> placeAndZoom layout.canvas.zoom layout.canvas.position) |> Maybe.withDefault (placeAndZoom 1 (Position 0 0)) ]
            (schema
                |> Maybe.map
                    (\( tables, incomingRelations, layout ) ->
                        -- display all shown tables
                        (layout.tables
                            |> List.reverse
                            |> L.filterZip (\t -> tables |> Dict.get t.id)
                            |> List.map (\( p, t ) -> ( ( t, p ), ( incomingRelations |> Dict.get p.id |> buildRelations tables layout sizes, sizes |> Dict.get (tableIdAsHtmlId p.id) ) ))
                            |> List.map (\( ( table, props ), ( rels, size ) ) -> viewTable hover layout.canvas.zoom table props rels size)
                        )
                            -- display all incoming relations for shown tables
                            ++ (layout.tables
                                    |> List.map (\t -> incomingRelations |> Dict.get t.id)
                                    |> List.concatMap (buildRelations tables layout sizes)
                                    |> List.map (viewRelation hover)
                               )
                            -- display outgoing relations of shown table which refer to a hidden table
                            ++ (layout.tables
                                    |> List.filterMap (\t -> tables |> Dict.get t.id)
                                    |> List.concatMap outgoingRelations
                                    |> List.filter (\r -> not (layout.tables |> L.memberBy .id r.ref.table))
                                    |> List.filterMap (buildRelation tables layout sizes)
                                    |> List.map (viewRelation hover)
                               )
                    )
                |> Maybe.withDefault []
            )
        ]


placeAndZoom : ZoomLevel -> Position -> Attribute msg
placeAndZoom zoom pan =
    style "transform" ("translate(" ++ String.fromFloat pan.left ++ "px, " ++ String.fromFloat pan.top ++ "px) scale(" ++ String.fromFloat zoom ++ ")")


buildRelations : Dict TableId Table -> Layout -> Dict HtmlId Size -> Maybe (Nel RelationRef) -> List Relation
buildRelations tables layout sizes rels =
    rels |> Maybe.map Nel.toList |> Maybe.withDefault [] |> List.filterMap (buildRelation tables layout sizes)


buildRelation : Dict TableId Table -> Layout -> Dict HtmlId Size -> RelationRef -> Maybe Relation
buildRelation tables layout sizes rel =
    Maybe.map2 (\src ref -> { key = rel.key, src = src, ref = ref })
        (buildRelationTarget tables layout sizes rel.src)
        (buildRelationTarget tables layout sizes rel.ref)


buildRelationTarget : Dict TableId Table -> Layout -> Dict HtmlId Size -> ColumnRef -> Maybe RelationTarget
buildRelationTarget tables layout sizes ref =
    (tables |> Dict.get ref.table |> M.andThenZip (\table -> table.columns |> Ned.get ref.column))
        |> Maybe.map (\( table, column ) -> { ref = ref, table = table, column = column, props = M.zip (layout.tables |> L.findBy .id ref.table) (sizes |> Dict.get (tableIdAsHtmlId ref.table)) })
