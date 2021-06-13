module View exposing (..)

import Draggable
import FontAwesome.Icon exposing (viewIcon)
import FontAwesome.Regular as IconLight
import FontAwesome.Solid as Icon
import Html exposing (Attribute, Html, div, span, text)
import Html.Attributes exposing (class, id, style, title)
import Http exposing (Error(..))
import Libs.SchemaDecoders exposing (Column, ColumnComment(..), ColumnName(..), ColumnType(..), ForeignKey, Index, IndexName(..), PrimaryKey(..), SchemaName(..), Table, TableComment(..), TableId(..), TableName(..), UniqueIndex, UniqueIndexName(..))
import Libs.Std exposing (handleWheel, maybeFilter, maybeFold)
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
        ([ class "table", placeAt table.position, id (formatTableId table.id) ] ++ dragAttrs (formatTableId table.id))
        [ div [ class "header", borderTopColor table.color ] ([ text (formatTableName table.sql) ] ++ viewComment (Maybe.map (\(TableComment comment) -> comment) table.sql.comment))
        , div [ class "columns" ] (List.map (viewColumn table.sql.primaryKey table.sql.uniques table.sql.indexes) table.sql.columns)
        ]


viewColumn : Maybe PrimaryKey -> List UniqueIndex -> List Index -> Column -> Html Msg
viewColumn pk uniques indexes column =
    div [ class "column" ]
        [ viewColumnIcon pk uniques indexes column
        , viewColumnName pk column
        , viewColumnType column
        ]


viewColumnIcon : Maybe PrimaryKey -> List UniqueIndex -> List Index -> Column -> Html Msg
viewColumnIcon maybePk uniques indexes column =
    case ( ( inPrimaryKey column.column maybePk, column.reference ), ( inUniqueIndexes column.column uniques, inIndexes column.column indexes ) ) of
        ( ( Just pk, _ ), _ ) ->
            span [ class "icon", title (formatPkTitle pk) ] [ viewIcon Icon.key ]

        ( ( _, Just fk ), _ ) ->
            span [ class "icon", title (formatFkTitle fk) ] [ viewIcon Icon.externalLinkAlt ]

        ( _, ( u :: us, _ ) ) ->
            span [ class "icon", title (formatUniqueTitle (u :: us)) ] [ viewIcon Icon.fingerprint ]

        ( _, ( _, i :: is ) ) ->
            span [ class "icon", title (formatIndexTitle (i :: is)) ] [ viewIcon Icon.sortAmountDownAlt ]

        _ ->
            span [ class "icon" ] []


viewColumnName : Maybe PrimaryKey -> Column -> Html Msg
viewColumnName pk column =
    let
        className : String
        className =
            case inPrimaryKey column.column pk of
                Just _ ->
                    "name bold"

                _ ->
                    "name"
    in
    span [ class className ]
        ([ text (formatColumnName column.column) ] ++ viewComment (Maybe.map (\(ColumnComment comment) -> comment) column.comment))


viewColumnType : Column -> Html Msg
viewColumnType column =
    span [ class "type" ] [ text (formatColumnType column.kind ++ formatNullable column) ]


viewComment : Maybe String -> List (Html Msg)
viewComment comment =
    maybeFold [] (\c -> [ span [ title c, style "margin-left" ".25rem", style "font-size" ".9rem", style "opacity" ".25" ] [ viewIcon IconLight.commentDots ] ]) comment


inPrimaryKey : ColumnName -> Maybe PrimaryKey -> Maybe PrimaryKey
inPrimaryKey column pk =
    maybeFilter (\(PrimaryKey { columns }) -> hasColumn column columns) pk


inUniqueIndexes : ColumnName -> List UniqueIndex -> List UniqueIndex
inUniqueIndexes column uniques =
    List.filter (\{ columns } -> hasColumn column columns) uniques


inIndexes : ColumnName -> List Index -> List Index
inIndexes column indexes =
    List.filter (\{ columns } -> hasColumn column columns) indexes


hasColumn : ColumnName -> List ColumnName -> Bool
hasColumn column columns =
    List.any (\c -> c == column) columns



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


formatColumnName : ColumnName -> String
formatColumnName (ColumnName name) =
    name


formatColumnType : ColumnType -> String
formatColumnType (ColumnType kind) =
    kind


formatNullable : Column -> String
formatNullable column =
    if column.nullable then
        "?"

    else
        ""


formatPkTitle : PrimaryKey -> String
formatPkTitle _ =
    "Primary key"


formatFkTitle : ForeignKey -> String
formatFkTitle fk =
    "Foreign key to " ++ formatReference fk


formatUniqueTitle : List UniqueIndex -> String
formatUniqueTitle uniques =
    "Unique constraint in " ++ String.join ", " (List.map (\unique -> formatUniqueIndexName unique.name) uniques)


formatIndexTitle : List Index -> String
formatIndexTitle indexes =
    "Indexed by " ++ String.join ", " (List.map (\index -> formatIndexName index.name) indexes)


formatReference : ForeignKey -> String
formatReference { schema, table, column } =
    case ( schema, table, column ) of
        ( SchemaName s, TableName t, ColumnName c ) ->
            if s == conf.defaultSchema then
                t ++ "." ++ c

            else
                s ++ "." ++ t ++ "." ++ c


formatUniqueIndexName : UniqueIndexName -> String
formatUniqueIndexName (UniqueIndexName name) =
    name


formatIndexName : IndexName -> String
formatIndexName (IndexName name) =
    name


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
