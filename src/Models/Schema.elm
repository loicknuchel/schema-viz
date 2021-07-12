module Models.Schema exposing (CanvasProps, Column, ColumnComment(..), ColumnIndex(..), ColumnName(..), ColumnProps, ColumnRef, ColumnState, ColumnType(..), ColumnValue(..), FileInfo, ForeignKey, ForeignKeyName(..), Index, IndexName(..), Layout, LayoutName, PrimaryKey, PrimaryKeyName(..), Relation, RelationRef, RelationState, Schema, SchemaId, SchemaInfo, SchemaName(..), SchemaState, Source, SourceLine, Table, TableAndColumn, TableComment(..), TableId(..), TableName(..), TableProps, TableState, TableStatus(..), Tables, Unique, UniqueName(..), buildSchema, formatTableId, formatTableName, initColumnState, initSchemaState, initTableState, parseTableId)

import AssocList as Dict exposing (Dict)
import Conf exposing (conf)
import Libs.Dict as D
import Libs.List as L
import Libs.Nel exposing (Nel)
import Libs.String as S
import Models.Utils exposing (Color, Position, Size, ZoomLevel)
import Time



-- deps = { to = { only = [ "Libs.*", "Models.*" ] } }


type alias Schema =
    { id : SchemaId
    , info : SchemaInfo
    , state : SchemaState
    , tables : Tables
    , relations : List RelationRef
    , layouts : List Layout
    }


type alias SchemaInfo =
    { created : Time.Posix
    , updated : Time.Posix
    , file : Maybe FileInfo
    }


type alias FileInfo =
    { name : String, lastModified : Time.Posix }


type alias SchemaState =
    { currentLayout : Maybe LayoutName, zoom : ZoomLevel, position : Position }


type alias Tables =
    Dict TableId Table


type alias RelationRef =
    { key : ForeignKeyName, src : ColumnRef, ref : ColumnRef, state : RelationState }


type alias ColumnRef =
    { table : TableId, column : ColumnName }


type alias Relation =
    { key : ForeignKeyName, src : TableAndColumn, ref : TableAndColumn, state : RelationState }


type alias TableAndColumn =
    { table : Table, column : Column }


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
    , state : TableState
    }


type alias TableState =
    { status : TableStatus, size : Size, position : Position, color : Color, selected : Bool }


type TableStatus
    = Uninitialized
    | Initializing
    | Hidden
    | Shown


type alias Column =
    { index : ColumnIndex
    , column : ColumnName
    , kind : ColumnType
    , nullable : Bool
    , default : Maybe ColumnValue
    , foreignKey : Maybe ForeignKey
    , comment : Maybe ColumnComment
    , state : ColumnState
    }


type alias ColumnState =
    { order : Maybe Int }


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
    { name : LayoutName, canvas : CanvasProps, tables : Dict TableId TableProps }


type alias SchemaId =
    String


type alias LayoutName =
    String


type alias CanvasProps =
    { zoom : ZoomLevel, position : Position }


type alias TableProps =
    { position : Position, color : Color, columns : Dict ColumnName ColumnProps }


type alias ColumnProps =
    { position : Int }


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


formatTableId : TableId -> String
formatTableId (TableId schema table) =
    formatTableName table schema


formatTableName : TableName -> SchemaName -> String
formatTableName (TableName table) (SchemaName schema) =
    if schema == conf.default.schema then
        table

    else
        schema ++ "." ++ table


parseTableId : String -> TableId
parseTableId id =
    case String.split "." id of
        schema :: table :: [] ->
            TableId (SchemaName schema) (TableName table)

        _ ->
            TableId (SchemaName conf.default.schema) (TableName id)


buildSchema : List SchemaId -> SchemaId -> SchemaInfo -> SchemaState -> List Table -> List Layout -> Schema
buildSchema takenIds id info state tables layouts =
    { id = S.uniqueId takenIds id, info = info, state = state, tables = tables |> D.fromList .id, relations = buildRelations tables, layouts = layouts }


buildRelations : List Table -> List RelationRef
buildRelations tables =
    tables |> List.foldr (\table res -> buildTableRelations table ++ res) []


buildTableRelations : Table -> List RelationRef
buildTableRelations table =
    table.columns |> Dict.values |> List.filterMap (\col -> col.foreignKey |> Maybe.map (buildRelation table col))


buildRelation : Table -> Column -> ForeignKey -> RelationRef
buildRelation table column fk =
    { key = fk.name, src = { table = table.id, column = column.column }, ref = { table = fk.tableId, column = fk.column }, state = { show = True } }


initSchemaState : SchemaState
initSchemaState =
    { currentLayout = Nothing, zoom = 1, position = Position 0 0 }


initTableState : TableId -> TableState
initTableState id =
    { status = Uninitialized, color = computeColor id, size = Size 0 0, position = Position 0 0, selected = False }


initColumnState : Int -> ColumnState
initColumnState index =
    { order = Just index }


computeColor : TableId -> Color
computeColor (TableId _ (TableName table)) =
    S.wordSplit table
        |> List.head
        |> Maybe.map S.hashCode
        |> Maybe.map (modBy (List.length conf.colors))
        |> Maybe.andThen (\index -> conf.colors |> L.get index)
        |> Maybe.withDefault conf.default.color
