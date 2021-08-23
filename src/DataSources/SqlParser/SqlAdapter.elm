module DataSources.SqlParser.SqlAdapter exposing (buildSchemaFromSql)

import DataSources.SqlParser.FileParser exposing (SqlColumn, SqlForeignKey, SqlIndex, SqlPrimaryKey, SqlSchema, SqlTable, SqlUnique)
import DataSources.SqlParser.Utils.Types exposing (SqlStatement)
import Dict
import Libs.Ned as Ned
import Libs.Nel as Nel
import Models.Schema exposing (Column, ColumnComment(..), ColumnIndex(..), ColumnRef, ColumnType(..), ColumnValue(..), ForeignKey, ForeignKeyName(..), Index, IndexName(..), PrimaryKey, PrimaryKeyName(..), Schema, SchemaInfo, Source, Table, TableComment(..), TableId, Unique, UniqueName(..), buildSchema, initLayout)


buildSchemaFromSql : List String -> String -> SchemaInfo -> SqlSchema -> Schema
buildSchemaFromSql takenNames name info schema =
    buildSqlTables schema |> (\tables -> buildSchema takenNames name info tables initLayout Nothing Dict.empty)


buildSqlTables : SqlSchema -> List Table
buildSqlTables schema =
    schema |> Dict.values |> List.map buildSqlTable


buildSqlTable : SqlTable -> Table
buildSqlTable table =
    { id = tableIdFromSqlTable table
    , schema = table.schema
    , table = table.table
    , columns = table.columns |> Nel.indexedMap buildSqlColumn |> Ned.fromNelMap .name
    , primaryKey = table.primaryKey |> Maybe.map buildSqlPrimaryKey
    , indexes = table.indexes |> List.map buildSqlIndex
    , uniques = table.uniques |> List.map buildSqlUnique
    , comment = table.comment |> Maybe.map TableComment
    , sources = [ table.source |> statementAsSource ]
    }


buildSqlColumn : Int -> SqlColumn -> Column
buildSqlColumn index column =
    { index = index |> ColumnIndex
    , name = column.name
    , kind = column.kind |> ColumnType
    , nullable = column.nullable
    , default = column.default |> Maybe.map ColumnValue
    , foreignKey = column.foreignKey |> Maybe.map buildSqlForeignKey
    , comment = column.comment |> Maybe.map ColumnComment
    }


buildSqlPrimaryKey : SqlPrimaryKey -> PrimaryKey
buildSqlPrimaryKey pk =
    { columns = pk.columns
    , name = pk.name |> PrimaryKeyName
    }


buildSqlForeignKey : SqlForeignKey -> ForeignKey
buildSqlForeignKey fk =
    { name = fk.name |> ForeignKeyName
    , ref = ColumnRef ( fk.schema, fk.table ) fk.column
    }


buildSqlIndex : SqlIndex -> Index
buildSqlIndex index =
    { name = index.name |> IndexName
    , columns = index.columns
    , definition = index.definition
    }


buildSqlUnique : SqlUnique -> Unique
buildSqlUnique unique =
    { name = unique.name |> UniqueName
    , columns = unique.columns
    , definition = unique.definition
    }


statementAsSource : SqlStatement -> Source
statementAsSource statement =
    { file = statement.head.file, lines = statement |> Nel.map (\l -> { no = l.line, text = l.text }) }


tableIdFromSqlTable : SqlTable -> TableId
tableIdFromSqlTable table =
    ( table.schema, table.table )