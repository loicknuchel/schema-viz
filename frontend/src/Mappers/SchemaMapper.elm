module Mappers.SchemaMapper exposing (buildSchema)

import AssocList as Dict exposing (Dict)
import Conf exposing (colorList, conf)
import JsonFormats.SchemaDecoder exposing (JsonColumn, JsonForeignKey, JsonIndex, JsonPrimaryKey, JsonTable, JsonUnique)
import Libs.Std exposing (dictFromList, listGet, stringHashCode, stringWordSplit)
import Models.Schema exposing (Column, ColumnComment(..), ColumnIndex(..), ColumnName(..), ColumnType(..), ForeignKey, ForeignKeyName(..), Index, IndexName(..), PrimaryKey, PrimaryKeyName(..), RelationRef, Schema, SchemaName(..), Table, TableComment(..), TableId(..), TableName(..), TableStatus(..), Unique, UniqueName(..))
import Models.Utils exposing (Color, Position, Size)


buildSchema : List ( JsonTable, TableId ) -> Schema
buildSchema tables =
    buildSchemaType (buildTables tables)


buildSchemaType : Dict TableId Table -> Schema
buildSchemaType tables =
    { tables = tables, relations = buildRelations tables, layouts = [] }


buildTables : List ( JsonTable, TableId ) -> Dict TableId Table
buildTables tables =
    tables |> List.map (buildTable (Size 0 0) (Position 0 0)) |> dictFromList .id


buildTable : Size -> Position -> ( JsonTable, TableId ) -> Table
buildTable size position ( table, id ) =
    { id = id
    , schema = table.schema |> SchemaName
    , table = table.table |> TableName
    , columns = table.columns |> List.indexedMap buildColumn |> dictFromList .column
    , primaryKey = table.primaryKey |> Maybe.map buildPrimaryKey
    , uniques = table.uniques |> List.map buildUnique
    , indexes = table.indexes |> List.map buildIndex
    , comment = table.comment |> Maybe.map TableComment
    , state = { status = Uninitialized, color = buildColor id, size = size, position = position }
    }


buildColor : TableId -> Color
buildColor (TableId _ (TableName table)) =
    stringWordSplit table
        |> List.head
        |> Maybe.map stringHashCode
        |> Maybe.map (modBy (List.length colorList))
        |> Maybe.andThen (\index -> colorList |> listGet index)
        |> Maybe.withDefault conf.colors.grey


buildColumn : Int -> JsonColumn -> Column
buildColumn index column =
    { index = index |> ColumnIndex
    , column = column.column |> ColumnName
    , kind = column.kind |> ColumnType
    , nullable = column.nullable
    , foreignKey = column.reference |> Maybe.map buildForeignKey
    , comment = column.comment |> Maybe.map ColumnComment
    , state = { order = Just index }
    }


buildPrimaryKey : JsonPrimaryKey -> PrimaryKey
buildPrimaryKey pk =
    { columns = pk.columns |> List.map ColumnName
    , name = pk.name |> PrimaryKeyName
    }


buildUnique : JsonUnique -> Unique
buildUnique unique =
    { columns = unique.columns |> List.map ColumnName
    , name = unique.name |> UniqueName
    }


buildIndex : JsonIndex -> Index
buildIndex index =
    { columns = index.columns |> List.map ColumnName
    , definition = index.definition
    , name = index.name |> IndexName
    }


buildForeignKey : JsonForeignKey -> ForeignKey
buildForeignKey fk =
    { tableId = fk |> buildTableId
    , schema = fk.schema |> SchemaName
    , table = fk.table |> TableName
    , column = fk.column |> ColumnName
    , name = fk.name |> ForeignKeyName
    }


buildTableId : JsonForeignKey -> TableId
buildTableId fk =
    TableId (SchemaName fk.schema) (TableName fk.table)



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
