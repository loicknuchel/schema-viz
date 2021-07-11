module JsonFormats.SchemaFormatTest exposing (..)

import AssocList as Dict
import Expect exposing (Expectation)
import Json.Decode as Decode
import Json.Encode as Encode
import JsonFormats.SchemaFormat exposing (..)
import Libs.Dict as D
import Models.Schema exposing (CanvasProps, Column, ColumnIndex(..), ColumnName(..), ColumnProps, ColumnState, ColumnType(..), ColumnValue(..), ForeignKey, ForeignKeyName(..), Index, IndexName(..), Layout, PrimaryKey, PrimaryKeyName(..), Schema, SchemaInfo, SchemaName(..), Table, TableId(..), TableName(..), TableProps, TableState, TableStatus(..), Unique, UniqueName(..))
import Models.Utils exposing (Position, Size)
import Test exposing (Test, describe, test)
import Time


size : Size
size =
    { width = 42.3, height = 5 }


position : Position
position =
    { left = 12.1, top = 23.4 }


columnProps : ColumnProps
columnProps =
    { position = 2 }


tableProps : TableProps
tableProps =
    { position = position, color = "green", columns = Dict.fromList [ ( ColumnName "id", columnProps ) ] }


canvasProps : CanvasProps
canvasProps =
    { zoom = 0.5, position = position }


tableId : TableId
tableId =
    TableId (SchemaName "public") (TableName "users")


layout : Layout
layout =
    { name = "layout", canvas = canvasProps, tables = Dict.fromList [ ( tableId, tableProps ) ] }


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


columnState : ColumnState
columnState =
    { order = Just 1 }


column : Column
column =
    { index = ColumnIndex 1, column = columnName, kind = ColumnType "int", nullable = False, default = Just (ColumnValue "1"), foreignKey = Nothing, comment = Nothing, state = columnState }


tableStatus : TableStatus
tableStatus =
    Shown


tableState : TableState
tableState =
    { status = Uninitialized, size = size, position = position, color = "red", selected = False }


table : Table
table =
    { id = tableId, schema = SchemaName "public", table = TableName "users", columns = D.fromList .column [ column ], primaryKey = Nothing, uniques = [], indexes = [], comment = Nothing, state = tableState }


info : SchemaInfo
info =
    { created = Time.millisToPosix 1234, updated = Time.millisToPosix 4321, file = Nothing }


schema : Schema
schema =
    { name = "a schema", info = info, layouts = [ layout ], tables = D.fromList .id [ table ], relations = [] }



-- TODO use fuzzy tests for encode/decode
-- TODO have a fixed JSON to check retro-compatibility


suite : Test
suite =
    describe "SchemaFormatTest"
        [ test "encode/decode Schema" (\_ -> schema |> expectRoundTrip encodeSchema (decodeSchema []))
        , test "encode/decode SchemaInfo" (\_ -> info |> expectRoundTrip encodeInfo decodeInfo)
        , test "encode/decode Table" (\_ -> table |> expectRoundTrip encodeTable decodeTable)
        , test "encode/decode TableState" (\_ -> tableState |> expectRoundTrip (encodeTableState tableState) (decodeTableState tableState))
        , test "encode/decode TableStatus" (\_ -> tableStatus |> expectRoundTrip encodeTableStatus decodeTableStatus)
        , test "encode/decode Column" (\_ -> column |> expectRoundTrip encodeColumn decodeColumn)
        , test "encode/decode ColumnState" (\_ -> columnState |> expectRoundTrip encodeColumnState decodeColumnState)
        , test "encode/decode PrimaryKey" (\_ -> primaryKey |> expectRoundTrip encodePrimaryKey decodePrimaryKey)
        , test "encode/decode Unique" (\_ -> unique |> expectRoundTrip encodeUnique decodeUnique)
        , test "encode/decode Index" (\_ -> index |> expectRoundTrip encodeIndex decodeIndex)
        , test "encode/decode ForeignKey" (\_ -> foreignKey |> expectRoundTrip encodeForeignKey decodeForeignKey)
        , test "encode/decode ColumnName" (\_ -> columnName |> expectRoundTrip encodeColumnName decodeColumnName)
        , test "encode/decode Layout" (\_ -> layout |> expectRoundTrip encodeLayout decodeLayout)
        , test "encode/decode CanvasProps" (\_ -> canvasProps |> expectRoundTrip encodeCanvasProps decodeCanvasProps)
        , test "encode/decode TableProps" (\_ -> tableProps |> expectRoundTrip encodeTableProps decodeTableProps)
        , test "encode/decode ColumnProps" (\_ -> columnProps |> expectRoundTrip encodeColumnProps decodeColumnProps)
        , test "encode/decode Position" (\_ -> position |> expectRoundTrip encodePosition decodePosition)
        , test "encode/decode Size" (\_ -> size |> expectRoundTrip encodeSize decodeSize)
        ]


expectRoundTrip : (a -> Encode.Value) -> Decode.Decoder a -> a -> Expectation
expectRoundTrip encode decoder a =
    a |> encode |> Encode.encode 0 |> Decode.decodeString decoder |> Expect.equal (Ok a)
