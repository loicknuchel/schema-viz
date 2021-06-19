module Models.Schema exposing (..)

import AssocList exposing (Dict)
import Models.Utils exposing (Color, Position, Size)



-- Schema model, only use types from Models.Utils or external libs, nothing outside


type alias Schema =
    { tables : Dict TableId Table
    , relations : List RelationRef
    }


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
    { status : TableStatus, size : Size, position : Position, color : Color }


type TableStatus
    = Uninitialized
    | Ready
    | Hidden
    | Visible


type alias Column =
    { index : ColumnIndex
    , column : ColumnName
    , kind : ColumnType
    , nullable : Bool
    , foreignKey : Maybe ForeignKey
    , comment : Maybe ColumnComment
    , state : ColumnState
    }


type alias ColumnState =
    { order : Maybe Int }


type alias PrimaryKey =
    { columns : List ColumnName, name : PrimaryKeyName }


type alias Unique =
    { columns : List ColumnName, name : UniqueName }


type alias Index =
    { columns : List ColumnName, definition : String, name : IndexName }


type alias ForeignKey =
    { tableId : TableId, schema : SchemaName, table : TableName, column : ColumnName, name : ForeignKeyName }


type TableComment
    = TableComment String


type ColumnComment
    = ColumnComment String


type SchemaName
    = SchemaName String


type TableId
    = TableId String


type TableName
    = TableName String


type ColumnIndex
    = ColumnIndex Int


type ColumnName
    = ColumnName String


type ColumnType
    = ColumnType String


type PrimaryKeyName
    = PrimaryKeyName String


type UniqueName
    = UniqueName String


type IndexName
    = IndexName String


type ForeignKeyName
    = ForeignKeyName String


formatTableId : TableId -> String
formatTableId (TableId id) =
    id
