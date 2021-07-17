module TestHelpers.Fuzzers exposing (..)

import Conf exposing (conf)
import Dict exposing (Dict)
import Fuzz exposing (Fuzzer)
import Libs.Dict as D
import Libs.Fuzz as F
import Models.Schema exposing (CanvasProps, Column, ColumnComment(..), ColumnIndex(..), ColumnName, ColumnType(..), ColumnValue(..), FileInfo, ForeignKey, ForeignKeyName(..), Index, IndexName(..), Layout, LayoutName, PrimaryKey, PrimaryKeyName(..), Schema, SchemaId, SchemaInfo, SchemaName, Source, SourceLine, Table, TableComment(..), TableId, TableName, TableProps, Unique, UniqueName(..), buildSchema)
import Models.Utils exposing (Color, Position, Size, ZoomLevel)
import Time


schema : Fuzzer Schema
schema =
    F.map7 buildSchema (listSmall schemaId) schemaId schemaInfo (listSmall table) layout (Fuzz.maybe layoutName) (dictSmall layoutName layout)


schemaInfo : Fuzzer SchemaInfo
schemaInfo =
    Fuzz.map3 SchemaInfo posix posix (Fuzz.maybe fileInfo)


fileInfo : Fuzzer FileInfo
fileInfo =
    Fuzz.map2 FileInfo path posix


table : Fuzzer Table
table =
    F.map8 (\s t c p u i co so -> Table ( s, t ) s t c p u i co so)
        schemaName
        tableName
        (listSmall column |> Fuzz.map (D.fromList .column))
        (Fuzz.maybe primaryKey)
        (listSmall unique)
        (listSmall index)
        (Fuzz.maybe tableComment)
        (listSmall source)


column : Fuzzer Column
column =
    F.map7 Column columnIndex columnName columnType Fuzz.bool (Fuzz.maybe columnValue) (Fuzz.maybe foreignKey) (Fuzz.maybe columnComment)


primaryKey : Fuzzer PrimaryKey
primaryKey =
    Fuzz.map2 PrimaryKey (listSmall columnName) primaryKeyName


foreignKey : Fuzzer ForeignKey
foreignKey =
    Fuzz.map4 (\s t c f -> ForeignKey ( s, t ) s t c f) schemaName tableName columnName foreignKeyName


unique : Fuzzer Unique
unique =
    Fuzz.map3 Unique uniqueName (listSmall columnName) text


index : Fuzzer Index
index =
    Fuzz.map3 Index indexName (listSmall columnName) text


source : Fuzzer Source
source =
    Fuzz.map2 Source path (F.nel sourceLine)


sourceLine : Fuzzer SourceLine
sourceLine =
    Fuzz.map2 SourceLine (Fuzz.intRange 0 50000) text


layout : Fuzzer Layout
layout =
    Fuzz.map3 Layout canvasProps (dictSmall tableId tableProps) (dictSmall tableId tableProps)


canvasProps : Fuzzer CanvasProps
canvasProps =
    Fuzz.map2 CanvasProps position zoomLevel


tableProps : Fuzzer TableProps
tableProps =
    Fuzz.map4 TableProps position color Fuzz.bool (listSmall columnName)


position : Fuzzer Position
position =
    Fuzz.map2 Position
        (Fuzz.floatRange -10000 10000)
        (Fuzz.floatRange -10000 10000)


size : Fuzzer Size
size =
    Fuzz.map2 Size
        (Fuzz.floatRange 0 10000)
        (Fuzz.floatRange 0 10000)


schemaId : Fuzzer SchemaId
schemaId =
    identifier


layoutName : Fuzzer LayoutName
layoutName =
    identifier


tableId : Fuzzer TableId
tableId =
    Fuzz.tuple ( schemaName, tableName )


schemaName : Fuzzer SchemaName
schemaName =
    identifier


tableName : Fuzzer TableName
tableName =
    identifier


columnName : Fuzzer ColumnName
columnName =
    identifier


columnIndex : Fuzzer ColumnIndex
columnIndex =
    Fuzz.intRange 0 50 |> Fuzz.map ColumnIndex


columnType : Fuzzer ColumnType
columnType =
    Fuzz.oneOf ([ "int", "serial", "varchar", "timestamp", "bigint", "text", "boolean", "character varying(10)" ] |> List.map Fuzz.constant) |> Fuzz.map ColumnType


columnValue : Fuzzer ColumnValue
columnValue =
    Fuzz.oneOf ([ "1", "false", "''::public.hstore", "default value: 'fr'::character varying" ] |> List.map Fuzz.constant) |> Fuzz.map ColumnValue


primaryKeyName : Fuzzer PrimaryKeyName
primaryKeyName =
    Fuzz.map PrimaryKeyName identifier


foreignKeyName : Fuzzer ForeignKeyName
foreignKeyName =
    Fuzz.map ForeignKeyName identifier


uniqueName : Fuzzer UniqueName
uniqueName =
    Fuzz.map UniqueName identifier


indexName : Fuzzer IndexName
indexName =
    Fuzz.map IndexName identifier


tableComment : Fuzzer TableComment
tableComment =
    Fuzz.map TableComment text


columnComment : Fuzzer ColumnComment
columnComment =
    Fuzz.map ColumnComment text


zoomLevel : Fuzzer ZoomLevel
zoomLevel =
    Fuzz.floatRange conf.zoom.min conf.zoom.max


color : Fuzzer Color
color =
    Fuzz.oneOf (conf.colors |> List.map Fuzz.constant)



-- Generic fuzzers


dictSmall : Fuzzer comparable -> Fuzzer v -> Fuzzer (Dict comparable v)
dictSmall kFuzz vFuzz =
    Fuzz.tuple ( kFuzz, vFuzz ) |> listSmall |> Fuzz.map Dict.fromList


listSmall : Fuzzer a -> Fuzzer (List a)
listSmall fuzz =
    -- TODO: should find a way to randomize list size but keep it small efficiently
    -- Fuzz.list can generate long lists & F.listN generate only size of n list, generating a random int then chaining with listN will be best
    F.listN 3 fuzz


stringSmall : Fuzzer String
stringSmall =
    Fuzz.string |> Fuzz.map (String.slice 0 10)


identifier : Fuzzer String
identifier =
    -- TODO: this should generate valid sql identifiers (letters, digits, _)
    F.letter |> Fuzz.list |> Fuzz.map String.fromList


path : Fuzzer String
path =
    -- TODO: this should generate a file path
    F.letter |> Fuzz.list |> Fuzz.map String.fromList


text : Fuzzer String
text =
    -- TODO: this should generate a text "normal" text, for example for comments
    F.letter |> Fuzz.list |> Fuzz.map String.fromList


word : Fuzzer String
word =
    F.letter |> Fuzz.list |> Fuzz.map String.fromList


posix : Fuzzer Time.Posix
posix =
    Fuzz.intRange -10000000000 10000000000 |> Fuzz.map (\offset -> Time.millisToPosix (1626342639000 + offset))
