module Models.Schema exposing (..)

import Json.Decode exposing (Decoder, field, list, map, map2, map4, map6, maybe, string)


type ColumnName
    = ColumnName String


type ColumnType
    = ColumnType String


type ColumnComment
    = ColumnComment String


type ForeignKeyName
    = ForeignKeyName String


type TableName
    = TableName String


type PrimaryKeyName
    = PrimaryKeyName String


type UniqueIndexName
    = UniqueIndexName String


type TableComment
    = TableComment String


type SchemaName
    = SchemaName String


type alias ForeignKey =
    { schema : SchemaName, table : TableName, column : ColumnName, name : ForeignKeyName }


type alias Column =
    { column : ColumnName, kind : ColumnType, reference : Maybe ForeignKey, comment : Maybe ColumnComment }


type PrimaryKey
    = PrimaryKey PrimaryKeyRecord


type alias PrimaryKeyRecord =
    { columns : List ColumnName, name : PrimaryKeyName }


type alias UniqueIndex =
    { columns : List ColumnName, name : UniqueIndexName }


type alias Table =
    { schema : SchemaName, table : TableName, columns : List Column, primaryKey : Maybe PrimaryKey, uniques : List UniqueIndex, comment : Maybe TableComment }


type alias Schema =
    { tables : List Table }


columnNameDecoder : Decoder ColumnName
columnNameDecoder =
    map ColumnName string


columnTypeDecoder : Decoder ColumnType
columnTypeDecoder =
    map ColumnType string


columnCommentDecoder : Decoder ColumnComment
columnCommentDecoder =
    map ColumnComment string


foreignKeyNameDecoder : Decoder ForeignKeyName
foreignKeyNameDecoder =
    map ForeignKeyName string


tableNameDecoder : Decoder TableName
tableNameDecoder =
    map TableName string


primaryKeyNameDecoder : Decoder PrimaryKeyName
primaryKeyNameDecoder =
    map PrimaryKeyName string


uniqueIndexNameDecoder : Decoder UniqueIndexName
uniqueIndexNameDecoder =
    map UniqueIndexName string


tableCommentDecoder : Decoder TableComment
tableCommentDecoder =
    map TableComment string


schemaNameDecoder : Decoder SchemaName
schemaNameDecoder =
    map SchemaName string


foreignKeyDecoder : Decoder ForeignKey
foreignKeyDecoder =
    map4 ForeignKey
        (field "schema" schemaNameDecoder)
        (field "table" tableNameDecoder)
        (field "column" columnNameDecoder)
        (field "name" foreignKeyNameDecoder)


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


tableDecoder : Decoder Table
tableDecoder =
    map6 Table
        (field "schema" schemaNameDecoder)
        (field "table" tableNameDecoder)
        (field "columns" (list columnDecoder))
        (maybe (field "primaryKey" primaryKeyDecoder))
        (field "uniques" (list uniqueIndexDecoder))
        (maybe (field "comment" tableCommentDecoder))


schemaDecoder : Decoder Schema
schemaDecoder =
    map Schema
        (field "tables" (list tableDecoder))
