module Models.Schema exposing (..)

import AssocList exposing (Dict)
import Models.Utils exposing (Color, Position, Size)



-- Schema model, only use types from Models.Utils or external libs, nothing outside


type alias Schema =
    { tables : Dict TableId Table
    , relations : List ( ForeignKey, ( Table, Column ), ( Table, Column ) )
    }


type alias Table =
    { id : TableId
    , schema : SchemaName
    , table : TableName
    , columns : Dict ColumnName Column
    , primaryKey : Maybe PrimaryKey
    , uniques : List Unique
    , indexes : List Index
    , comment : Maybe TableComment
    , ui : TableState
    }


type alias TableState =
    { size : Size, position : Position, color : Color }


type alias Column =
    { index : ColumnIndex
    , column : ColumnName
    , kind : ColumnType
    , nullable : Bool
    , foreignKey : Maybe ForeignKey
    , comment : Maybe ColumnComment
    }


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
