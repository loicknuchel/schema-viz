module View exposing (viewApp)

import AssocList as Dict
import Html exposing (Attribute, Html, div, text)
import Html.Attributes exposing (class, id, style)
import Libs.Std exposing (handleWheel, listAddOn, listFilterMap)
import Models exposing (CanvasPosition, Model, Msg(..), ZoomLevel, conf)
import Models.Schema exposing (ColumnRef, Relation, RelationRef, Schema, Table, TableAndColumn, TableStatus(..))
import Views.Helpers exposing (dragAttrs)
import Views.Menu exposing (viewMenu)
import Views.Relations exposing (viewRelation)
import Views.Tables exposing (viewTable)



-- view entry point, can include any module from Views, Models or Libs


viewApp : Model -> Maybe String -> Html Msg
viewApp model loading =
    div [ class "app" ]
        (listAddOn loading
            (\msg -> div [ class "loading" ] [ text msg ])
            [ viewMenu model.menu model.schema
            , viewErd model.state.zoom model.state.position model.schema
            ]
        )


viewErd : ZoomLevel -> CanvasPosition -> Schema -> Html Msg
viewErd zoom pan schema =
    div ([ class "erd", id "erd", handleWheel Zoom ] ++ dragAttrs conf.ids.erd)
        [ div [ class "canvas", placeAndZoom zoom pan ]
            (listFilterMap shouldDrawTable (viewTable zoom) (Dict.values schema.tables)
                ++ listFilterMap shouldDrawRelation viewRelation (List.filterMap (buildRelation schema) schema.relations)
            )
        ]



-- view helpers


placeAndZoom : ZoomLevel -> CanvasPosition -> Attribute msg
placeAndZoom zoom pan =
    style "transform" ("translate(" ++ String.fromFloat pan.left ++ "px, " ++ String.fromFloat pan.top ++ "px) scale(" ++ String.fromFloat zoom ++ ")")


shouldDrawTable : Table -> Bool
shouldDrawTable table =
    case table.state.status of
        Uninitialized ->
            False

        Hidden ->
            False

        Initializing ->
            True

        Shown ->
            True


shouldDrawRelation : Relation -> Bool
shouldDrawRelation relation =
    relation.state.show && (relation.src.table.state.status == Shown || relation.ref.table.state.status == Shown)


buildRelation : Schema -> RelationRef -> Maybe Relation
buildRelation schema rel =
    Maybe.map2 (\from to -> { key = rel.key, src = from, ref = to, state = rel.state }) (getTableAndColumn rel.src schema) (getTableAndColumn rel.ref schema)


getTableAndColumn : ColumnRef -> Schema -> Maybe TableAndColumn
getTableAndColumn ref schema =
    Maybe.andThen (\table -> Maybe.map (\column -> { table = table, column = column }) (Dict.get ref.column table.columns)) (Dict.get ref.table schema.tables)
