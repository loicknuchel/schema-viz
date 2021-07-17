module Models.Schema exposing (CanvasProps, Column, ColumnComment(..), ColumnIndex(..), ColumnName, ColumnRef, ColumnType(..), ColumnValue(..), FileInfo, ForeignKey, ForeignKeyName(..), Index, IndexName(..), Layout, LayoutName, PrimaryKey, PrimaryKeyName(..), Relation, RelationRef, RelationTarget, Schema, SchemaId, SchemaInfo, SchemaName, Source, SourceLine, Table, TableComment(..), TableId, TableName, TableProps, Unique, UniqueName(..), buildSchema, extractColumnIndex, htmlIdAsTableId, initLayout, initTableProps, outgoingRelations, showTableId, showTableName, stringAsTableId, tableIdAsHtmlId, tableIdAsString)

import Conf exposing (conf)
import Dict exposing (Dict)
import Libs.Dict as D
import Libs.List as L
import Libs.Models exposing (HtmlId)
import Libs.Ned as Ned exposing (Ned)
import Libs.Nel as Nel exposing (Nel)
import Libs.String as S
import Models.Utils exposing (Color, Position, Size, ZoomLevel)
import Time



-- deps = { to = { only = [ "Libs.*", "Models.*" ] } }


type alias Schema =
    { id : SchemaId
    , info : SchemaInfo
    , tables : Dict TableId Table
    , incomingRelations : Dict TableId (List RelationRef)
    , layout : Layout
    , layoutName : Maybe LayoutName
    , layouts : Dict LayoutName Layout
    }


type alias SchemaInfo =
    { created : Time.Posix
    , updated : Time.Posix
    , file : Maybe FileInfo
    }


type alias FileInfo =
    { name : String, lastModified : Time.Posix }


type alias RelationRef =
    { key : ForeignKeyName, src : ColumnRef, ref : ColumnRef }


type alias ColumnRef =
    { table : TableId, column : ColumnName }


type alias Relation =
    { key : ForeignKeyName, src : RelationTarget, ref : RelationTarget }


type alias RelationTarget =
    { table : Table, column : Column, props : Maybe ( TableProps, Size ) }


type alias Table =
    { id : TableId
    , schema : SchemaName
    , table : TableName
    , columns : Ned ColumnName Column
    , primaryKey : Maybe PrimaryKey
    , uniques : List Unique
    , indexes : List Index
    , comment : Maybe TableComment
    , sources : List Source
    }


type alias Column =
    { index : ColumnIndex
    , column : ColumnName
    , kind : ColumnType
    , nullable : Bool
    , default : Maybe ColumnValue
    , foreignKey : Maybe ForeignKey
    , comment : Maybe ColumnComment
    }


type alias PrimaryKey =
    { name : PrimaryKeyName, columns : Nel ColumnName }


type alias ForeignKey =
    { name : ForeignKeyName, tableId : TableId, column : ColumnName }


type alias Unique =
    { name : UniqueName, columns : Nel ColumnName, definition : String }


type alias Index =
    { name : IndexName, columns : Nel ColumnName, definition : String }


type alias Source =
    { file : String, lines : Nel SourceLine }


type alias SourceLine =
    { no : Int, text : String }


type alias Layout =
    { canvas : CanvasProps, tables : Dict TableId TableProps, hiddenTables : Dict TableId TableProps }


type alias CanvasProps =
    { position : Position, zoom : ZoomLevel }


type alias TableProps =
    { position : Position, color : Color, selected : Bool, columns : List ColumnName }


type alias SchemaId =
    String


type alias LayoutName =
    String


type TableComment
    = TableComment String


type ColumnComment
    = ColumnComment String


type alias SchemaName =
    String


type alias TableName =
    String


type alias TableId =
    ( SchemaName, TableName )


type ColumnIndex
    = ColumnIndex Int


type alias ColumnName =
    String


type ColumnType
    = ColumnType String


type ColumnValue
    = ColumnValue String


type PrimaryKeyName
    = PrimaryKeyName String


type UniqueName
    = UniqueName String


type IndexName
    = IndexName String


type ForeignKeyName
    = ForeignKeyName String


tableIdAsHtmlId : TableId -> HtmlId
tableIdAsHtmlId ( schema, table ) =
    "table-" ++ schema ++ "-" ++ table


htmlIdAsTableId : HtmlId -> TableId
htmlIdAsTableId id =
    case String.split "-" id of
        "table" :: schema :: table :: [] ->
            ( schema, table )

        _ ->
            ( conf.default.schema, id )


tableIdAsString : TableId -> String
tableIdAsString ( schema, table ) =
    schema ++ "." ++ table


stringAsTableId : String -> TableId
stringAsTableId id =
    case String.split "." id of
        schema :: table :: [] ->
            ( schema, table )

        _ ->
            ( conf.default.schema, id )


showTableName : SchemaName -> TableName -> String
showTableName schema table =
    if schema == conf.default.schema then
        table

    else
        schema ++ "." ++ table


showTableId : TableId -> String
showTableId ( schema, table ) =
    showTableName schema table


buildSchema : List SchemaId -> SchemaId -> SchemaInfo -> List Table -> Layout -> Maybe LayoutName -> Dict LayoutName Layout -> Schema
buildSchema takenIds id info tables layout layoutName layouts =
    { id = S.uniqueId takenIds id
    , info = info
    , tables = tables |> D.fromListMap .id
    , incomingRelations = buildIncomingRelations tables
    , layout = layout
    , layoutName = layoutName
    , layouts = layouts
    }


buildIncomingRelations : List Table -> Dict TableId (List RelationRef)
buildIncomingRelations tables =
    tables |> buildRelations |> D.groupBy (\r -> r.ref.table)


buildRelations : List Table -> List RelationRef
buildRelations tables =
    tables |> List.foldr (\table res -> outgoingRelations table ++ res) []


outgoingRelations : Table -> List RelationRef
outgoingRelations table =
    table.columns |> Ned.values |> Nel.filterMap (\col -> col.foreignKey |> Maybe.map (buildRelation table col))


buildRelation : Table -> Column -> ForeignKey -> RelationRef
buildRelation table column fk =
    { key = fk.name, src = { table = table.id, column = column.column }, ref = { table = fk.tableId, column = fk.column } }


initLayout : Layout
initLayout =
    { canvas = { position = Position 0 0, zoom = 1 }, tables = Dict.empty, hiddenTables = Dict.empty }


initTableProps : Table -> TableProps
initTableProps table =
    { position = Position 0 0
    , color = computeColor table.id
    , selected = False
    , columns = table.columns |> Ned.values |> Nel.toList |> List.sortBy (\c -> c.index |> extractColumnIndex) |> List.map .column
    }


computeColor : TableId -> Color
computeColor ( _, table ) =
    S.wordSplit table
        |> List.head
        |> Maybe.map S.hashCode
        |> Maybe.map (modBy (List.length conf.colors))
        |> Maybe.andThen (\index -> conf.colors |> L.get index)
        |> Maybe.withDefault conf.default.color


extractColumnIndex : ColumnIndex -> Int
extractColumnIndex (ColumnIndex index) =
    index
