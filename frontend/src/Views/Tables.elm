module Views.Tables exposing (viewTable)

import AssocList as Dict
import FontAwesome.Icon exposing (viewIcon)
import FontAwesome.Regular as IconLight
import FontAwesome.Solid as Icon
import Html exposing (Attribute, Html, a, b, div, li, span, text, ul)
import Html.Attributes exposing (attribute, class, classList, href, id, style, title)
import Html.Events exposing (onClick, onDoubleClick)
import Libs.Std exposing (divIf, listAddIf, listAppendOn, maybeFilter, plural)
import Models exposing (Msg(..))
import Models.Schema exposing (Column, ColumnComment(..), ColumnName, ForeignKey, Index, IndexName(..), PrimaryKey, Relation, Table, TableComment(..), TableId, TableStatus(..), Unique, UniqueName(..))
import Models.Utils exposing (ZoomLevel)
import Views.Bootstrap exposing (bsDropdown)
import Views.Helpers exposing (dragAttrs, extractColumnIndex, extractColumnName, extractColumnType, formatTableId, formatTableName, placeAt, sizeAttrs, withColumnName, withNullableInfo)



-- views showing tables, can include Views.Helpers, Models or Libs modules. Nothing else from views.


viewTable : ZoomLevel -> List Relation -> Table -> Html Msg
viewTable zoom incomingTableRelations table =
    let
        ( hiddenColumns, visibleColumns ) =
            table.columns |> Dict.values |> List.partition (\column -> column.state.order == Nothing)

        collapseId : String
        collapseId =
            formatTableId table.id ++ "-hidden-columns-collapse"
    in
    div
        (listAddIf (table.state.status == Initializing)
            (style "visibility" "hidden")
            [ class "erd-table", id (formatTableId table.id), placeAt table.state.position ]
            ++ sizeAttrs table.state.size
            ++ dragAttrs (formatTableId table.id)
        )
        [ viewHeader zoom table
        , div [ class "columns" ]
            (visibleColumns
                |> List.sortBy (\c -> c.state.order |> Maybe.withDefault -1)
                |> List.map (\c -> viewColumn table.id table.primaryKey table.uniques table.indexes (filterIncomingColumnRelations incomingTableRelations c) c)
            )
        , divIf (List.length hiddenColumns > 0)
            [ class "hidden-columns" ]
            [ a [ href ("#" ++ collapseId), class "toggle", attribute "data-bs-toggle" "collapse", attribute "role" "button", attribute "aria-expanded" "false", attribute "aria-controls" collapseId ]
                [ text (plural (hiddenColumns |> List.length) "No hidden column" "1 hidden column" " hidden columns")
                ]
            , div [ class "collapse", id collapseId ]
                (hiddenColumns
                    |> List.sortBy (\column -> extractColumnIndex column.index)
                    |> List.map (viewHiddenColumn table.id table.primaryKey table.uniques table.indexes)
                )
            ]
        ]


viewHeader : ZoomLevel -> Table -> Html Msg
viewHeader zoom table =
    div [ class "header", borderTopColor table.state.color, style "display" "flex", style "align-items" "center" ]
        [ div [ style "flex-grow" "1" ] (listAppendOn table.comment (\(TableComment comment) -> viewComment comment) [ span (tableNameSize zoom) [ text (formatTableName table.table table.schema) ] ])
        , div [ style "font-size" "0.9rem", style "opacity" "0.25", onClick (HideTable table.id) ] [ viewIcon Icon.eyeSlash ]
        ]


viewColumn : TableId -> Maybe PrimaryKey -> List Unique -> List Index -> List Relation -> Column -> Html Msg
viewColumn tableId pk uniques indexes columnRelations column =
    div [ class "column", onDoubleClick (HideColumn tableId column.column) ]
        [ viewColumnDropdown columnRelations (viewColumnIcon pk uniques indexes column)
        , viewColumnName pk column
        , viewColumnType column
        ]


viewHiddenColumn : TableId -> Maybe PrimaryKey -> List Unique -> List Index -> Column -> Html Msg
viewHiddenColumn tableId pk uniques indexes column =
    div [ class "hidden-column", onDoubleClick (ShowColumn tableId column.column (extractColumnIndex column.index)) ]
        [ viewColumnIcon pk uniques indexes column []
        , viewColumnName pk column
        , viewColumnType column
        ]


