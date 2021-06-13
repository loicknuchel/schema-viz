module Views.Helpers exposing (..)

-- Helpers for views, can be included in any view, should not include anything from views

import Draggable
import Html exposing (Attribute)
import Html.Attributes exposing (style)
import Http exposing (Error(..))
import Libs.SchemaDecoders exposing (Table, TableId(..))
import Models exposing (DragId, Msg(..), Position, Size, SizedTable, UiTable, conf)


placeAt : Position -> Attribute msg
placeAt p =
    style "transform" ("translate(" ++ String.fromFloat p.left ++ "px, " ++ String.fromFloat p.top ++ "px)")


dragAttrs : DragId -> List (Attribute Msg)
dragAttrs id =
    Draggable.mouseTrigger id DragMsg :: Draggable.touchTriggers id DragMsg



-- data accessors


tableToSizedTable : Table -> SizedTable
tableToSizedTable table =
    SizedTable table.id table (Size 0 0)


sizedTableToUiTable : SizedTable -> UiTable
sizedTableToUiTable table =
    UiTable table.id table.sql table.size conf.colors.grey (Position 0 0)


tableToUiTable : Table -> UiTable
tableToUiTable table =
    sizedTableToUiTable (tableToSizedTable table)



-- formatters


formatTableId : TableId -> DragId
formatTableId (TableId id) =
    id


formatHttpError : Http.Error -> String
formatHttpError error =
    case error of
        BadUrl url ->
            "The URL " ++ url ++ " was invalid"

        Timeout ->
            "Unable to reach the server, try again"

        NetworkError ->
            "Unable to reach the server, check your network connection"

        BadStatus 500 ->
            "The server had a problem, try again later"

        BadStatus 400 ->
            "Verify your information and try again"

        BadStatus _ ->
            "Unknown error"

        BadBody errorMessage ->
            errorMessage
