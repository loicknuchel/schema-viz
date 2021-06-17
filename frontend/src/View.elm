module View exposing (viewApp)

import AssocList as Dict
import Html exposing (Attribute, Html, div, text)
import Html.Attributes exposing (class, style)
import Libs.Std exposing (handleWheel, listAddOn, listFilterMap)
import Models exposing (CanvasPosition, Menu, Msg(..), ZoomLevel, conf)
import Models.Schema exposing (Column, ForeignKey, Schema, Table)
import Views.Helpers exposing (dragAttrs)
import Views.Menu exposing (viewMenu)
import Views.Relations exposing (viewRelation)
import Views.Tables exposing (viewTable)



-- view entry point, can include any module from Views, Models or Libs


viewApp : Menu -> Schema -> Maybe String -> ZoomLevel -> CanvasPosition -> Html Msg
viewApp menu schema loading zoom pan =
    div [ class "app" ]
        (listAddOn loading
            (\msg -> div [ class "loading" ] [ text msg ])
            [ viewMenu menu schema
            , viewErd zoom pan schema
            ]
        )


viewErd : ZoomLevel -> CanvasPosition -> Schema -> Html Msg
viewErd zoom pan schema =
    div ([ class "erd", handleWheel Zoom ] ++ dragAttrs conf.ids.erd)
        [ div [ class "canvas", placeAndZoom zoom pan ]
            (listFilterMap visibleTable (viewTable zoom) (Dict.values schema.tables) ++ listFilterMap visibleRelation viewRelation schema.relations)
        ]



-- view helpers


placeAndZoom : ZoomLevel -> CanvasPosition -> Attribute msg
placeAndZoom zoom pan =
    style "transform" ("translate(" ++ String.fromFloat pan.left ++ "px, " ++ String.fromFloat pan.top ++ "px) scale(" ++ String.fromFloat zoom ++ ")")


visibleTable : Table -> Bool
visibleTable table =
    table.state.show


visibleRelation : ( ForeignKey, ( Table, Column ), ( Table, Column ) ) -> Bool
visibleRelation ( _, ( srcTable, _ ), ( refTable, _ ) ) =
    srcTable.state.show || refTable.state.show
