module Views.Helpers exposing (columnRefAsHtmlId, dragAttrs, extractColumnName, extractColumnType, formatDate, humanDatetime, onClickConfirm, placeAt, sizeAttrs, withColumnName, withNullableInfo)

import Draggable
import Html exposing (Attribute, Html, span, text)
import Html.Attributes exposing (height, style, title, width)
import Html.Events exposing (onClick)
import Libs.Bootstrap exposing (Toggle(..), bsToggle)
import Libs.DateTime as DateTime
import Libs.Models exposing (HtmlId)
import Libs.Task as T
import Models exposing (DragId, Msg(..), TimeInfo)
import Models.Schema exposing (ColumnName, ColumnRef, ColumnType(..), tableIdAsHtmlId)
import Models.Utils exposing (Position, Size)
import Time



-- deps = { to = { only = [ "Libs.*", "Models.*", "Conf" ] } }


placeAt : Position -> Attribute msg
placeAt p =
    style "transform" ("translate(" ++ String.fromFloat p.left ++ "px, " ++ String.fromFloat p.top ++ "px)")


dragAttrs : DragId -> List (Attribute Msg)
dragAttrs id =
    Draggable.mouseTrigger id DragMsg :: Draggable.touchTriggers id DragMsg


sizeAttrs : Size -> List (Attribute Msg)
sizeAttrs size =
    [ width (round size.width), height (round size.height) ]


onClickConfirm : String -> Msg -> Attribute Msg
onClickConfirm content msg =
    onClick (OpenConfirm { content = text content, cmd = T.send msg })



-- formatters


extractColumnName : ColumnName -> String
extractColumnName name =
    name


extractColumnType : ColumnType -> String
extractColumnType (ColumnType kind) =
    kind


withColumnName : ColumnName -> String -> String
withColumnName column table =
    table ++ "." ++ column


columnRefAsHtmlId : ColumnRef -> HtmlId
columnRefAsHtmlId ref =
    tableIdAsHtmlId ref.table |> withColumnName ref.column


withNullableInfo : Bool -> String -> String
withNullableInfo nullable text =
    if nullable then
        text ++ "?"

    else
        text


formatDate : TimeInfo -> Time.Posix -> String
formatDate info date =
    DateTime.format "dd MMM yyyy" info.zone date


humanDatetime : TimeInfo -> Time.Posix -> Html msg
humanDatetime info date =
    span [ title (DateTime.format "dd MMM yyyy HH:mm" info.zone date), bsToggle Tooltip ] [ text (DateTime.human info.now date) ]
