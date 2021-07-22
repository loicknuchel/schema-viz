module Views.Erd.Table exposing (viewTable)

import FontAwesome.Icon exposing (viewIcon)
import FontAwesome.Regular as IconLight
import FontAwesome.Solid as Icon
import Html exposing (Attribute, Html, a, b, button, div, li, span, text, ul)
import Html.Attributes exposing (class, classList, id, style, title, type_)
import Html.Events exposing (onClick, onDoubleClick)
import Libs.Bootstrap exposing (Toggle(..), bsDropdown, bsToggle, bsToggleCollapse)
import Libs.Html exposing (divIf)
import Libs.Html.Events exposing (stopClick)
import Libs.List as L
import Libs.Ned as Ned
import Libs.Nel as Nel
import Libs.Size exposing (Size)
import Libs.String as S
import Models exposing (Msg(..))
import Models.Schema exposing (Column, ColumnComment(..), ColumnRef, ColumnValue(..), ForeignKey, Index, IndexName(..), PrimaryKey, Relation, Table, TableComment(..), TableProps, Unique, UniqueName(..), extractColumnIndex, inIndexes, inPrimaryKey, inUniques, showTableId, showTableName, tableIdAsHtmlId)
import Models.Utils exposing (ZoomLevel)
import Views.Helpers exposing (columnRefAsHtmlId, dragAttrs, extractColumnName, extractColumnType, placeAt, sizeAttr, withColumnName, withNullableInfo)



-- deps = { to = { only = [ "Libs.*", "Models.*", "Conf", "Views.Helpers" ] } }


viewTable : ZoomLevel -> Table -> TableProps -> List Relation -> Maybe Size -> Html Msg
viewTable zoom table props incomingRelations size =
    let
        hiddenColumns : List Column
        hiddenColumns =
            table.columns |> Ned.values |> Nel.filter (\c -> props.columns |> L.hasNot c.column)

        collapseId : String
        collapseId =
            tableIdAsHtmlId table.id ++ "-hidden-columns-collapse"
    in
    div
        ([ class "erd-table"
         , class props.color
         , classList [ ( "selected", props.selected ) ]
         , id (tableIdAsHtmlId table.id)
         , placeAt props.position
         , size |> Maybe.map sizeAttr |> Maybe.withDefault (style "visibility" "hidden")
         ]
            ++ dragAttrs (tableIdAsHtmlId table.id)
        )
        [ viewHeader zoom table
        , div [ class "columns" ]
            (props.columns
                |> List.filterMap (\c -> table.columns |> Ned.get c)
                |> List.map (\c -> viewColumn { table = table.id, column = c.column } table (filterIncomingColumnRelations incomingRelations c) c)
            )
        , divIf (List.length hiddenColumns > 0)
            [ class "hidden-columns" ]
            [ button ([ class "toggle", type_ "button" ] ++ bsToggleCollapse collapseId)
                [ text (S.plural (hiddenColumns |> List.length) "No hidden column" "1 hidden column" "hidden columns")
                ]
            , div [ class "collapse", id collapseId ]
                (hiddenColumns
                    |> List.sortBy (\column -> extractColumnIndex column.index)
                    |> List.map (\c -> viewHiddenColumn { table = table.id, column = c.column } table c)
                )
            ]
        ]


viewHeader : ZoomLevel -> Table -> Html Msg
viewHeader zoom table =
    div [ class "header", style "display" "flex", style "align-items" "center", onClick (SelectTable table.id) ]
        [ div [ style "flex-grow" "1" ] (L.appendOn table.comment (\(TableComment comment) -> viewComment comment) [ span (tableNameSize zoom) [ text (showTableName table.schema table.table) ] ])
        , bsDropdown (tableIdAsHtmlId table.id ++ "-settings-dropdown")
            []
            (\attrs -> div ([ style "font-size" "0.9rem", style "opacity" "0.25", style "width" "30px", style "margin-left" "-10px", style "margin-right" "-20px", stopClick Noop ] ++ attrs) [ viewIcon Icon.ellipsisV ])
            (\attrs ->
                ul attrs
                    [ li [] [ button [ type_ "button", class "dropdown-item", onClick (HideTable table.id) ] [ text "Hide table" ] ]
                    , li []
                        [ button [ type_ "button", class "dropdown-item" ] [ text "Sort columns »" ]
                        , ul [ class "dropdown-menu dropdown-submenu" ]
                            [ li [] [ button [ type_ "button", class "dropdown-item", onClick (SortColumns table.id "sql") ] [ text "By SQL order" ] ]
                            , li [] [ button [ type_ "button", class "dropdown-item", onClick (SortColumns table.id "name") ] [ text "By name" ] ]
                            , li [] [ button [ type_ "button", class "dropdown-item", onClick (SortColumns table.id "type") ] [ text "By type" ] ]
                            , li [] [ button [ type_ "button", class "dropdown-item", onClick (SortColumns table.id "property") ] [ text "By property" ] ]
                            ]
                        ]
                    ]
            )
        ]