viewColumnIcon : Maybe PrimaryKey -> List Unique -> List Index -> Column -> List (Attribute Msg) -> Html Msg
viewColumnIcon maybePk uniques indexes column attrs =
    case ( ( inPrimaryKey column.column maybePk, column.foreignKey ), ( inUniqueIndexes column.column uniques, inIndexes column.column indexes ) ) of
        ( ( Just pk, _ ), _ ) ->
            div (class "icon" :: attrs) [ div [ title (formatPkTitle pk), attribute "data-bs-toggle" "tooltip" ] [ viewIcon Icon.key ] ]

        ( ( _, Just fk ), _ ) ->
            -- TODO: know fk table state to not put onClick when it's already shown (so Update.elm#showTable on Shown state could issue an error)
            div (class "icon" :: onClick (ShowTable fk.tableId) :: attrs) [ div [ title (formatFkTitle fk), attribute "data-bs-toggle" "tooltip" ] [ viewIcon Icon.externalLinkAlt ] ]

        ( _, ( u :: us, _ ) ) ->
            div (class "icon" :: attrs) [ div [ title (formatUniqueTitle (u :: us)), attribute "data-bs-toggle" "tooltip" ] [ viewIcon Icon.fingerprint ] ]

        ( _, ( _, i :: is ) ) ->
            div (class "icon" :: attrs) [ div [ title (formatIndexTitle (i :: is)), attribute "data-bs-toggle" "tooltip" ] [ viewIcon Icon.sortAmountDownAlt ] ]

        _ ->
            div ([ class "icon" ] ++ attrs) []


viewColumnDropdown : List Relation -> (List (Attribute Msg) -> Html Msg) -> Html Msg
viewColumnDropdown incomingColumnRelations element =
    case
        incomingColumnRelations
            |> List.map
                (\relation ->
                    li []
                        [ a [ class "dropdown-item", classList [ ( "disabled", relation.src.table.state.status == Shown ) ], onClick (ShowTable relation.src.table.id) ]
                            [ viewIcon Icon.externalLinkAlt
                            , text " "
                            , b [] [ text (formatTableId relation.src.table.id) ]
                            , text ("" |> withColumnName relation.src.column.column |> withNullableInfo relation.src.column.nullable)
                            ]
                        ]
                )
    of
        [] ->
            -- needs the same structure than dropdown to not change nodes and cause bootstrap errors: (Bootstrap doesn't allow more than one instance per element)
            div [] [ element [] ]

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
        ([ text (extractColumnName column.column) ] |> listAppendOn column.comment (\(ColumnComment comment) -> viewComment comment))


viewColumnType : Column -> Html msg
viewColumnType column =
    div [ class "type" ] [ text (formatColumnType column) ]


viewComment : String -> Html msg
viewComment comment =
    span [ title comment, attribute "data-bs-toggle" "tooltip", style "margin-left" ".25rem", style "font-size" ".9rem", style "opacity" ".25" ] [ viewIcon IconLight.commentDots ]



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
    incomingTableRelations |> List.filter (\r -> r.ref.column.column == column.column)


inPrimaryKey : ColumnName -> Maybe PrimaryKey -> Maybe PrimaryKey
inPrimaryKey column pk =
    pk |> maybeFilter (\{ columns } -> columns |> hasColumn column)


inUniqueIndexes : ColumnName -> List Unique -> List Unique
inUniqueIndexes column uniques =
    uniques |> List.filter (\{ columns } -> columns |> hasColumn column)


inIndexes : ColumnName -> List Index -> List Index
inIndexes column indexes =
    indexes |> List.filter (\{ columns } -> columns |> hasColumn column)


hasColumn : ColumnName -> List ColumnName -> Bool
hasColumn column columns =
    columns |> List.any (\c -> c == column)



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
    "Unique constraint in " ++ (uniques |> List.map (\unique -> formatUniqueIndexName unique.name) |> String.join ", ")


formatIndexTitle : List Index -> String
formatIndexTitle indexes =
    "Indexed by " ++ (indexes |> List.map (\index -> formatIndexName index.name) |> String.join ", ")


formatReference : ForeignKey -> String
formatReference { schema, table, column } =
    formatTableName table schema |> withColumnName column


formatUniqueIndexName : UniqueName -> String
formatUniqueIndexName (UniqueName name) =
    name


formatIndexName : IndexName -> String
formatIndexName (IndexName name) =
    name
