module View exposing (..)

import Draggable
import Html exposing (Attribute, Html, div, li, text, ul)
import Html.Attributes exposing (class, id, style)
import Http exposing (Error(..))
import Libs.SchemaDecoders exposing (Column, ColumnName(..), ColumnType(..), SchemaName(..), Table, TableName(..))
import Libs.Std exposing (maybeFold)
import Models exposing (DragId, Menu, Msg(..), Position, Size, SizedTable, UiTable, colors)


viewApp : Maybe Menu -> List UiTable -> Html Msg
viewApp menu tables =
    div [ class "app" ]
        [ viewMenu menu
        , viewErd tables
        ]


viewMenu : Maybe Menu -> Html Msg
viewMenu menu =
    div ([ class "menu", placeAt (maybeFold (Position 0 0) .position menu) ] ++ maybeFold [] (\m -> dragAttrs m.id) menu)
        [ text "menu" ]


viewErd : List UiTable -> Html Msg
viewErd tables =
    div [ class "erd" ] (List.map viewTable tables)


viewTable : UiTable -> Html Msg
viewTable table =
    div ([ class "table", placeAt table.position, id (formatTableId table.sql), borderColor table.color ] ++ dragAttrs table.id)
        [ div [ class "header" ] [ text (formatTableName table.sql) ]
        , ul [ class "columns" ] (List.map viewColumn table.sql.columns)
        ]


viewColumn : Column -> Html Msg
viewColumn column =
    li [ class "column" ] [ text (formatColumnName column ++ " " ++ formatColumnType column) ]



-- helpers


placeAt : Position -> Attribute msg
placeAt p =
    style "transform" ("translate(" ++ String.fromFloat p.left ++ "px, " ++ String.fromFloat p.top ++ "px)")


borderColor : String -> Attribute msg
borderColor color =
    style "border-color" color


dragAttrs : DragId -> List (Attribute Msg)
dragAttrs id =
    style "cursor" "pointer" :: Draggable.mouseTrigger id DragMsg :: Draggable.touchTriggers id DragMsg


tableToUiTable : Table -> UiTable
tableToUiTable table =
    UiTable (formatTableId table) table (Size 0 0) colors.grey (Position 0 0)


sizedTableToUiTable : SizedTable -> UiTable
sizedTableToUiTable table =
    UiTable table.id table.sql table.size colors.grey (Position 0 0)



-- formatters


formatTableId : Table -> String
formatTableId table =
    case ( table.schema, table.table ) of
        ( SchemaName schema, TableName name ) ->
            schema ++ "." ++ name


formatTableName : Table -> String
formatTableName table =
    case ( table.schema, table.table ) of
        ( SchemaName schema, TableName name ) ->
            schema ++ "." ++ name


formatColumnName : Column -> String
formatColumnName column =
    case column.column of
        ColumnName name ->
            name


formatColumnType : Column -> String
formatColumnType column =
    case column.kind of
        ColumnType kind ->
            kind


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
