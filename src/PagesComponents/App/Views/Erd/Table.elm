module PagesComponents.App.Views.Erd.Table exposing (viewTable)

import Conf exposing (conf)
import Dict
import FontAwesome.Icon exposing (viewIcon)
import FontAwesome.Regular as IconLight
import FontAwesome.Solid as Icon
import Html exposing (Attribute, Html, b, button, div, li, span, text, ul)
import Html.Attributes exposing (class, classList, id, style, title, type_)
import Html.Events exposing (onClick, onDoubleClick, onMouseEnter, onMouseLeave)
import Libs.Bootstrap exposing (Toggle(..), bsDropdown, bsToggle, bsToggleCollapse)
import Libs.Html exposing (divIf)
import Libs.Html.Events exposing (stopClick)
import Libs.List as L
import Libs.Maybe as M
import Libs.Models exposing (ZoomLevel)
import Libs.Ned as Ned
import Libs.Nel as Nel
import Libs.Size exposing (Size)
import Libs.String as S
import Models.Schema exposing (Column, ColumnComment(..), ColumnRef, ColumnValue(..), ForeignKey, Index, IndexName(..), PrimaryKey, Relation, Table, TableComment(..), TableProps, Unique, UniqueName(..), extractColumnIndex, inIndexes, inPrimaryKey, inUniques, showTableId, showTableName, tableIdAsHtmlId, tableIdAsString)
import PagesComponents.App.Models exposing (Hover, Msg(..))
import PagesComponents.App.Views.Helpers exposing (columnRefAsHtmlId, dragAttrs, extractColumnName, extractColumnType, placeAt, sizeAttr, withColumnName, withNullableInfo)


viewTable : Hover -> ZoomLevel -> Int -> Table -> TableProps -> List Relation -> Maybe Size -> Html Msg
viewTable hover zoom index table props incomingRelations size =
    let
        hiddenColumns : List Column
        hiddenColumns =
            table.columns |> Ned.values |> Nel.filter (\c -> props.columns |> L.hasNot c.name)

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
         , style "z-index" (String.fromInt (conf.zIndex.tables + index))
         , size |> Maybe.map sizeAttr |> Maybe.withDefault (style "visibility" "hidden")
         , onMouseEnter (HoverTable (Just table.id))
         , onMouseLeave (HoverTable Nothing)
         ]
            ++ dragAttrs (tableIdAsHtmlId table.id)
        )
        [ viewHeader zoom index table
        , div [ class "columns" ]
            (props.columns
                |> List.filterMap (\c -> table.columns |> Ned.get c)
                |> List.map (\c -> viewColumn hover (filterIncomingColumnRelations incomingRelations c) table c)
            )
        , divIf (List.length hiddenColumns > 0)
            [ class "hidden-columns" ]
            [ button ([ class "toggle", type_ "button" ] ++ bsToggleCollapse collapseId)
                [ text (S.plural (hiddenColumns |> List.length) "No hidden column" "1 hidden column" "hidden columns")
                ]
            , div [ class "collapse", id collapseId ]
                (hiddenColumns
                    |> List.sortBy (\column -> extractColumnIndex column.index)
                    |> List.map (\c -> viewHiddenColumn table c)
                )
            ]
        ]


viewHeader : ZoomLevel -> Int -> Table -> Html Msg
viewHeader zoom index table =
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
                            [ li [] [ button [ type_ "button", class "dropdown-item", onClick (SortColumns table.id "property"), title "Primary key, then foreign key, then unique indexes, then indexes, then others" ] [ text "By property" ] ]
                            , li [] [ button [ type_ "button", class "dropdown-item", onClick (SortColumns table.id "name") ] [ text "By name" ] ]
                            , li [] [ button [ type_ "button", class "dropdown-item", onClick (SortColumns table.id "sql") ] [ text "By SQL order" ] ]
                            , li [] [ button [ type_ "button", class "dropdown-item", onClick (SortColumns table.id "type") ] [ text "By type" ] ]
                            ]
                        ]
                    , li []
                        [ button [ type_ "button", class "dropdown-item" ] [ text "Hide columns »" ]
                        , ul [ class "dropdown-menu dropdown-submenu" ]
                            [ li [] [ button [ type_ "button", class "dropdown-item", onClick (HideColumns table.id "regular"), title "Without key or index" ] [ text "Regular ones" ] ]
                            , li [] [ button [ type_ "button", class "dropdown-item", onClick (HideColumns table.id "nullable") ] [ text "Nullable ones" ] ]
                            , li [] [ button [ type_ "button", class "dropdown-item", onClick (HideColumns table.id "all") ] [ text "All" ] ]
                            ]
                        ]
                    , li []
                        [ button [ type_ "button", class "dropdown-item" ] [ text "Show columns »" ]
                        , ul [ class "dropdown-menu dropdown-submenu" ]
                            [ li [] [ button [ type_ "button", class "dropdown-item", onClick (ShowColumns table.id "all") ] [ text "All" ] ]
                            ]
                        ]
                    , li []
                        [ button [ type_ "button", class "dropdown-item" ] [ text "Order »" ]
                        , ul [ class "dropdown-menu dropdown-submenu" ]
                            [ li [] [ button [ type_ "button", class "dropdown-item", onClick (TableOrder table.id 1000) ] [ text "Bring to front" ] ]
                            , li [] [ button [ type_ "button", class "dropdown-item", onClick (TableOrder table.id (index + 1)) ] [ text "Bring forward" ] ]
                            , li [] [ button [ type_ "button", class "dropdown-item", onClick (TableOrder table.id (index - 1)) ] [ text "Send backward" ] ]
                            , li [] [ button [ type_ "button", class "dropdown-item", onClick (TableOrder table.id 0) ] [ text "Send to back" ] ]
                            ]
                        ]
                    ]
            )
        ]


