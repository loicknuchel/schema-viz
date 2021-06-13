module View exposing (..)

import Draggable
import FontAwesome.Icon exposing (viewIcon)
import FontAwesome.Solid as Icon
import Html exposing (Attribute, Html, div, span, text)
import Html.Attributes exposing (class, id, style, title)
import Http exposing (Error(..))
import Libs.SchemaDecoders exposing (Column, ColumnComment(..), ColumnName(..), ColumnType(..), ForeignKey, ForeignKeyName(..), PrimaryKey(..), SchemaName(..), Table, TableComment(..), TableId(..), TableName(..))
import Libs.Std exposing (handleWheel, maybeFold)
import Models exposing (CanvasPosition, DragId, Menu, Msg(..), Position, Size, SizedTable, UiTable, ZoomLevel, conf)


viewApp : ZoomLevel -> CanvasPosition -> Maybe Menu -> List UiTable -> Html Msg
viewApp zoom pan menu tables =
    div [ class "app" ]
        [ viewMenu menu
        , viewErd zoom pan tables
        ]


viewMenu : Maybe Menu -> Html Msg
viewMenu menu =
    div ([ class "menu", placeAt (maybeFold (Position 0 0) .position menu) ] ++ maybeFold [] (\m -> dragAttrs m.id) menu)
        [ text "menu" ]


viewErd : ZoomLevel -> CanvasPosition -> List UiTable -> Html Msg
viewErd zoom pan tables =
    div ([ class "erd", handleWheel Zoom ] ++ dragAttrs "erd")
        [ div [ class "canvas", placeAndZoom zoom pan ] (List.map viewTable tables) ]


viewTable : UiTable -> Html Msg
viewTable table =
    div
        ([ class "table", placeAt table.position, id (formatTableId table.id) ]
            ++ maybeFold [] (\(TableComment comment) -> [ title comment ]) table.sql.comment
            ++ dragAttrs (formatTableId table.id)
        )
        [ div [ class "header", borderTopColor table.color ] [ text (formatTableName table.sql) ]
        , div [ class "columns" ] (List.map (viewColumn table.sql.primaryKey) table.sql.columns)
        ]


viewColumn : Maybe PrimaryKey -> Column -> Html Msg
viewColumn pk column =
    div ([ class "column" ] ++ maybeFold [] (\(ColumnComment comment) -> [ title comment ]) column.comment)
        [ viewColumnIcon column.reference
        , viewColumnName pk column
        , span [ class "type" ] [ text (formatColumnType column) ]
        ]


viewColumnIcon : Maybe ForeignKey -> Html Msg
viewColumnIcon fk =
    case fk of
        Just { schema, table, column, name } ->
            case ( schema, table, column ) of
                ( SchemaName s, TableName t, ColumnName c ) ->
                    span [ class "icon", title ("Foreign key to " ++ s ++ "." ++ t ++ "." ++ c) ] [ viewIcon Icon.externalLinkAlt ]

        _ ->
            span [ class "icon" ] []


viewColumnName : Maybe PrimaryKey -> Column -> Html Msg
viewColumnName pk column =
    let
        className =
            if isInPrimaryKey pk column then
                "name bold"

            else
                "name"
    in
    span [ class className ] [ text (formatColumnName column) ]


isInPrimaryKey : Maybe PrimaryKey -> Column -> Bool
isInPrimaryKey pk col =
    case pk of
        Just (PrimaryKey { columns }) ->
            List.any (\c -> c == col.column) columns

        _ ->
            False



-- helpers


placeAt : Position -> Attribute msg
placeAt p =
    style "transform" ("translate(" ++ String.fromFloat p.left ++ "px, " ++ String.fromFloat p.top ++ "px)")


placeAndZoom : ZoomLevel -> CanvasPosition -> Attribute msg
placeAndZoom zoom pan =
    style "transform" ("translate(" ++ String.fromFloat pan.left ++ "px, " ++ String.fromFloat pan.top ++ "px) scale(" ++ String.fromFloat zoom ++ ")")


borderTopColor : String -> Attribute msg
borderTopColor color =
    style "border-top-color" color


dragAttrs : DragId -> List (Attribute Msg)
dragAttrs id =
    Draggable.mouseTrigger id DragMsg :: Draggable.touchTriggers id DragMsg


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
formatTableId id =
    case id of
        TableId value ->
            value


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
