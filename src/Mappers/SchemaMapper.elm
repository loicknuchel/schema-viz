module Mappers.SchemaMapper exposing (buildSchema, buildSchemaFromSql, emptySchema, initTableState)

import AssocList as Dict
import Conf exposing (conf)
import Libs.Dict as D
import Libs.List as L
import Libs.String as S
import Models.Schema exposing (Column, ColumnComment(..), ColumnIndex(..), ColumnName(..), ColumnState, ColumnType(..), ColumnValue(..), ForeignKey, ForeignKeyName(..), Index, IndexName(..), Layout, PrimaryKey, PrimaryKeyName(..), RelationRef, Schema, SchemaInfo, SchemaName(..), Table, TableComment(..), TableId(..), TableName(..), TableState, TableStatus(..), Unique, UniqueName(..))
import Models.Utils exposing (Color, Position, Size)
import SqlParser.SchemaParser exposing (SqlColumn, SqlForeignKey, SqlIndex, SqlPrimaryKey, SqlSchema, SqlTable, SqlUnique)
import Time


buildSchemaFromSql : List String -> String -> SchemaInfo -> SqlSchema -> Schema
buildSchemaFromSql takenNames name info schema =
    buildSqlTables schema |> (\tables -> buildSchema takenNames name info tables [])


emptySchema : Schema
emptySchema =
    buildSchema [] "No name" { created = Time.millisToPosix 0, updated = Time.millisToPosix 0, file = Nothing } [] []


buildSchema : List String -> String -> SchemaInfo -> List Table -> List Layout -> Schema
buildSchema takenNames name info tables layouts =
    { name = S.uniqueId takenNames name, info = info, tables = tables |> D.fromList .id, relations = buildRelations tables, layouts = layouts }


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


tableIdFromSqlTable : SqlTable -> TableId
tableIdFromSqlTable table =
    TableId (SchemaName table.schema) (TableName table.table)


tableIdFromSqlForeignKey : SqlForeignKey -> TableId
tableIdFromSqlForeignKey fk =
    TableId (SchemaName fk.schema) (TableName fk.table)


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



-- build relations


buildRelations : List Table -> List RelationRef
buildRelations tables =
    tables |> List.foldr (\table res -> buildTableRelations table ++ res) []


buildTableRelations : Table -> List RelationRef
buildTableRelations table =
    table.columns |> Dict.values |> List.filterMap (\col -> col.foreignKey |> Maybe.map (buildRelation table col))


buildRelation : Table -> Column -> ForeignKey -> RelationRef
buildRelation table column fk =
    { key = fk.name, src = { table = table.id, column = column.column }, ref = { table = fk.tableId, column = fk.column }, state = { show = True } }
