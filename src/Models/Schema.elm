module Models.Schema exposing (CanvasProps, Column, ColumnComment(..), ColumnIndex(..), ColumnName(..), ColumnRef, ColumnType(..), ColumnValue(..), FileInfo, ForeignKey, ForeignKeyName(..), Index, IndexName(..), Layout, LayoutName, PrimaryKey, PrimaryKeyName(..), Relation, RelationRef, RelationState, RelationTarget, Schema, SchemaId, SchemaInfo, SchemaName(..), Source, SourceLine, Table, TableComment(..), TableId(..), TableName(..), TableProps, Unique, UniqueName(..), buildSchema, extractColumnIndex, htmlIdAsTableId, initLayout, initTableProps, showTableId, showTableName, stringAsTableId, tableIdAsHtmlId, tableIdAsString)

import AssocList as Dict exposing (Dict)
import Conf exposing (conf)
import Libs.Dict as D
import Libs.List as L
import Libs.Models exposing (HtmlId)
import Libs.Nel exposing (Nel)
import Libs.String as S
import Models.Utils exposing (Color, Position, Size, ZoomLevel)
import Time



-- deps = { to = { only = [ "Libs.*", "Models.*" ] } }


type alias Schema =
    { id : SchemaId
    , info : SchemaInfo
    , tables : Dict TableId Table
    , relations : List RelationRef
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
    { key : ForeignKeyName, src : ColumnRef, ref : ColumnRef, state : RelationState }


type alias ColumnRef =
    { table : TableId, column : ColumnName }


type alias Relation =
    { key : ForeignKeyName, src : RelationTarget, ref : RelationTarget, state : RelationState }


type alias RelationTarget =
    { table : Table, column : Column, props : Maybe ( TableProps, Size ) }


type alias RelationState =
    { show : Bool }


type alias Table =
    { id : TableId
    , schema : SchemaName
    , table : TableName
    , columns : Dict ColumnName Column
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
    { columns : List ColumnName, name : PrimaryKeyName }


type alias Index =
    { name : IndexName, columns : List ColumnName, definition : String }


type alias Unique =
    { name : UniqueName, columns : List ColumnName, definition : String }


type alias ForeignKey =
    { tableId : TableId, schema : SchemaName, table : TableName, column : ColumnName, name : ForeignKeyName }


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


type SchemaName
    = SchemaName String


type TableId
    = TableId SchemaName TableName


type TableName
    = TableName String


type ColumnIndex
    = ColumnIndex Int


type ColumnName
    = ColumnName String


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
tableIdAsHtmlId (TableId (SchemaName schema) (TableName table)) =
    "table-" ++ schema ++ "-" ++ table


htmlIdAsTableId : HtmlId -> TableId
htmlIdAsTableId id =
    case String.split "-" id of
        "table" :: schema :: table :: [] ->
            TableId (SchemaName schema) (TableName table)

        _ ->
            TableId (SchemaName conf.default.schema) (TableName id)


tableIdAsString : TableId -> String
tableIdAsString (TableId (SchemaName schema) (TableName table)) =
    schema ++ "." ++ table


stringAsTableId : String -> TableId
stringAsTableId id =
    case String.split "." id of
        schema :: table :: [] ->
            TableId (SchemaName schema) (TableName table)

        _ ->
            TableId (SchemaName conf.default.schema) (TableName id)


showTableName : SchemaName -> TableName -> String
showTableName (SchemaName schema) (TableName table) =
    if schema == conf.default.schema then
        table

    else
        schema ++ "." ++ table


showTableId : TableId -> String
showTableId (TableId schema table) =
    showTableName schema table


buildSchema : List SchemaId -> SchemaId -> SchemaInfo -> List Table -> Layout -> Maybe LayoutName -> Dict LayoutName Layout -> Schema
buildSchema takenIds id info tables layout layoutName layouts =
    { id = S.uniqueId takenIds id
    , info = info
    , tables = tables |> D.fromList .id
    , relations = buildRelations tables
    , layout = layout
    , layoutName = layoutName
    , layouts = layouts
    }


buildRelations : List Table -> List RelationRef
buildRelations tables =
    tables |> List.foldr (\table res -> buildTableRelations table ++ res) []


buildTableRelations : Table -> List RelationRef
buildTableRelations table =
    table.columns |> Dict.values |> List.filterMap (\col -> col.foreignKey |> Maybe.map (buildRelation table col))


buildRelation : Table -> Column -> ForeignKey -> RelationRef
buildRelation table column fk =
    { key = fk.name, src = { table = table.id, column = column.column }, ref = { table = fk.tableId, column = fk.column }, state = { show = True } }


initLayout : Layout
initLayout =
    { canvas = { position = Position 0 0, zoom = 1 }, tables = Dict.empty, hiddenTables = Dict.empty }


initTableProps : Table -> TableProps
initTableProps table =
    { position = Position 0 0
    , color = computeColor table.id
    , selected = False
    , columns = table.columns |> Dict.values |> List.sortBy (\c -> c.index |> extractColumnIndex) |> List.map .column
    }


computeColor : TableId -> Color
computeColor (TableId _ (TableName table)) =
    S.wordSplit table
        |> List.head
        |> Maybe.map S.hashCode
        |> Maybe.map (modBy (List.length conf.colors))
        |> Maybe.andThen (\index -> conf.colors |> L.get index)
        |> Maybe.withDefault conf.default.color


extractColumnIndex : ColumnIndex -> Int
extractColumnIndex (ColumnIndex index) =
    index
