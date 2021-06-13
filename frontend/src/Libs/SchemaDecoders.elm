module Libs.SchemaDecoders exposing (..)

import Json.Decode exposing (Decoder, field, list, map, map2, map4, map6, maybe, string)


type alias Schema =
    { tables : List Table }


type alias Table =
    { id : TableId, schema : SchemaName, table : TableName, columns : List Column, primaryKey : Maybe PrimaryKey, uniques : List UniqueIndex, comment : Maybe TableComment }


type alias Column =
    { column : ColumnName, kind : ColumnType, reference : Maybe ForeignKey, comment : Maybe ColumnComment }


type PrimaryKey
    = PrimaryKey PrimaryKeyRecord


type alias PrimaryKeyRecord =
    { columns : List ColumnName, name : PrimaryKeyName }


type alias UniqueIndex =
    { columns : List ColumnName, name : UniqueIndexName }


type alias ForeignKey =
    { schema : SchemaName, table : TableName, column : ColumnName, name : ForeignKeyName }


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


type ColumnName
    = ColumnName String


type ColumnType
    = ColumnType String


type PrimaryKeyName
    = PrimaryKeyName String


type UniqueIndexName
    = UniqueIndexName String


type ForeignKeyName
    = ForeignKeyName String


schemaDecoder : Decoder Schema
schemaDecoder =
    map Schema
        (field "tables" (list tableDecoder))


tableDecoder : Decoder Table
tableDecoder =
    map6 (\schema table columns primaryKey uniques comment -> Table (buildTableId schema table) schema table columns primaryKey uniques comment)
        (field "schema" schemaNameDecoder)
        (field "table" tableNameDecoder)
        (field "columns" (list columnDecoder))
        (maybe (field "primaryKey" primaryKeyDecoder))
        (field "uniques" (list uniqueIndexDecoder))
        (maybe (field "comment" tableCommentDecoder))


buildTableId : SchemaName -> TableName -> TableId
buildTableId schema table =
    case ( schema, table ) of
        ( SchemaName schemaName, TableName tableName ) ->
            TableId (schemaName ++ "." ++ tableName)


columnDecoder : Decoder Column
columnDecoder =
    map4 Column
        (field "column" columnNameDecoder)
        (field "type" columnTypeDecoder)
        (maybe (field "reference" foreignKeyDecoder))
        (maybe (field "comment" columnCommentDecoder))


primaryKeyDecoder : Decoder PrimaryKey
primaryKeyDecoder =
    map PrimaryKey
        (map2 PrimaryKeyRecord
            (field "columns" (list columnNameDecoder))
            (field "name" primaryKeyNameDecoder)
        )


uniqueIndexDecoder : Decoder UniqueIndex
uniqueIndexDecoder =
    map2 UniqueIndex
        (field "columns" (list columnNameDecoder))
        (field "name" uniqueIndexNameDecoder)


foreignKeyDecoder : Decoder ForeignKey
foreignKeyDecoder =
    map4 ForeignKey
        (field "schema" schemaNameDecoder)
        (field "table" tableNameDecoder)
        (field "column" columnNameDecoder)
        (field "name" foreignKeyNameDecoder)


tableCommentDecoder : Decoder TableComment
tableCommentDecoder =
    map TableComment string


columnCommentDecoder : Decoder ColumnComment
columnCommentDecoder =
    map ColumnComment string


schemaNameDecoder : Decoder SchemaName
schemaNameDecoder =
    map SchemaName string


tableNameDecoder : Decoder TableName
tableNameDecoder =
    map TableName string


columnNameDecoder : Decoder ColumnName
columnNameDecoder =
    map ColumnName string


columnTypeDecoder : Decoder ColumnType
columnTypeDecoder =
    map ColumnType string


primaryKeyNameDecoder : Decoder PrimaryKeyName
primaryKeyNameDecoder =
    map PrimaryKeyName string


uniqueIndexNameDecoder : Decoder UniqueIndexName
uniqueIndexNameDecoder =
    map UniqueIndexName string


foreignKeyNameDecoder : Decoder ForeignKeyName
foreignKeyNameDecoder =
    map ForeignKeyName string
