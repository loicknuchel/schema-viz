module View exposing (viewApp)

import AssocList as Dict
import Html exposing (Attribute, Html, div, text)
import Html.Attributes exposing (class, style)
import Libs.Std exposing (handleWheel, maybeFold)
import Models exposing (CanvasPosition, Menu, Msg(..), ZoomLevel, conf)
import Models.Schema exposing (Schema)
import Models.Utils exposing (Position)
import Views.Helpers exposing (dragAttrs, placeAt)
import Views.Relations exposing (viewRelation)
import Views.Tables exposing (viewTable)



-- view entry point, can include any module from Views, Models or Libs


viewApp : ZoomLevel -> CanvasPosition -> Maybe Menu -> Schema -> Html Msg
viewApp zoom pan menu schema =
    div [ class "app" ]
        [ viewMenu menu
        , viewErd zoom pan schema
        ]


viewMenu : Maybe Menu -> Html Msg
viewMenu menu =
    div ([ class "menu", placeAt (maybeFold (Position 0 0) .position menu) ] ++ maybeFold [] (\_ -> dragAttrs conf.ids.menu) menu)
        [ text "menu" ]


viewErd : ZoomLevel -> CanvasPosition -> Schema -> Html Msg
viewErd zoom pan schema =
    div ([ class "erd", handleWheel Zoom ] ++ dragAttrs conf.ids.erd)
        [ div [ class "canvas", placeAndZoom zoom pan ] (List.map viewTable (Dict.values schema.tables) ++ List.map viewRelation schema.relations) ]



-- view helpers


placeAndZoom : ZoomLevel -> CanvasPosition -> Attribute msg
placeAndZoom zoom pan =
    style "transform" ("translate(" ++ String.fromFloat pan.left ++ "px, " ++ String.fromFloat pan.top ++ "px) scale(" ++ String.fromFloat zoom ++ ")")
