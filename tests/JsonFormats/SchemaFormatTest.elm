module JsonFormats.SchemaFormatTest exposing (..)

import AssocList as Dict
import Expect exposing (Expectation)
import Json.Decode as Decode
import Json.Encode as Encode
import JsonFormats.SchemaFormat exposing (..)
import Libs.Dict as D
import Models.Schema exposing (CanvasProps, Column, ColumnIndex(..), ColumnName(..), ColumnType(..), ColumnValue(..), ForeignKey, ForeignKeyName(..), Index, IndexName(..), Layout, PrimaryKey, PrimaryKeyName(..), Schema, SchemaInfo, SchemaName(..), Table, TableId(..), TableName(..), TableProps, Unique, UniqueName(..))
import Models.Utils exposing (Position, Size)
import Test exposing (Test, describe, test)
import Time


size : Size
size =
    { width = 42.3, height = 5 }


position : Position
position =
    { left = 12.1, top = 23.4 }


tableProps : TableProps
tableProps =
    { position = position, color = "green", selected = False, columns = [ ColumnName "id" ] }


canvasProps : CanvasProps
canvasProps =
    { zoom = 0.5, position = position }


tableId : TableId
tableId =
    TableId (SchemaName "public") (TableName "users")


layout : Layout
layout =
    { canvas = canvasProps, tables = Dict.fromList [ ( tableId, tableProps ) ], hiddenTables = Dict.empty }


columnName : ColumnName
columnName =
    ColumnName "id"


foreignKey : ForeignKey
foreignKey =
    { tableId = tableId, schema = SchemaName "public", table = TableName "users", column = columnName, name = ForeignKeyName "users_pk" }


index : Index
index =
    { name = IndexName "name_index", columns = [ ColumnName "name" ], definition = "btree (name)" }


unique : Unique
unique =
    { name = UniqueName "email_unique", columns = [ ColumnName "email" ], definition = "(email)" }


primaryKey : PrimaryKey
primaryKey =
    { columns = [ ColumnName "id" ], name = PrimaryKeyName "id_pk" }


column : Column
column =
    { index = ColumnIndex 1
    , column = columnName
    , kind = ColumnType "int"
    , nullable = False
    , default = Just (ColumnValue "1")
    , foreignKey = Nothing
    , comment = Nothing
    }


table : Table
table =
    { id = tableId
    , schema = SchemaName "public"
    , table = TableName "users"
    , columns = D.fromList .column [ column ]
    , primaryKey = Nothing
    , uniques = []
    , indexes = []
    , comment = Nothing
    , sources = []
    }


info : SchemaInfo
info =
    { created = Time.millisToPosix 1234, updated = Time.millisToPosix 4321, file = Nothing }


schema : Schema
schema =
    { id = "a schema", info = info, tables = D.fromList .id [ table ], relations = [], layout = layout, layoutName = Nothing, layouts = Dict.empty }



-- TODO use fuzzy tests for encode/decode
-- TODO have a fixed JSON to check retro-compatibility


suite : Test
suite =
    describe "SchemaFormatTest"
        [ test "encode/decode Schema" (\_ -> schema |> expectRoundTrip encodeSchema (decodeSchema []))
        , test "encode/decode SchemaInfo" (\_ -> info |> expectRoundTrip encodeInfo decodeInfo)
        , test "encode/decode Table" (\_ -> table |> expectRoundTrip encodeTable decodeTable)
        , test "encode/decode Column" (\_ -> column |> expectRoundTrip encodeColumn decodeColumn)
        , test "encode/decode PrimaryKey" (\_ -> primaryKey |> expectRoundTrip encodePrimaryKey decodePrimaryKey)
        , test "encode/decode Unique" (\_ -> unique |> expectRoundTrip encodeUnique decodeUnique)
        , test "encode/decode Index" (\_ -> index |> expectRoundTrip encodeIndex decodeIndex)
        , test "encode/decode ForeignKey" (\_ -> foreignKey |> expectRoundTrip encodeForeignKey decodeForeignKey)
        , test "encode/decode ColumnName" (\_ -> columnName |> expectRoundTrip encodeColumnName decodeColumnName)
        , test "encode/decode Layout" (\_ -> layout |> expectRoundTrip encodeLayout decodeLayout)
        , test "encode/decode CanvasProps" (\_ -> canvasProps |> expectRoundTrip encodeCanvasProps decodeCanvasProps)
        , test "encode/decode TableProps" (\_ -> tableProps |> expectRoundTrip encodeTableProps decodeTableProps)
        , test "encode/decode Position" (\_ -> position |> expectRoundTrip encodePosition decodePosition)
        , test "encode/decode Size" (\_ -> size |> expectRoundTrip encodeSize decodeSize)
        ]


expectRoundTrip : (a -> Encode.Value) -> Decode.Decoder a -> a -> Expectation
expectRoundTrip encode decoder a =
    a |> encode |> Encode.encode 0 |> Decode.decodeString decoder |> Expect.equal (Ok a)