viewColumn : ColumnRef -> Table -> List Relation -> Column -> Html Msg
viewColumn ref table columnRelations column =
    div [ class "column", onDoubleClick (HideColumn ref) ]
        [ viewColumnDropdown columnRelations ref (viewColumnIcon table column)
        , viewColumnName table column
        , viewColumnType column
        ]


viewHiddenColumn : ColumnRef -> Table -> Column -> Html Msg
viewHiddenColumn ref table column =
    div [ class "hidden-column", onDoubleClick (ShowColumn ref (extractColumnIndex column.index)) ]
        [ viewColumnIcon table column []
        , viewColumnName table column
        , viewColumnType column
        ]


viewColumnIcon : Table -> Column -> List (Attribute Msg) -> Html Msg
viewColumnIcon table column attrs =
    case ( ( column.column |> inPrimaryKey table, column.foreignKey ), ( column.column |> inUniques table, column.column |> inIndexes table ) ) of
        ( ( Just pk, _ ), _ ) ->
            div (class "icon" :: attrs) [ div [ title (formatPkTitle pk), bsToggle Tooltip ] [ viewIcon Icon.key ] ]

        ( ( _, Just fk ), _ ) ->
            -- TODO: know fk table state to not put onClick when it's already shown (so Update.elm#showTable on Shown state could issue an error)
            div (class "icon" :: onClick (ShowTable fk.tableId) :: attrs) [ div [ title (formatFkTitle fk), bsToggle Tooltip ] [ viewIcon Icon.externalLinkAlt ] ]

        ( _, ( u :: us, _ ) ) ->
            div (class "icon" :: attrs) [ div [ title (formatUniqueTitle (u :: us)), bsToggle Tooltip ] [ viewIcon Icon.fingerprint ] ]

        ( _, ( _, i :: is ) ) ->
            div (class "icon" :: attrs) [ div [ title (formatIndexTitle (i :: is)), bsToggle Tooltip ] [ viewIcon Icon.sortAmountDownAlt ] ]

        _ ->
            div ([ class "icon" ] ++ attrs) []


viewColumnDropdown : List Relation -> ColumnRef -> (List (Attribute Msg) -> Html Msg) -> Html Msg
viewColumnDropdown incomingColumnRelations ref element =
    case
        incomingColumnRelations
            |> List.map
                (\relation ->
                    li []
                        [ a [ class "dropdown-item", classList [ ( "disabled", not (relation.src.props == Nothing) ) ], onClick (ShowTable relation.src.table.id) ]
                            [ viewIcon Icon.externalLinkAlt
                            , text " "
                            , b [] [ text (showTableId relation.src.table.id) ]
                            , text ("" |> withColumnName relation.src.column.column |> withNullableInfo relation.src.column.nullable)
                            ]
                        ]
                )
    of
        [] ->
            -- needs the same structure than dropdown to not change nodes and cause bootstrap errors: (Bootstrap doesn't allow more than one instance per element)
            div [] [ element [] ]

        items ->
            bsDropdown (columnRefAsHtmlId ref ++ "-relations-dropdown")
                [ class "dropdown-menu-end" ]
                (\attrs -> element attrs)
                (\attrs -> ul attrs (items ++ viewShowAllOption incomingColumnRelations))


viewShowAllOption : List Relation -> List (Html Msg)
viewShowAllOption incomingRelations =
    case incomingRelations |> List.filter (\r -> r.src.props == Nothing) of
        [] ->
            []

        rels ->
            [ li [] [ a [ class "dropdown-item", onClick (ShowTables (rels |> List.map (\r -> r.src.table.id))) ] [ text "Show all" ] ] ]


viewColumnName : Table -> Column -> Html msg
viewColumnName table column =
    let
        className : String
        className =
            case column.column |> inPrimaryKey table of
                Just _ ->
                    "name bold"

                _ ->
                    "name"
    in
    div [ class className ]
        ([ text (extractColumnName column.column) ] |> L.appendOn column.comment (\(ColumnComment comment) -> viewComment comment))


viewColumnType : Column -> Html msg
viewColumnType column =
    column.default
        |> Maybe.map (\(ColumnValue d) -> div [ class "type", title ("default value: " ++ d), bsToggle Tooltip, style "text-decoration" "underline" ] [ text (formatColumnType column) ])
        |> Maybe.withDefault (div [ class "type" ] [ text (formatColumnType column) ])


viewComment : String -> Html msg
viewComment comment =
    span [ title comment, bsToggle Tooltip, style "margin-left" ".25rem", style "font-size" ".9rem", style "opacity" ".25" ] [ viewIcon IconLight.commentDots ]



-- view helpers


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
formatReference { tableId, column } =
    showTableName (tableId |> Tuple.first) (tableId |> Tuple.second) |> withColumnName column


formatUniqueIndexName : UniqueName -> String
formatUniqueIndexName (UniqueName name) =
    name


formatIndexName : IndexName -> String
formatIndexName (IndexName name) =
    name
