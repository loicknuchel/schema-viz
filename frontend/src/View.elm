module View exposing (viewApp)

import AssocList as Dict exposing (Dict)
import Html exposing (Attribute, Html, div, text)
import Html.Attributes exposing (class, style)
import Libs.SchemaDecoders exposing (PrimaryKey(..), TableId)
import Libs.Std exposing (handleWheel, maybeFold)
import Models exposing (CanvasPosition, Menu, Msg(..), Position, UiTable, ZoomLevel)
import Views.Helpers exposing (dragAttrs, placeAt)
import Views.Relations exposing (getRelations, viewRelation)
import Views.Tables exposing (viewTable)



-- view entry point, can include any module from Views, Models or Libs


viewApp : ZoomLevel -> CanvasPosition -> Maybe Menu -> Dict TableId UiTable -> Html Msg
viewApp zoom pan menu tables =
    div [ class "app" ]
        [ viewMenu menu
        , viewErd zoom pan tables
        ]


viewMenu : Maybe Menu -> Html Msg
viewMenu menu =
    div ([ class "menu", placeAt (maybeFold (Position 0 0) .position menu) ] ++ maybeFold [] (\m -> dragAttrs m.id) menu)
        [ text "menu" ]


viewErd : ZoomLevel -> CanvasPosition -> Dict TableId UiTable -> Html Msg
viewErd zoom pan tables =
    div ([ class "erd", handleWheel Zoom ] ++ dragAttrs "erd")
        [ div [ class "canvas", placeAndZoom zoom pan ] (List.map viewTable (Dict.values tables) ++ List.map viewRelation (getRelations tables)) ]



-- view helpers


placeAndZoom : ZoomLevel -> CanvasPosition -> Attribute msg
placeAndZoom zoom pan =
    style "transform" ("translate(" ++ String.fromFloat pan.left ++ "px, " ++ String.fromFloat pan.top ++ "px) scale(" ++ String.fromFloat zoom ++ ")")
