module Mappers.SchemaMapper exposing (buildSchemaFromSql)

import AssocList as Dict
import Libs.Dict as D
import Libs.Nel as Nel
import Models.Schema exposing (Column, ColumnComment(..), ColumnIndex(..), ColumnName(..), ColumnType(..), ColumnValue(..), ForeignKey, ForeignKeyName(..), Index, IndexName(..), PrimaryKey, PrimaryKeyName(..), Schema, SchemaInfo, SchemaName(..), Source, Table, TableComment(..), TableId(..), TableName(..), TableStatus(..), Unique, UniqueName(..), buildSchema, initColumnState, initSchemaState, initTableState)
import SqlParser.SchemaParser exposing (SqlColumn, SqlForeignKey, SqlIndex, SqlPrimaryKey, SqlSchema, SqlTable, SqlUnique)
import SqlParser.Utils.Types exposing (SqlStatement)



-- deps = { to = { only = [ "Libs.*", "Models.*", "SqlParser.*" ] } }


buildSchemaFromSql : List String -> String -> SchemaInfo -> SqlSchema -> Schema
buildSchemaFromSql takenNames name info schema =
    buildSqlTables schema |> (\tables -> buildSchema takenNames name info initSchemaState tables [])


buildSqlTables : SqlSchema -> List Table
buildSqlTables schema =
    schema |> Dict.values |> List.map buildSqlTable


buildSqlTable : SqlTable -> Table
buildSqlTable table =
    { id = tableIdFromSqlTable table
    , schema = table.schema |> SchemaName
    , table = table.table |> TableName
    , columns = table.columns |> List.indexedMap buildSqlColumn |> D.fromList .column
    , primaryKey = table.primaryKey |> Maybe.map buildSqlPrimaryKey
    , indexes = table.indexes |> List.map buildSqlIndex
    , uniques = table.uniques |> List.map buildSqlUnique
    , comment = table.comment |> Maybe.map TableComment
    , sources = [ table.source |> statementAsSource ]
    , state = initTableState (tableIdFromSqlTable table)
    }


buildSqlColumn : Int -> SqlColumn -> Column
buildSqlColumn index column =
    { index = index |> ColumnIndex
    , column = column.name |> ColumnName
    , kind = column.kind |> ColumnType
    , nullable = column.nullable
    , default = column.default |> Maybe.map ColumnValue
    , foreignKey = column.foreignKey |> Maybe.map buildSqlForeignKey
    , comment = column.comment |> Maybe.map ColumnComment
    , state = initColumnState index
    }


buildSqlPrimaryKey : SqlPrimaryKey -> PrimaryKey
buildSqlPrimaryKey pk =
    { columns = pk.columns |> List.map ColumnName
    , name = pk.name |> PrimaryKeyName
    }


buildSqlForeignKey : SqlForeignKey -> ForeignKey
buildSqlForeignKey fk =
    { tableId = fk |> tableIdFromSqlForeignKey
    , schema = fk.schema |> SchemaName
    , table = fk.table |> TableName
    , column = fk.column |> ColumnName
    , name = fk.name |> ForeignKeyName
    }


buildSqlIndex : SqlIndex -> Index
buildSqlIndex index =
    { name = index.name |> IndexName
    , columns = index.columns |> List.map ColumnName
    , definition = index.definition
    }


buildSqlUnique : SqlUnique -> Unique
buildSqlUnique unique =
    { name = unique.name |> UniqueName
    , columns = unique.columns |> List.map ColumnName
    , definition = unique.definition
    }


statementAsSource : SqlStatement -> Source
statementAsSource statement =
    { file = statement.head.file, lines = statement |> Nel.map (\l -> { no = l.line, text = l.text }) }


tableIdFromSqlTable : SqlTable -> TableId
tableIdFromSqlTable table =
    TableId (SchemaName table.schema) (TableName table.table)


tableIdFromSqlForeignKey : SqlForeignKey -> TableId
tableIdFromSqlForeignKey fk =
    TableId (SchemaName fk.schema) (TableName fk.table)
