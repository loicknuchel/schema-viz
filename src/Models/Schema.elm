module Models.Schema exposing (CanvasProps, Column, ColumnComment(..), ColumnIndex(..), ColumnName(..), ColumnProps, ColumnRef, ColumnState, ColumnType(..), ColumnValue(..), FileInfo, ForeignKey, ForeignKeyName(..), Index, IndexName(..), Layout, LayoutName, PrimaryKey, PrimaryKeyName(..), Relation, RelationRef, RelationState, Schema, SchemaInfo, SchemaName(..), Table, TableAndColumn, TableComment(..), TableId(..), TableName(..), TableProps, TableState, TableStatus(..), Unique, UniqueName(..), formatTableId, formatTableName, parseTableId)

import AssocList exposing (Dict)
import Conf exposing (conf)
import Models.Utils exposing (Color, Position, Size, ZoomLevel)
import Time



-- Schema model, only use types from Models.Utils or external libs, nothing outside


type alias Schema =
    { name : String
    , info : SchemaInfo
    , layouts : List Layout
    , tables : Dict TableId Table
    , relations : List RelationRef
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


type alias Layout =
    { name : LayoutName, canvas : CanvasProps, tables : Dict TableId TableProps }


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
