module View exposing (viewApp)

import AssocList as Dict
import Conf exposing (conf)
import FontAwesome.Styles as Icon
import Html exposing (Attribute, Html, div)
import Html.Attributes exposing (class, id, style)
import Libs.Bool as B
import Libs.Html.Events exposing (onWheel)
import Libs.List as L
import Models exposing (Canvas, Model, Msg(..))
import Models.Schema exposing (ColumnRef, Relation, RelationRef, Schema, Table, TableAndColumn, TableStatus(..))
import Models.Utils exposing (Position, ZoomLevel)
import Views.Helpers exposing (dragAttrs, sizeAttrs)
import Views.Menu exposing (viewMenu)
import Views.Modals.Confirm exposing (viewConfirm)
import Views.Modals.CreateLayout exposing (viewCreateLayoutModal)
import Views.Modals.HelpInstructions exposing (viewHelpModal)
import Views.Modals.SchemaSwitch exposing (viewSchemaSwitchModal)
import Views.Navbar exposing (viewNavbar)
import Views.Relation exposing (viewRelation)
import Views.Table exposing (viewTable)



-- view entry point, can include any module from Views, Models or Libs


viewApp : Model -> List (Html Msg)
viewApp model =
    [ Icon.css ]
        ++ viewNavbar model.state.search model.state.currentLayout model.schema
        ++ viewMenu model.schema
        ++ [ viewErd model.canvas model.schema ]
        ++ [ viewSchemaSwitchModal model.time model.switch (B.cond (Dict.isEmpty model.schema.tables) "Schema Viz, easily explore your SQL schema!" "Load a new schema") model.storedSchemas
           , viewCreateLayoutModal (model.state.newLayout |> Maybe.withDefault "")
           , viewHelpModal
           , viewConfirm model.confirm
           , viewToasts
           ]


viewErd : Canvas -> Schema -> Html Msg
viewErd canvas schema =
    let
        relations : List Relation
        relations =
            schema.relations |> List.filterMap (buildRelation schema)
    in
    div ([ id conf.ids.erd, class "erd", onWheel Zoom ] ++ sizeAttrs canvas.size ++ dragAttrs conf.ids.erd)
        [ div [ class "canvas", placeAndZoom canvas.zoom canvas.position ]
            ((schema.tables |> Dict.values |> L.filterMap shouldDrawTable (\t -> viewTable canvas.zoom (incomingTableRelations relations t) t))
                ++ (relations |> L.filterMap shouldDrawRelation viewRelation)
            )
        ]


viewToasts : Html Msg
viewToasts =
    div [ id "toast-container", class "toast-container position-fixed bottom-0 end-0 p-3" ] []



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
    relation.state.show
        && (case ( relation.src.table.state.status, relation.ref.table.state.status ) of
                ( Shown, Shown ) ->
                    not (relation.src.column.state.order == Nothing) && not (relation.ref.column.state.order == Nothing)

                ( Shown, _ ) ->
                    not (relation.src.column.state.order == Nothing)

                ( _, Shown ) ->
                    not (relation.ref.column.state.order == Nothing)

                _ ->
                    False
           )


incomingTableRelations : List Relation -> Table -> List Relation
incomingTableRelations relations table =
    relations |> List.filter (\r -> r.ref.table.id == table.id)


buildRelation : Schema -> RelationRef -> Maybe Relation
buildRelation schema rel =
    Maybe.map2 (\from to -> { key = rel.key, src = from, ref = to, state = rel.state }) (getTableAndColumn rel.src schema) (getTableAndColumn rel.ref schema)


getTableAndColumn : ColumnRef -> Schema -> Maybe TableAndColumn
getTableAndColumn ref schema =
    schema.tables |> Dict.get ref.table |> Maybe.andThen (\table -> table.columns |> Dict.get ref.column |> Maybe.map (\column -> { table = table, column = column }))
