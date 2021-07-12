module View exposing (viewApp)

import AssocList as Dict
import Conf exposing (conf)
import FontAwesome.Styles as Icon
import Html exposing (Attribute, Html, div)
import Html.Attributes exposing (class, id, style)
import Libs.Html.Events exposing (onWheel)
import Libs.List as L
import Models exposing (Canvas, Model, Msg(..))
import Models.Schema exposing (ColumnRef, Relation, RelationRef, Schema, Table, TableAndColumn, TableStatus(..), Tables)
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



-- deps = { to = { only = [ "Libs.*", "Models.*", "Views.*", "Conf" ] } }
-- view entry point, can include any module from Views, Models or Libs


viewApp : Model -> List (Html Msg)
viewApp model =
    [ Icon.css ]
        ++ viewNavbar model.state.search model.schema
        ++ viewMenu model.schema
        ++ [ viewErd model.canvas model.schema ]
        ++ [ viewSchemaSwitchModal model.time model.switch (model.schema |> Maybe.map (\_ -> "Schema Viz, easily explore your SQL schema!") |> Maybe.withDefault "Load a new schema") model.storedSchemas
           , viewCreateLayoutModal (model.state.newLayout |> Maybe.withDefault "")
           , viewHelpModal
           , viewConfirm model.confirm
           , viewToasts
           ]


viewErd : Canvas -> Maybe Schema -> Html Msg
viewErd canvas schema =
    let
        relations : List Relation
        relations =
            schema |> Maybe.map (\s -> s.relations |> List.filterMap (buildRelation s.tables)) |> Maybe.withDefault []
    in
    div ([ id conf.ids.erd, class "erd", onWheel Zoom ] ++ sizeAttrs canvas.size ++ dragAttrs conf.ids.erd)
        [ div [ class "canvas", schema |> Maybe.map (\s -> placeAndZoom s.state.zoom s.state.position) |> Maybe.withDefault (placeAndZoom 1 (Position 0 0)) ]
            ((schema |> Maybe.map .tables |> Maybe.map Dict.values |> Maybe.withDefault [] |> L.filterMap shouldDrawTable (\t -> viewTable (schema |> Maybe.map (\s -> s.state.zoom) |> Maybe.withDefault 1) (incomingTableRelations relations t) t))
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


buildRelation : Tables -> RelationRef -> Maybe Relation
buildRelation tables rel =
    Maybe.map2 (\from to -> { key = rel.key, src = from, ref = to, state = rel.state }) (getTableAndColumn rel.src tables) (getTableAndColumn rel.ref tables)


getTableAndColumn : ColumnRef -> Tables -> Maybe TableAndColumn
getTableAndColumn ref tables =
    tables |> Dict.get ref.table |> Maybe.andThen (\table -> table.columns |> Dict.get ref.column |> Maybe.map (\column -> { table = table, column = column }))
