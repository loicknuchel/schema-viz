module Views.Helpers exposing (dragAttrs, formatHttpError, formatTableId, formatTableName, placeAt, sizeAttrs)

import Draggable
import Html exposing (Attribute)
import Html.Attributes exposing (attribute, style)
import Http exposing (Error(..))
import Models exposing (DragId, Msg(..), conf)
import Models.Schema exposing (SchemaName(..), Table, TableId(..), TableName(..))
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
    [ attribute "width" (String.fromFloat size.width), attribute "height" (String.fromFloat size.height) ]



-- formatters


formatTableId : TableId -> DragId
formatTableId (TableId id) =
    id


formatTableName : Table -> String
formatTableName table =
    case ( table.schema, table.table ) of
        ( SchemaName schema, TableName name ) ->
            if schema == conf.defaultSchema then
                name

            else
                schema ++ "." ++ name


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
