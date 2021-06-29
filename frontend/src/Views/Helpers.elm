module Views.Helpers exposing (dragAttrs, extractColumnIndex, extractColumnName, extractColumnType, formatHttpError, formatTableId, formatTableName, parseTableId, placeAt, sizeAttrs, withColumnName, withNullableInfo)

import Conf exposing (conf)
import Draggable
import Html exposing (Attribute)
import Html.Attributes exposing (height, style, width)
import Http exposing (Error(..))
import Models exposing (DragId, Msg(..))
import Models.Schema exposing (ColumnIndex(..), ColumnName(..), ColumnType(..), SchemaName(..), TableId(..), TableName(..))
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


formatTableId : TableId -> String
formatTableId (TableId schema table) =
    formatTableName table schema


parseTableId : String -> TableId
parseTableId id =
    case String.split "." id of
        schema :: table :: [] ->
            TableId (SchemaName schema) (TableName table)

        _ ->
            TableId (SchemaName conf.defaultSchema) (TableName id)


formatTableName : TableName -> SchemaName -> String
formatTableName (TableName table) (SchemaName schema) =
    if schema == conf.defaultSchema then
        table

    else
        schema ++ "." ++ table


withColumnName : ColumnName -> String -> String
withColumnName (ColumnName column) table =
    table ++ "." ++ column


withNullableInfo : Bool -> String -> String
withNullableInfo nullable text =
    if nullable then
        text ++ "?"

    else
        text


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