viewColumn : Hover -> List Relation -> Table -> Column -> Html Msg
viewColumn hover incomingRelations table column =
    let
        ref : ColumnRef
        ref =
            ColumnRef table.id column.name
    in
    div [ class "column", classList [ ( "hover", isRelationHover hover incomingRelations column ) ], id (columnRefAsHtmlId ref), onDoubleClick (HideColumn ref), onMouseEnter (HoverColumn (Just ref)), onMouseLeave (HoverColumn Nothing) ]
        [ viewColumnDropdown incomingRelations ref (viewColumnIcon table column)
        , viewColumnName table column
        , viewColumnType column
        ]


isRelationHover : Hover -> List Relation -> Column -> Bool
isRelationHover hover columnRelations column =
    hover.column
        |> M.exist
            (\c ->
                (column.foreignKey |> M.exist (\fk -> fk.ref == c))
                    || (columnRelations |> List.any (\r -> r.src.table.id == c.table && r.src.column.name == c.column))
            )


viewHiddenColumn : Table -> Column -> Html Msg
viewHiddenColumn table column =
    div [ class "hidden-column", onDoubleClick (ShowColumn (ColumnRef table.id column.name)) ]
        [ viewColumnIcon table column []
        , viewColumnName table column
        , viewColumnType column
        ]


viewColumnIcon : Table -> Column -> List (Attribute Msg) -> Html Msg
viewColumnIcon table column attrs =
    case ( ( column.name |> inPrimaryKey table, column.foreignKey ), ( column.name |> inUniques table, column.name |> inIndexes table ) ) of
        ( ( Just pk, _ ), _ ) ->
            div (class "icon" :: attrs) [ div [ title (formatPkTitle pk), bsToggle Tooltip ] [ viewIcon Icon.key ] ]

        ( ( _, Just fk ), _ ) ->
            -- TODO: know fk table state to not put onClick when it's already shown (so Update.elm#showTable on Shown state could issue an error)
            div (class "icon" :: onClick (ShowTable fk.ref.table) :: attrs) [ div [ title (formatFkTitle fk), bsToggle Tooltip ] [ viewIcon Icon.externalLinkAlt ] ]

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
            |> L.groupBy (\relation -> relation.src.table.id |> tableIdAsString)
            |> Dict.values
            |> List.concatMap (\tableRelations -> [ tableRelations.head ])
            |> List.map
                (\relation ->
                    li []
                        [ button [ type_ "button", class "dropdown-item", classList [ ( "disabled", not (relation.src.props == Nothing) ) ], onClick (ShowTable relation.src.table.id) ]
                            [ viewIcon Icon.externalLinkAlt
                            , text " "
                            , b [] [ text (showTableId relation.src.table.id) ]
                            , text ("" |> withColumnName relation.src.column.name |> withNullableInfo relation.src.column.nullable)
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
    case incomingRelations |> List.filter (\r -> r.src.props == Nothing) |> List.map (\r -> r.src.table.id) |> L.unique of
        [] ->
            []

        rels ->
            [ li [] [ button [ type_ "button", class "dropdown-item", onClick (ShowTables rels) ] [ text ("Show all (" ++ String.fromInt (List.length rels) ++ " tables)") ] ] ]


viewColumnName : Table -> Column -> Html msg
viewColumnName table column =
    let
        className : String
        className =
            case column.name |> inPrimaryKey table of
                Just _ ->
                    "name bold"

                _ ->
                    "name"
    in
    div [ class className ]
        ([ text (extractColumnName column.name) ] |> L.appendOn column.comment (\(ColumnComment comment) -> viewComment comment))


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
    incomingTableRelations |> List.filter (\r -> r.ref.column.name == column.name)


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
formatReference fk =
    showTableName (fk.ref.table |> Tuple.first) (fk.ref.table |> Tuple.second) |> withColumnName fk.ref.column


formatUniqueIndexName : UniqueName -> String
formatUniqueIndexName (UniqueName name) =
    name


formatIndexName : IndexName -> String
formatIndexName (IndexName name) =
    name
