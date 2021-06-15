module View exposing (viewApp)

import AssocList as Dict
import Html exposing (Attribute, Html, div)
import Html.Attributes exposing (class, style)
import Libs.Std exposing (handleWheel)
import Models exposing (CanvasPosition, Menu, Msg(..), ZoomLevel, conf)
import Models.Schema exposing (Schema)
import Views.Helpers exposing (dragAttrs)
import Views.Menu exposing (viewMenu)
import Views.Relations exposing (viewRelation)
import Views.Tables exposing (viewTable)



-- view entry point, can include any module from Views, Models or Libs


viewApp : ZoomLevel -> CanvasPosition -> Menu -> Schema -> Html Msg
viewApp zoom pan menu schema =
    div [ class "app" ]
        [ viewMenu menu schema.tables
        , viewErd zoom pan schema
        ]


viewErd : ZoomLevel -> CanvasPosition -> Schema -> Html Msg
viewErd zoom pan schema =
    div ([ class "erd", handleWheel Zoom ] ++ dragAttrs conf.ids.erd)
        [ div [ class "canvas", placeAndZoom zoom pan ]
            (List.map viewTable (List.filter (\t -> t.state.show) (Dict.values schema.tables)) ++ List.map viewRelation schema.relations)
        ]



-- view helpers


placeAndZoom : ZoomLevel -> CanvasPosition -> Attribute msg
placeAndZoom zoom pan =
    style "transform" ("translate(" ++ String.fromFloat pan.left ++ "px, " ++ String.fromFloat pan.top ++ "px) scale(" ++ String.fromFloat zoom ++ ")")
