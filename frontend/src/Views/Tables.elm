module Views.Tables exposing (viewTable)

import AssocList as Dict
import FontAwesome.Icon exposing (viewIcon)
import FontAwesome.Regular as IconLight
import FontAwesome.Solid as Icon
import Html exposing (Attribute, Html, div, span, text)
import Html.Attributes exposing (class, id, style, title)
import Html.Events exposing (onClick)
import Libs.Std exposing (listAddIf, listAppendOn, maybeFilter)
import Models exposing (Msg(..), ZoomLevel, conf)
import Models.Schema exposing (Column, ColumnComment(..), ColumnName(..), ColumnType(..), ForeignKey, Index, IndexName(..), PrimaryKey, SchemaName(..), Table, TableComment(..), TableName(..), TableStatus(..), Unique, UniqueName(..))
import Views.Helpers exposing (dragAttrs, formatTableId, formatTableName, placeAt, sizeAttrs)



-- views showing tables, can include Views.Helpers, Models or Libs modules. Nothing else from views.


viewTable : ZoomLevel -> Table -> Html Msg
viewTable zoom table =
    div
        (listAddIf (table.state.status == Initializing)
            (style "visibility" "hidden")
            [ class "erd-table", id (formatTableId table.id), placeAt table.state.position ]
            ++ sizeAttrs table.state.size
            ++ dragAttrs (formatTableId table.id)
        )
        [ viewHeader zoom table
        , div [ class "columns" ] (List.map (viewColumn table.primaryKey table.uniques table.indexes) (Dict.values table.columns))
        ]


viewHeader : ZoomLevel -> Table -> Html Msg
viewHeader zoom table =
    div [ class "header", borderTopColor table.state.color, style "display" "flex", style "align-items" "center" ]
        [ div [ style "flex-grow" "1" ] (listAppendOn table.comment (\(TableComment comment) -> viewComment comment) [ span (tableNameSize zoom) [ text (formatTableName table) ] ])
        , div [ style "font-size" "0.9rem", style "opacity" "0.25", onClick (HideTable table.id) ] [ viewIcon Icon.eyeSlash ]
        ]


viewColumn : Maybe PrimaryKey -> List Unique -> List Index -> Column -> Html Msg
viewColumn pk uniques indexes column =
    div [ class "column" ]
        [ viewColumnIcon pk uniques indexes column
        , viewColumnName pk column
        , viewColumnType column
        ]


viewColumnIcon : Maybe PrimaryKey -> List Unique -> List Index -> Column -> Html Msg
viewColumnIcon maybePk uniques indexes column =
    case ( ( inPrimaryKey column.column maybePk, column.foreignKey ), ( inUniqueIndexes column.column uniques, inIndexes column.column indexes ) ) of
        ( ( Just pk, _ ), _ ) ->
            span [ class "icon", title (formatPkTitle pk) ] [ viewIcon Icon.key ]

        ( ( _, Just fk ), _ ) ->
            span [ class "icon", title (formatFkTitle fk), onClick (ShowTable fk.tableId) ] [ viewIcon Icon.externalLinkAlt ]

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
        (listAppendOn column.comment (\(ColumnComment comment) -> viewComment comment) [ text (formatColumnName column.column) ])


viewColumnType : Column -> Html Msg
viewColumnType column =
    span [ class "type" ] [ text (formatColumnType column.kind ++ formatNullable column) ]


viewComment : String -> Html Msg
viewComment comment =
    span [ title comment, style "margin-left" ".25rem", style "font-size" ".9rem", style "opacity" ".25" ] [ viewIcon IconLight.commentDots ]



-- view helpers


borderTopColor : String -> Attribute msg
borderTopColor color =
    style "border-top-color" color


tableNameSize : ZoomLevel -> List (Attribute msg)
tableNameSize zoom =
    -- when zoom is small, keep the table name readable
    if zoom < 0.5 then
        [ style "font-size" (String.fromFloat (10 / zoom) ++ "px") ]

    else
        []



-- data accessors


inPrimaryKey : ColumnName -> Maybe PrimaryKey -> Maybe PrimaryKey
inPrimaryKey column pk =
    maybeFilter (\{ columns } -> hasColumn column columns) pk


inUniqueIndexes : ColumnName -> List Unique -> List Unique
inUniqueIndexes column uniques =
    List.filter (\{ columns } -> hasColumn column columns) uniques


inIndexes : ColumnName -> List Index -> List Index
inIndexes column indexes =
    List.filter (\{ columns } -> hasColumn column columns) indexes


hasColumn : ColumnName -> List ColumnName -> Bool
hasColumn column columns =
    List.any (\c -> c == column) columns



-- formatters


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


formatUniqueTitle : List Unique -> String
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


formatUniqueIndexName : UniqueName -> String
formatUniqueIndexName (UniqueName name) =
    name


formatIndexName : IndexName -> String
formatIndexName (IndexName name) =
    name
