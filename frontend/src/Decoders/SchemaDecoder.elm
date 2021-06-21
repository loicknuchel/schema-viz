module Decoders.SchemaDecoder exposing (JsonColumn, JsonForeignKey, JsonIndex, JsonPrimaryKey, JsonSchema, JsonTable, JsonUnique, schemaDecoder)

import Json.Decode exposing (Decoder, bool, field, list, map, map2, map3, map4, map5, map7, maybe, string)



-- decode schema json into JsonSchema type.
-- Should mimic json structure to avoid any business logic that could fail.
-- So it's very stable and any error here should be from a bad json structure, no code error (very basic).


type alias JsonSchema =
    { tables : List JsonTable }


type alias JsonTable =
    { schema : String
    , table : String
    , columns : List JsonColumn
    , primaryKey : Maybe JsonPrimaryKey
    , uniques : List JsonUnique
    , indexes : List JsonIndex
    , comment : Maybe String
    }


type alias JsonColumn =
    { column : String
    , kind : String
    , nullable : Bool
    , reference : Maybe JsonForeignKey
    , comment : Maybe String
    }


type alias JsonPrimaryKey =
    { columns : List String, name : String }


type alias JsonUnique =
    { columns : List String, name : String }


type alias JsonIndex =
    { columns : List String, definition : String, name : String }


type alias JsonForeignKey =
    { schema : String, table : String, column : String, name : String }


schemaDecoder : Decoder JsonSchema
schemaDecoder =
    map JsonSchema
        (field "tables" (list tableDecoder))


tableDecoder : Decoder JsonTable
tableDecoder =
    map7 JsonTable
        (field "schema" string)
        (field "table" string)
        (field "columns" (list columnDecoder))
        (maybe (field "primary_key" primaryKeyDecoder))
        (field "uniques" (list uniqueIndexDecoder))
        (field "indexes" (list indexDecoder))
        (maybe (field "comment" string))


columnDecoder : Decoder JsonColumn
columnDecoder =
    map5 JsonColumn
        (field "column" string)
        (field "type" string)
        (field "nullable" bool)
        (maybe (field "reference" foreignKeyDecoder))
        (maybe (field "comment" string))


primaryKeyDecoder : Decoder JsonPrimaryKey
primaryKeyDecoder =
    map2 JsonPrimaryKey
        (field "columns" (list string))
        (field "name" string)


uniqueIndexDecoder : Decoder JsonUnique
uniqueIndexDecoder =
    map2 JsonUnique
        (field "columns" (list string))
        (field "name" string)


indexDecoder : Decoder JsonIndex
indexDecoder =
    map3 JsonIndex
        (field "columns" (list string))
        (field "definition" string)
        (field "name" string)


foreignKeyDecoder : Decoder JsonForeignKey
foreignKeyDecoder =
    map4 JsonForeignKey
        (field "schema" string)
        (field "table" string)
        (field "column" string)
        (field "name" string)
