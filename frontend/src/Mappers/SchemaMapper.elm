module Mappers.SchemaMapper exposing (buildSchemaFromJson, buildSchemaFromSql)

import AssocList as Dict exposing (Dict)
import Conf exposing (colorList, conf)
import JsonFormats.SchemaDecoder exposing (JsonColumn, JsonForeignKey, JsonIndex, JsonPrimaryKey, JsonSchema, JsonTable, JsonUnique)
import Libs.Std exposing (dictFromList, listGet, listZipWith, stringHashCode, stringWordSplit)
import Models.Schema exposing (Column, ColumnComment(..), ColumnIndex(..), ColumnName(..), ColumnType(..), ForeignKey, ForeignKeyName(..), Index, IndexName(..), PrimaryKey, PrimaryKeyName(..), RelationRef, Schema, SchemaName(..), Table, TableComment(..), TableId(..), TableName(..), TableStatus(..), Unique, UniqueName(..))
import Models.Utils exposing (Color, Position, Size)
import SqlParser.SchemaParser exposing (SqlColumn, SqlForeignKey, SqlPrimaryKey, SqlSchema, SqlTable, SqlUnique)


buildSchemaFromJson : JsonSchema -> Schema
buildSchemaFromJson schema =
    buildSchemaType (buildJsonTables schema)


buildSchemaFromSql : SqlSchema -> Schema
buildSchemaFromSql schema =
    buildSchemaType (buildSqlTables schema)


buildSchemaType : Dict TableId Table -> Schema
buildSchemaType tables =
    { tables = tables, relations = buildRelations tables, layouts = [] }


buildJsonTables : JsonSchema -> Dict TableId Table
buildJsonTables schema =
    schema.tables |> listZipWith tableIdFromJsonTable |> List.map (buildJsonTable (Size 0 0) (Position 0 0)) |> dictFromList .id


buildJsonTable : Size -> Position -> ( JsonTable, TableId ) -> Table
buildJsonTable size position ( table, id ) =
    { id = id
    , schema = table.schema |> SchemaName
    , table = table.table |> TableName
    , columns = table.columns |> List.indexedMap buildJsonColumn |> dictFromList .column
    , primaryKey = table.primaryKey |> Maybe.map buildJsonPrimaryKey
    , uniques = table.uniques |> List.map buildJsonUnique
    , indexes = table.indexes |> List.map buildJsonIndex
    , comment = table.comment |> Maybe.map TableComment
    , state = { status = Uninitialized, color = buildColor id, size = size, position = position }
    }


buildJsonColumn : Int -> JsonColumn -> Column
buildJsonColumn index column =
    { index = index |> ColumnIndex
    , column = column.column |> ColumnName
    , kind = column.kind |> ColumnType
    , nullable = column.nullable
    , foreignKey = column.reference |> Maybe.map buildJsonForeignKey
    , comment = column.comment |> Maybe.map ColumnComment
    , state = { order = Just index }
    }


buildJsonPrimaryKey : JsonPrimaryKey -> PrimaryKey
buildJsonPrimaryKey pk =
    { columns = pk.columns |> List.map ColumnName
    , name = pk.name |> PrimaryKeyName
    }


buildJsonUnique : JsonUnique -> Unique
buildJsonUnique unique =
    { columns = unique.columns |> List.map ColumnName
    , name = unique.name |> UniqueName
    }


buildJsonIndex : JsonIndex -> Index
buildJsonIndex index =
    { columns = index.columns |> List.map ColumnName
    , definition = index.definition
    , name = index.name |> IndexName
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


buildSqlTables : SqlSchema -> Dict TableId Table
buildSqlTables schema =
    schema |> Dict.values |> List.map (buildSqlTable (Size 0 0) (Position 0 0)) |> dictFromList .id


buildSqlTable : Size -> Position -> SqlTable -> Table
buildSqlTable size position table =
    { id = tableIdFromSqlTable table
    , schema = table.schema |> SchemaName
    , table = table.table |> TableName
    , columns = table.columns |> List.indexedMap buildSqlColumn |> dictFromList .column
    , primaryKey = table.primaryKey |> Maybe.map buildSqlPrimaryKey
    , uniques = table.uniques |> List.map buildSqlUnique
    , indexes = []
    , comment = table.comment |> Maybe.map TableComment
    , state = { status = Uninitialized, color = buildColor (tableIdFromSqlTable table), size = size, position = position }
    }


buildSqlColumn : Int -> SqlColumn -> Column
buildSqlColumn index column =
    { index = index |> ColumnIndex
    , column = column.name |> ColumnName
    , kind = column.kind |> ColumnType
    , nullable = column.nullable
    , foreignKey = column.foreignKey |> Maybe.map buildSqlForeignKey
    , comment = column.comment |> Maybe.map ColumnComment
    , state = { order = Just index }
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


buildSqlUnique : SqlUnique -> Unique
buildSqlUnique unique =
    { columns = unique.columns |> List.map ColumnName
    , name = unique.name |> UniqueName
    }


tableIdFromSqlTable : SqlTable -> TableId
tableIdFromSqlTable table =
    TableId (SchemaName table.schema) (TableName table.table)


tableIdFromSqlForeignKey : SqlForeignKey -> TableId
tableIdFromSqlForeignKey fk =
    TableId (SchemaName fk.schema) (TableName fk.table)


buildColor : TableId -> Color
buildColor (TableId _ (TableName table)) =
    stringWordSplit table
        |> List.head
        |> Maybe.map stringHashCode
        |> Maybe.map (modBy (List.length colorList))
        |> Maybe.andThen (\index -> colorList |> listGet index)
        |> Maybe.withDefault conf.colors.grey



-- build relations


buildRelations : Dict TableId Table -> List RelationRef
buildRelations tables =
    tables |> Dict.values |> List.foldr (\table res -> buildTableRelations table ++ res) []


buildTableRelations : Table -> List RelationRef
buildTableRelations table =
    table.columns |> Dict.values |> List.filterMap (\col -> col.foreignKey |> Maybe.map (buildRelation table col))


buildRelation : Table -> Column -> ForeignKey -> RelationRef
buildRelation table column fk =
    { key = fk.name, src = { table = table.id, column = column.column }, ref = { table = fk.tableId, column = fk.column }, state = { show = True } }
