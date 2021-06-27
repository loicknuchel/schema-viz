module View exposing (viewApp)

import AssocList as Dict
import Conf exposing (conf)
import Html exposing (Attribute, Html, div, text)
import Html.Attributes exposing (class, id, style)
import Libs.Std exposing (handleWheel, listAppendOn, listFilterMap)
import Models exposing (Canvas, Model, Msg(..))
import Models.Schema exposing (ColumnRef, Relation, RelationRef, Schema, Table, TableAndColumn, TableStatus(..))
import Models.Utils exposing (Position, ZoomLevel)
import Views.Helpers exposing (dragAttrs, sizeAttrs)
import Views.Menu exposing (viewMenu)
import Views.Navbar exposing (viewNavbar)
import Views.Relations exposing (viewRelation)
import Views.Tables exposing (viewTable)



-- view entry point, can include any module from Views, Models or Libs


viewApp : Model -> Maybe String -> Html Msg
viewApp model loading =
    div [ class "app" ]
        (listAppendOn loading
            (\msg -> div [ class "loading" ] [ text msg ])
            [ viewNavbar model.state.search (Dict.values model.schema.tables)
            , viewMenu model.schema
            , viewErd model.canvas model.schema
            ]
        )


viewErd : Canvas -> Schema -> Html Msg
viewErd canvas schema =
    let
        relations : List Relation
        relations =
            List.filterMap (buildRelation schema) schema.relations
    in
    div ([ class "erd", id conf.ids.erd, handleWheel Zoom ] ++ sizeAttrs canvas.size ++ dragAttrs conf.ids.erd)
        [ div [ class "canvas", placeAndZoom canvas.zoom canvas.position ]
            (listFilterMap shouldDrawTable (\t -> viewTable canvas.zoom (incomingTableRelations relations t) t) (Dict.values schema.tables)
                ++ listFilterMap shouldDrawRelation viewRelation relations
            )
        ]



-- view helpers


placeAndZoom : ZoomLevel -> Position -> Attribute msg
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


incomingTableRelations : List Relation -> Table -> List Relation
incomingTableRelations relations table =
    List.filter (\r -> r.ref.table.id == table.id) relations


buildRelation : Schema -> RelationRef -> Maybe Relation
buildRelation schema rel =
    Maybe.map2 (\from to -> { key = rel.key, src = from, ref = to, state = rel.state }) (getTableAndColumn rel.src schema) (getTableAndColumn rel.ref schema)


getTableAndColumn : ColumnRef -> Schema -> Maybe TableAndColumn
getTableAndColumn ref schema =
    Maybe.andThen (\table -> Maybe.map (\column -> { table = table, column = column }) (Dict.get ref.column table.columns)) (Dict.get ref.table schema.tables)
