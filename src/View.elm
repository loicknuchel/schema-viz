module View exposing (viewApp)

import AssocList as Dict exposing (Dict)
import Conf exposing (conf)
import FontAwesome.Styles as Icon
import Html exposing (Attribute, Html, div)
import Html.Attributes exposing (class, id, style)
import Libs.Html.Events exposing (onWheel)
import Libs.List as L
import Libs.Maybe as M
import Libs.Models exposing (HtmlId)
import Models exposing (Model, Msg(..))
import Models.Schema exposing (ColumnName, ColumnRef, Layout, Relation, RelationRef, RelationTarget, Schema, Table, TableId, tableIdAsHtmlId)
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
        ++ viewNavbar model.search model.schema
        ++ viewMenu model.schema
        ++ [ viewErd model.sizes model.schema ]
        ++ [ viewSchemaSwitchModal model.time model.switch (model.schema |> Maybe.map (\_ -> "Schema Viz, easily explore your SQL schema!") |> Maybe.withDefault "Load a new schema") model.storedSchemas
           , viewCreateLayoutModal model.newLayout
           , viewHelpModal
           , viewConfirm model.confirm
           , viewToasts
           ]


viewErd : Dict HtmlId Size -> Maybe Schema -> Html Msg
viewErd sizes schema =
    let
        relations : List Relation
        relations =
            schema |> Maybe.map (\s -> s.relations |> List.filterMap (buildRelation s.tables s.layout sizes)) |> Maybe.withDefault []
    in
    div ([ id conf.ids.erd, class "erd", onWheel OnWheel ] ++ sizeAttrs (sizes |> Dict.get conf.ids.erd |> Maybe.withDefault (Size 0 0)) ++ dragAttrs conf.ids.erd)
        [ div [ class "canvas", schema |> Maybe.map (\s -> placeAndZoom s.layout.canvas.zoom s.layout.canvas.position) |> Maybe.withDefault (placeAndZoom 1 (Position 0 0)) ]
            (schema
                |> Maybe.map
                    (\s ->
                        (s.tables
                            |> Dict.values
                            |> L.filterZip (\t -> (s.layout.tables |> Dict.get t.id) |> Maybe.map (\p -> ( p, sizes |> Dict.get (tableIdAsHtmlId t.id) )))
                            |> List.map (\( t, ( p, size ) ) -> viewTable s.layout.canvas.zoom (incomingTableRelations relations t) t p size)
                        )
                            ++ (relations |> L.filterMap (shouldDrawRelation s.layout) viewRelation)
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


shouldDrawRelation : Layout -> Relation -> Bool
shouldDrawRelation layout relation =
    relation.state.show && (isShown relation.src layout || isShown relation.ref layout)


isShown : RelationTarget -> Layout -> Bool
isShown ref layout =
    isColumnShown ref.table.id ref.column.column layout


isColumnShown : TableId -> ColumnName -> Layout -> Bool
isColumnShown table column layout =
    layout.tables |> Dict.get table |> Maybe.map (\t -> t.columns |> List.any (\c -> c == column)) |> Maybe.withDefault False


incomingTableRelations : List Relation -> Table -> List Relation
incomingTableRelations relations table =
    relations |> List.filter (\r -> r.ref.table.id == table.id)


buildRelation : Dict TableId Table -> Layout -> Dict HtmlId Size -> RelationRef -> Maybe Relation
buildRelation tables layout sizes rel =
    Maybe.map2 (\src ref -> { key = rel.key, src = src, ref = ref, state = rel.state })
        (buildRelationTarget tables layout sizes rel.src)
        (buildRelationTarget tables layout sizes rel.ref)


buildRelationTarget : Dict TableId Table -> Layout -> Dict HtmlId Size -> ColumnRef -> Maybe RelationTarget
buildRelationTarget tables layout sizes ref =
    (tables |> Dict.get ref.table |> M.andThenZip (\table -> table.columns |> Dict.get ref.column))
        |> Maybe.map (\( table, column ) -> { table = table, column = column, props = M.zip (layout.tables |> Dict.get ref.table) (sizes |> Dict.get (tableIdAsHtmlId ref.table)) })
