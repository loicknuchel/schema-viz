module Commands.RenderLayout exposing (buildTable, renderLayout)

import AssocList as Dict exposing (Dict)
import Decoders.SchemaDecoder exposing (JsonColumn, JsonForeignKey, JsonIndex, JsonPrimaryKey, JsonTable, JsonUnique)
import Libs.Std exposing (dictFromList, genChoose, genSequence, listCollect)
import Models exposing (Msg(..), WindowSize, conf)
import Models.Schema exposing (Column, ColumnComment(..), ColumnIndex(..), ColumnName(..), ColumnType(..), ForeignKey, ForeignKeyName(..), Index, IndexName(..), PrimaryKey, PrimaryKeyName(..), Schema, SchemaName(..), Table, TableComment(..), TableId(..), TableName(..), Unique, UniqueName(..))
import Models.Utils exposing (Color, Position, Size)
import Random



-- build the initial app layout having all the required data


renderLayout : List ( JsonTable, TableId, Size ) -> WindowSize -> Cmd Msg
renderLayout tables windowSize =
    Random.generate (\schema -> GotLayout schema 1 (Position 0 0)) (schemaGen tables windowSize)



-- RANDOM GENERATORS


schemaGen : List ( JsonTable, TableId, Size ) -> WindowSize -> Random.Generator Schema
schemaGen tables windowSize =
    Random.map (\result -> buildSchema (dictFromList .id result)) (tablesGen tables windowSize)


tablesGen : List ( JsonTable, TableId, Size ) -> WindowSize -> Random.Generator (List Table)
tablesGen tables windowSize =
    genSequence (List.map (\table -> tableGen table windowSize) tables)


tableGen : ( JsonTable, TableId, Size ) -> WindowSize -> Random.Generator Table
tableGen ( table, id, size ) windowSize =
    Random.map2 (buildTable table id size) (positionGen size windowSize) colorGen


positionGen : Size -> WindowSize -> Random.Generator Position
positionGen table windowSize =
    Random.map2 (\w h -> Position w h) (Random.float 0 (windowSize.width - table.width)) (Random.float 0 (windowSize.height - table.height))


colorGen : Random.Generator Color
colorGen =
    case conf.colors of
        { pink, purple, darkBlue, blue, turquoise, lightBlue, lightGreen, green, yellow, orange, red, grey } ->
            genChoose ( pink, [ purple, darkBlue, blue, turquoise, lightBlue, lightGreen, green, yellow, orange, red, grey ] )



-- data transformers


buildSchema : Dict TableId Table -> Schema
buildSchema tables =
    { tables = tables, relations = buildRelations tables }


buildTable : JsonTable -> TableId -> Size -> Position -> Color -> Table
buildTable table id size position color =
    { id = id
    , schema = SchemaName table.schema
    , table = TableName table.table
    , columns = dictFromList .column (List.reverse (List.indexedMap buildColumn table.columns))
    , primaryKey = Maybe.map buildPrimaryKey table.primaryKey
    , uniques = List.map buildUnique table.uniques
    , indexes = List.map buildIndex table.indexes
    , comment = Maybe.map TableComment table.comment
    , state = { size = size, position = position, color = color, show = True }
    }


buildColumn : Int -> JsonColumn -> Column
buildColumn index column =
    { index = ColumnIndex index
    , column = ColumnName column.column
    , kind = ColumnType column.kind
    , nullable = column.nullable
    , foreignKey = Maybe.map buildForeignKey column.reference
    , comment = Maybe.map ColumnComment column.comment
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
    { tableId = buildTableId fk.schema fk.table
    , schema = SchemaName fk.schema
    , table = TableName fk.table
    , column = ColumnName fk.column
    , name = ForeignKeyName fk.name
    }


buildTableId : String -> String -> TableId
buildTableId schema table =
    TableId (schema ++ "." ++ table)



-- build relations


buildRelations : Dict TableId Table -> List ( ForeignKey, ( Table, Column ), ( Table, Column ) )
buildRelations tables =
    List.foldr (\table res -> includeRefTable tables (getColumnsWithForeignKey table) ++ res) [] (Dict.values tables)


includeRefTable : Dict TableId Table -> List ( ForeignKey, ( Table, Column ) ) -> List ( ForeignKey, ( Table, Column ), ( Table, Column ) )
includeRefTable tables relations =
    listCollect (\( fk, src ) -> Maybe.map (\ref -> ( fk, src, ref )) (getTableAndColumn ( fk.tableId, fk.column ) tables)) relations


getTableAndColumn : ( TableId, ColumnName ) -> Dict TableId Table -> Maybe ( Table, Column )
getTableAndColumn ( tableId, columnName ) tables =
    Maybe.andThen (\table -> Maybe.map (\column -> ( table, column )) (Dict.get columnName table.columns)) (Dict.get tableId tables)


getColumnsWithForeignKey : Table -> List ( ForeignKey, ( Table, Column ) )
getColumnsWithForeignKey table =
    listCollect (\column -> Maybe.map (\fk -> ( fk, ( table, column ) )) column.foreignKey) (Dict.values table.columns)
