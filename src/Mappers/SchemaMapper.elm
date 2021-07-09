module Mappers.SchemaMapper exposing (buildSchema, buildSchemaFromJson, buildSchemaFromSql, emptySchema)

import AssocList as Dict
import Conf exposing (conf)
import JsonFormats.JsonSchemaDecoder exposing (JsonColumn, JsonForeignKey, JsonIndex, JsonPrimaryKey, JsonSchema, JsonTable, JsonUnique)
import Libs.Std exposing (dictFromList, listGet, listZipWith, stringHashCode, stringWordSplit, uniqueId)
import Models.Schema exposing (Column, ColumnComment(..), ColumnIndex(..), ColumnName(..), ColumnState, ColumnType(..), ColumnValue(..), ForeignKey, ForeignKeyName(..), Index, IndexName(..), Layout, PrimaryKey, PrimaryKeyName(..), RelationRef, Schema, SchemaName(..), Table, TableComment(..), TableId(..), TableName(..), TableState, TableStatus(..), Unique, UniqueName(..))
import Models.Utils exposing (Color, Position, Size)
import SqlParser.SchemaParser exposing (SqlColumn, SqlForeignKey, SqlIndex, SqlPrimaryKey, SqlSchema, SqlTable, SqlUnique)


buildSchemaFromJson : List String -> String -> JsonSchema -> Schema
buildSchemaFromJson takenNames name schema =
    buildJsonTables schema |> buildSchema takenNames name []


buildSchemaFromSql : List String -> String -> SqlSchema -> Schema
buildSchemaFromSql takenNames name schema =
    buildSqlTables schema |> buildSchema takenNames name []


emptySchema : Schema
emptySchema =
    buildSchema [] "No name" [] []


buildSchema : List String -> String -> List Layout -> List Table -> Schema
buildSchema takenNames name layouts tables =
    { name = uniqueId takenNames name, tables = tables |> dictFromList .id, relations = buildRelations tables, layouts = layouts }


buildJsonTables : JsonSchema -> List Table
buildJsonTables schema =
    schema.tables |> listZipWith tableIdFromJsonTable |> List.map buildJsonTable


buildJsonTable : ( JsonTable, TableId ) -> Table
buildJsonTable ( table, id ) =
    { id = id
    , schema = table.schema |> SchemaName
    , table = table.table |> TableName
    , columns = table.columns |> List.indexedMap buildJsonColumn |> dictFromList .column
    , primaryKey = table.primaryKey |> Maybe.map buildJsonPrimaryKey
    , uniques = table.uniques |> List.map buildJsonUnique
    , indexes = table.indexes |> List.map buildJsonIndex
    , comment = table.comment |> Maybe.map TableComment
    , state = initTableState id
    }


buildJsonColumn : Int -> JsonColumn -> Column
buildJsonColumn index column =
    { index = index |> ColumnIndex
    , column = column.column |> ColumnName
    , kind = column.kind |> ColumnType
    , nullable = column.nullable
    , default = column.default |> Maybe.map ColumnValue
    , foreignKey = column.reference |> Maybe.map buildJsonForeignKey
    , comment = column.comment |> Maybe.map ColumnComment
    , state = initColumnState index
    }


buildJsonPrimaryKey : JsonPrimaryKey -> PrimaryKey
buildJsonPrimaryKey pk =
    { columns = pk.columns |> List.map ColumnName
    , name = pk.name |> PrimaryKeyName
    }


buildJsonIndex : JsonIndex -> Index
buildJsonIndex index =
    { name = index.name |> IndexName
    , columns = index.columns |> List.map ColumnName
    , definition = index.definition
    }


buildJsonUnique : JsonUnique -> Unique
buildJsonUnique unique =
    { name = unique.name |> UniqueName
    , columns = unique.columns |> List.map ColumnName
    , definition = unique.definition
    }


buildJsonForeignKey : JsonForeignKey -> ForeignKey
buildJsonForeignKey fk =
    { tableId = fk |> tableIdFromJsonForeignKey
    , schema = fk.schema |> SchemaName
    , table = fk.table |> TableName
    , column = fk.column |> ColumnName
    , name = fk.name |> ForeignKeyName
    }


tableIdFromJsonTable : JsonTable -> TableId
tableIdFromJsonTable table =
    TableId (SchemaName table.schema) (TableName table.table)


tableIdFromJsonForeignKey : JsonForeignKey -> TableId
tableIdFromJsonForeignKey fk =
    TableId (SchemaName fk.schema) (TableName fk.table)


buildSqlTables : SqlSchema -> List Table
buildSqlTables schema =
    schema |> Dict.values |> List.map buildSqlTable


buildSqlTable : SqlTable -> Table
buildSqlTable table =
    { id = tableIdFromSqlTable table
    , schema = table.schema |> SchemaName
    , table = table.table |> TableName
    , columns = table.columns |> List.indexedMap buildSqlColumn |> dictFromList .column
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
    stringWordSplit table
        |> List.head
        |> Maybe.map stringHashCode
        |> Maybe.map (modBy (List.length conf.colors))
        |> Maybe.andThen (\index -> conf.colors |> listGet index)
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
