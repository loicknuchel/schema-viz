module Views.Tables exposing (viewTable)

import AssocList as Dict
import FontAwesome.Icon exposing (viewIcon)
import FontAwesome.Regular as IconLight
import FontAwesome.Solid as Icon
import Html exposing (Attribute, Html, a, div, li, span, text, ul)
import Html.Attributes exposing (class, id, style, title)
import Html.Events exposing (onClick)
import Libs.Std exposing (listAddIf, listAppendOn, maybeFilter)
import Models exposing (Msg(..))
import Models.Schema exposing (Column, ColumnComment(..), ColumnName, ForeignKey, Index, IndexName(..), PrimaryKey, Relation, Table, TableAndColumn, TableComment(..), TableStatus(..), Unique, UniqueName(..))
import Models.Utils exposing (ZoomLevel)
import Views.Bootstrap exposing (bsDropdown)
import Views.Helpers exposing (dragAttrs, extractColumnName, extractColumnType, formatTableId, formatTableName, placeAt, sizeAttrs, withColumnName, withNullableInfo)



-- views showing tables, can include Views.Helpers, Models or Libs modules. Nothing else from views.


viewTable : ZoomLevel -> List Relation -> Table -> Html Msg
viewTable zoom incomingTableRelations table =
    div
        (listAddIf (table.state.status == Initializing)
            (style "visibility" "hidden")
            [ class "erd-table", id (formatTableId table.id), placeAt table.state.position ]
            ++ sizeAttrs table.state.size
            ++ dragAttrs (formatTableId table.id)
        )
        [ viewHeader zoom table
        , div [ class "columns" ] (List.map (\c -> viewColumn table.primaryKey table.uniques table.indexes (filterIncomingColumnRelations incomingTableRelations c) c) (Dict.values table.columns))
        ]


viewHeader : ZoomLevel -> Table -> Html Msg
viewHeader zoom table =
    div [ class "header", borderTopColor table.state.color, style "display" "flex", style "align-items" "center" ]
        [ div [ style "flex-grow" "1" ] (listAppendOn table.comment (\(TableComment comment) -> viewComment comment) [ span (tableNameSize zoom) [ text (formatTableName table.table table.schema) ] ])
        , div [ style "font-size" "0.9rem", style "opacity" "0.25", onClick (HideTable table.id) ] [ viewIcon Icon.eyeSlash ]
        ]


viewColumn : Maybe PrimaryKey -> List Unique -> List Index -> List Relation -> Column -> Html Msg
viewColumn pk uniques indexes columnRelations column =
    div [ class "column" ]
        [ viewColumnDropdown columnRelations (viewColumnIcon pk uniques indexes column)
        , viewColumnName pk column
        , viewColumnType column
        ]


viewColumnIcon : Maybe PrimaryKey -> List Unique -> List Index -> Column -> List (Attribute Msg) -> Html Msg
viewColumnIcon maybePk uniques indexes column attrs =
    case ( ( inPrimaryKey column.column maybePk, column.foreignKey ), ( inUniqueIndexes column.column uniques, inIndexes column.column indexes ) ) of
        ( ( Just pk, _ ), _ ) ->
            div ([ class "icon", title (formatPkTitle pk) ] ++ attrs) [ viewIcon Icon.key ]

        ( ( _, Just fk ), _ ) ->
            -- TODO: know fk table state to not put onClick when it's already shown (so Update.elm#showTable on Shown state could issue an error)
            div ([ class "icon", title (formatFkTitle fk), onClick (ShowTable fk.tableId) ] ++ attrs) [ viewIcon Icon.externalLinkAlt ]

        ( _, ( u :: us, _ ) ) ->
            div ([ class "icon", title (formatUniqueTitle (u :: us)) ] ++ attrs) [ viewIcon Icon.fingerprint ]

        ( _, ( _, i :: is ) ) ->
            div ([ class "icon", title (formatIndexTitle (i :: is)) ] ++ attrs) [ viewIcon Icon.sortAmountDownAlt ]

        _ ->
            div ([ class "icon" ] ++ attrs) []


viewColumnDropdown : List Relation -> (List (Attribute Msg) -> Html Msg) -> Html Msg
viewColumnDropdown incomingColumnRelations element =
    case
        List.map
            (\r -> li [] [ a [ class "dropdown-item", onClick (ShowTable r.src.table.id) ] [ viewIcon Icon.externalLinkAlt, text " ", text (formatColumnRef r.src) ] ])
            (List.filter (\r -> not (r.src.table.state.status == Shown)) incomingColumnRelations)
    of
        [] ->
            element []

        items ->
            bsDropdown "drop"
                (\attrs -> element attrs)
                (\attrs -> ul attrs items)


viewColumnName : Maybe PrimaryKey -> Column -> Html msg
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
    div [ class className ]
        (listAppendOn column.comment (\(ColumnComment comment) -> viewComment comment) [ text (extractColumnName column.column) ])


viewColumnType : Column -> Html msg
viewColumnType column =
    div [ class "type" ] [ text (formatColumnType column) ]


viewComment : String -> Html msg
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


filterIncomingColumnRelations : List Relation -> Column -> List Relation
filterIncomingColumnRelations incomingTableRelations column =
    List.filter (\r -> r.ref.column.column == column.column) incomingTableRelations


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


formatColumnType : Column -> String
formatColumnType column =
    extractColumnType column.kind |> withNullableInfo column.nullable


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
    formatTableName table schema |> withColumnName column


formatColumnRef : TableAndColumn -> String
formatColumnRef { table, column } =
    formatTableId table.id |> withColumnName column.column |> withNullableInfo column.nullable


formatUniqueIndexName : UniqueName -> String
formatUniqueIndexName (UniqueName name) =
    name


formatIndexName : IndexName -> String
formatIndexName (IndexName name) =
    name
