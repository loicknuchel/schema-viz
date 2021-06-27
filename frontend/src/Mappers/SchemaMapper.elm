module Mappers.SchemaMapper exposing (buildSchema)

import AssocList as Dict exposing (Dict)
import Conf exposing (conf)
import Decoders.SchemaDecoder exposing (JsonColumn, JsonForeignKey, JsonIndex, JsonPrimaryKey, JsonTable, JsonUnique)
import Libs.Std exposing (dictFromList)
import Models.Schema exposing (Column, ColumnComment(..), ColumnIndex(..), ColumnName(..), ColumnType(..), ForeignKey, ForeignKeyName(..), Index, IndexName(..), PrimaryKey, PrimaryKeyName(..), RelationRef, Schema, SchemaName(..), Table, TableComment(..), TableId(..), TableName(..), TableStatus(..), Unique, UniqueName(..))
import Models.Utils exposing (Color, Position, Size)


buildSchema : List ( JsonTable, TableId ) -> Schema
buildSchema tables =
    buildSchemaType (buildTables tables)


buildSchemaType : Dict TableId Table -> Schema
buildSchemaType tables =
    { tables = tables, relations = buildRelations tables }


buildTables : List ( JsonTable, TableId ) -> Dict TableId Table
buildTables tables =
    dictFromList .id (List.map (buildTable conf.colors.grey (Size 0 0) (Position 0 0)) tables)


buildTable : Color -> Size -> Position -> ( JsonTable, TableId ) -> Table
buildTable color size position ( table, id ) =
    { id = id
    , schema = SchemaName table.schema
    , table = TableName table.table
    , columns = dictFromList .column (List.indexedMap buildColumn table.columns)
    , primaryKey = Maybe.map buildPrimaryKey table.primaryKey
    , uniques = List.map buildUnique table.uniques
    , indexes = List.map buildIndex table.indexes
    , comment = Maybe.map TableComment table.comment
    , state = { status = Uninitialized, color = color, size = size, position = position }
    }


buildColumn : Int -> JsonColumn -> Column
buildColumn index column =
    { index = ColumnIndex index
    , column = ColumnName column.column
    , kind = ColumnType column.kind
    , nullable = column.nullable
    , foreignKey = Maybe.map buildForeignKey column.reference
    , comment = Maybe.map ColumnComment column.comment
    , state = { order = Just index }
    }


buildPrimaryKey : JsonPrimaryKey -> PrimaryKey
buildPrimaryKey pk =
    { columns = List.map ColumnName pk.columns
    , name = PrimaryKeyName pk.name
    }


buildUnique : JsonUnique -> Unique
buildUnique unique =
    { columns = List.map ColumnName unique.columns
    , name = UniqueName unique.name
    }


buildIndex : JsonIndex -> Index
buildIndex index =
    { columns = List.map ColumnName index.columns
    , definition = index.definition
    , name = IndexName index.name
    }


buildForeignKey : JsonForeignKey -> ForeignKey
buildForeignKey fk =
    { tableId = buildTableId fk
    , schema = SchemaName fk.schema
    , table = TableName fk.table
    , column = ColumnName fk.column
    , name = ForeignKeyName fk.name
    }


buildTableId : JsonForeignKey -> TableId
buildTableId fk =
    TableId (SchemaName fk.schema) (TableName fk.table)



-- build relations


buildRelations : Dict TableId Table -> List RelationRef
buildRelations tables =
    List.foldr (\table res -> buildTableRelations table ++ res) [] (Dict.values tables)


buildTableRelations : Table -> List RelationRef
buildTableRelations table =
    List.filterMap (\col -> Maybe.map (buildRelation table col) col.foreignKey) (Dict.values table.columns)


buildRelation : Table -> Column -> ForeignKey -> RelationRef
buildRelation table column fk =
    { key = fk.name, src = { table = table.id, column = column.column }, ref = { table = fk.tableId, column = fk.column }, state = { show = True } }
