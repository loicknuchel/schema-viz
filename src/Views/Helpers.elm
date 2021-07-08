module Views.Helpers exposing (decodeErrorToHtml, dragAttrs, extractColumnIndex, extractColumnName, extractColumnType, formatColumnRef, formatHttpError, placeAt, sizeAttrs, withColumnName, withNullableInfo)

import Draggable
import Html exposing (Attribute)
import Html.Attributes exposing (height, style, width)
import Http exposing (Error(..))
import Json.Decode as Decode
import Models exposing (DragId, Msg(..))
import Models.Schema exposing (ColumnIndex(..), ColumnName(..), ColumnRef, ColumnType(..), formatTableId)
import Models.Utils exposing (Position, Size)



-- Helpers for views, can be included in any view, should not include anything from views


placeAt : Position -> Attribute msg
placeAt p =
    style "transform" ("translate(" ++ String.fromFloat p.left ++ "px, " ++ String.fromFloat p.top ++ "px)")


dragAttrs : DragId -> List (Attribute Msg)
dragAttrs id =
    Draggable.mouseTrigger id DragMsg :: Draggable.touchTriggers id DragMsg


sizeAttrs : Size -> List (Attribute Msg)
sizeAttrs size =
    [ width (round size.width), height (round size.height) ]



-- formatters


extractColumnIndex : ColumnIndex -> Int
extractColumnIndex (ColumnIndex index) =
    index


extractColumnName : ColumnName -> String
extractColumnName (ColumnName name) =
    name


extractColumnType : ColumnType -> String
extractColumnType (ColumnType kind) =
    kind


withColumnName : ColumnName -> String -> String
withColumnName (ColumnName column) table =
    table ++ "." ++ column


formatColumnRef : ColumnRef -> String
formatColumnRef ref =
    formatTableId ref.table |> withColumnName ref.column


withNullableInfo : Bool -> String -> String
withNullableInfo nullable text =
    if nullable then
        text ++ "?"

    else
        text


decodeErrorToHtml : Decode.Error -> String
decodeErrorToHtml error =
    "<pre>" ++ Decode.errorToString error ++ "</pre>"


formatHttpError : Http.Error -> String
formatHttpError error =
    case error of
        BadUrl url ->
            "the URL " ++ url ++ " was invalid"

        Timeout ->
            "unable to reach the server, try again"

        NetworkError ->
            "unable to reach the server, check your network connection"

        BadStatus 500 ->
            "the server had a problem, try again later"

        BadStatus 400 ->
            "verify your information and try again"

        BadStatus 404 ->
            "file does not exist"

        BadStatus status ->
            "network error (" ++ String.fromInt status ++ ")"

        BadBody errorMessage ->
            errorMessage
