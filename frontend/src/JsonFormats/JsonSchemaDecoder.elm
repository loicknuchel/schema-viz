module JsonFormats.JsonSchemaDecoder exposing (JsonColumn, JsonForeignKey, JsonIndex, JsonPrimaryKey, JsonSchema, JsonTable, JsonUnique, schemaDecoder)

import Json.Decode exposing (Decoder, bool, field, list, map, map2, map3, map4, map6, map7, maybe, string)



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
    , indexes : List JsonIndex
    , uniques : List JsonUnique
    , comment : Maybe String
    }


type alias JsonColumn =
    { column : String
    , kind : String
    , nullable : Bool
    , default : Maybe String
    , reference : Maybe JsonForeignKey
    , comment : Maybe String
    }


type alias JsonPrimaryKey =
    { columns : List String, name : String }


type alias JsonIndex =
    { name : String, columns : List String, definition : String }


type alias JsonUnique =
    { name : String, columns : List String, definition : String }


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
        (field "indexes" (list indexDecoder))
        (field "uniques" (list uniqueIndexDecoder))
        (maybe (field "comment" string))


columnDecoder : Decoder JsonColumn
columnDecoder =
    map6 JsonColumn
        (field "column" string)
        (field "type" string)
        (field "nullable" bool)
        (maybe (field "default" string))
        (maybe (field "reference" foreignKeyDecoder))
        (maybe (field "comment" string))


primaryKeyDecoder : Decoder JsonPrimaryKey
primaryKeyDecoder =
    map2 JsonPrimaryKey
        (field "columns" (list string))
        (field "name" string)


uniqueIndexDecoder : Decoder JsonUnique
uniqueIndexDecoder =
    map3 JsonUnique
        (field "name" string)
        (field "columns" (list string))
        (field "definition" string)


indexDecoder : Decoder JsonIndex
indexDecoder =
    map3 JsonIndex
        (field "name" string)
        (field "columns" (list string))
        (field "definition" string)


foreignKeyDecoder : Decoder JsonForeignKey
foreignKeyDecoder =
    map4 JsonForeignKey
        (field "schema" string)
        (field "table" string)
        (field "column" string)
        (field "name" string)
