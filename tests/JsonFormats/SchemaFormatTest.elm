module JsonFormats.SchemaFormatTest exposing (..)

import Dict
import Expect exposing (Expectation)
import Json.Decode as Decode
import Json.Encode as Encode
import JsonFormats.SchemaFormat exposing (..)
import Libs.Dict as D
import Libs.Ned as Ned
import Libs.Nel exposing (Nel)
import Libs.Position exposing (Position)
import Models.Schema exposing (CanvasProps, Column, ColumnComment(..), ColumnIndex(..), ColumnRef, ColumnType(..), ColumnValue(..), FileInfo, ForeignKey, ForeignKeyName(..), Index, IndexName(..), Layout, PrimaryKey, PrimaryKeyName(..), RelationRef, Schema, SchemaInfo, Source, SourceLine, TableComment(..), TableProps, Unique, UniqueName(..))
import Test exposing (Test, describe, fuzz, test)
import TestHelpers.Fuzzers as Fuzzers
import Time


schema0 : Schema
schema0 =
    { id = "schema-0"
    , info = SchemaInfo (Time.millisToPosix 12) (Time.millisToPosix 42) Nothing
    , tables = Dict.empty
    , incomingRelations = Dict.empty
    , layout = Layout (CanvasProps (Position 5 8) 0.5) Dict.empty Dict.empty
    , layoutName = Nothing
    , layouts = Dict.empty
    }


schema0Json : String
schema0Json =
    """{"id":"schema-0","info":{"created":12,"updated":42},"tables":[],"layout":{"canvas":{"position":{"left":5,"top":8},"zoom":0.5}}}"""


schema1 : Schema
schema1 =
    { id = "schema-1"
    , info = SchemaInfo (Time.millisToPosix 12) (Time.millisToPosix 42) (Just (FileInfo "structure.sql" (Time.millisToPosix 58)))
    , tables =
        D.fromListMap .id
            [ { id = ( "public", "users" )
              , schema = "public"
              , table = "users"
              , columns = Ned.singletonMap .column (Column (ColumnIndex 1) "id" (ColumnType "int") False Nothing Nothing Nothing)
              , primaryKey = Nothing
              , uniques = []
              , indexes = []
              , comment = Nothing
              , sources = []
              }
            ]
    , incomingRelations = Dict.empty
    , layout = Layout (CanvasProps (Position 5 8) 0.5) (Dict.fromList [ ( ( "public", "users" ), TableProps (Position 1 2) "red" False [] ) ]) Dict.empty
    , layoutName = Nothing
    , layouts = Dict.fromList [ ( "empty", Layout (CanvasProps (Position 3 6) 1) Dict.empty Dict.empty ) ]
    }


schema1Json : String
schema1Json =
    """{"id":"schema-1","info":{"created":12,"updated":42,"file":{"name":"structure.sql","lastModified":58}},"tables":[{"schema":"public","table":"users","columns":[{"index":1,"name":"id","type":"int","nullable":false}]}],"layout":{"canvas":{"position":{"left":5,"top":8},"zoom":0.5},"tables":{"public.users":{"position":{"left":1,"top":2},"color":"red"}}},"layouts":{"empty":{"canvas":{"position":{"left":3,"top":6},"zoom":1}}}}"""


schema2 : Schema
schema2 =
    { id = "schema-2"
    , info = SchemaInfo (Time.millisToPosix 12) (Time.millisToPosix 42) (Just (FileInfo "structure.sql" (Time.millisToPosix 58)))
    , tables =
        D.fromListMap .id
            [ { id = ( "public", "users" )
              , schema = "public"
              , table = "users"
              , columns =
                    Ned.buildMap .column
                        (Column (ColumnIndex 1) "id" (ColumnType "int") False Nothing Nothing Nothing)
                        [ Column (ColumnIndex 2) "name" (ColumnType "varchar") True Nothing Nothing Nothing ]
              , primaryKey = Just (PrimaryKey (PrimaryKeyName "users_pk") (Nel "id" []))
              , uniques = []
              , indexes = []
              , comment = Nothing
              , sources = [ Source "structure.sql" (Nel (SourceLine 10 "CREATE TABLE users") [ SourceLine 11 "  (id int NOT NULL, name varchar);" ]) ]
              }
            , { id = ( "public", "creds" )
              , schema = "public"
              , table = "creds"
              , columns =
                    Ned.buildMap .column
                        (Column (ColumnIndex 1) "user_id" (ColumnType "int") False Nothing (Just (ForeignKey (ForeignKeyName "creds_user_id") ( "public", "users" ) "id")) Nothing)
                        [ Column (ColumnIndex 2) "login" (ColumnType "varchar") False Nothing Nothing Nothing
                        , Column (ColumnIndex 3) "pass" (ColumnType "varchar") False Nothing Nothing (Just (ColumnComment "Encrypted field"))
                        , Column (ColumnIndex 4) "role" (ColumnType "varchar") True (Just (ColumnValue "guest")) Nothing Nothing
                        ]
              , primaryKey = Nothing
              , uniques = [ Unique (UniqueName "unique_login") (Nel "login" []) "(login)" ]
              , indexes = [ Index (IndexName "role_idx") (Nel "role" []) "(role)" ]
              , comment = Just (TableComment "To allow users to login")
              , sources = []
              }
            ]
    , incomingRelations = Dict.fromList [ ( ( "public", "users" ), [ RelationRef (ForeignKeyName "creds_user_id") (ColumnRef ( "public", "creds" ) "user_id") (ColumnRef ( "public", "users" ) "id") ] ) ]
    , layout = Layout (CanvasProps (Position 5 8) 0.5) (Dict.fromList [ ( ( "public", "users" ), TableProps (Position 1 2) "red" True [ "id", "name" ] ) ]) (Dict.fromList [ ( ( "public", "creds" ), TableProps (Position 0 0) "blue" False [ "login", "pass" ] ) ])
    , layoutName = Just "users"
    , layouts =
        Dict.fromList
            [ ( "link", Layout (CanvasProps (Position 32 13) 1.5) (Dict.fromList [ ( ( "public", "users" ), TableProps (Position 90 102) "red" True [ "id" ] ), ( ( "public", "creds" ), TableProps (Position 0 0) "blue" False [ "user_id" ] ) ]) Dict.empty )
            , ( "empty", Layout (CanvasProps (Position 3 6) 1) Dict.empty Dict.empty )
            ]
    }


schema2Json : String
schema2Json =
    """{"id":"schema-2","info":{"created":12,"updated":42,"file":{"name":"structure.sql","lastModified":58}},"tables":["""
        ++ """{"schema":"public","table":"creds","columns":[{"index":1,"name":"user_id","type":"int","nullable":false,"foreignKey":{"name":"creds_user_id","schema":"public","table":"users","column":"id"}},{"index":2,"name":"login","type":"varchar","nullable":false},{"index":3,"name":"pass","type":"varchar","nullable":false,"comment":"Encrypted field"},{"index":4,"name":"role","type":"varchar","default":"guest"}],"uniques":[{"name":"unique_login","columns":["login"],"definition":"(login)"}],"indexes":[{"name":"role_idx","columns":["role"],"definition":"(role)"}],"comment":"To allow users to login"},"""
        ++ """{"schema":"public","table":"users","columns":[{"index":1,"name":"id","type":"int","nullable":false},{"index":2,"name":"name","type":"varchar"}],"primaryKey":{"name":"users_pk","columns":["id"]},"sources":[{"file":"structure.sql","lines":[{"no":10,"text":"CREATE TABLE users"},{"no":11,"text":"  (id int NOT NULL, name varchar);"}]}]}"""
        ++ """],"layout":{"canvas":{"position":{"left":5,"top":8},"zoom":0.5},"tables":{"public.users":{"position":{"left":1,"top":2},"color":"red","selected":true,"columns":["id","name"]}},"hiddenTables":{"public.creds":{"position":{"left":0,"top":0},"color":"blue","columns":["login","pass"]}}}"""
        ++ ""","layoutName":"users","""
        ++ """"layouts":{"""
        ++ """"empty":{"canvas":{"position":{"left":3,"top":6},"zoom":1}},"""
        ++ """"link":{"canvas":{"position":{"left":32,"top":13},"zoom":1.5},"tables":{"public.creds":{"position":{"left":0,"top":0},"color":"blue","columns":["user_id"]},"public.users":{"position":{"left":90,"top":102},"color":"red","selected":true,"columns":["id"]}}}}}"""


suite : Test
suite =
    describe "SchemaFormatTest"
        [ test "encode schema0" (\_ -> schema0 |> encodeSchema |> Encode.encode 0 |> Expect.equal schema0Json)
        , test "decode schema0" (\_ -> schema0Json |> Decode.decodeString (decodeSchema []) |> Expect.equal (Ok schema0))
        , test "encode schema1" (\_ -> schema1 |> encodeSchema |> Encode.encode 0 |> Expect.equal schema1Json)
        , test "decode schema1" (\_ -> schema1Json |> Decode.decodeString (decodeSchema []) |> Expect.equal (Ok schema1))
        , test "encode schema2" (\_ -> schema2 |> encodeSchema |> Encode.encode 0 |> Expect.equal schema2Json)
        , test "decode schema2" (\_ -> schema2Json |> Decode.decodeString (decodeSchema []) |> Expect.equal (Ok schema2))

        -- , fuzz Fuzzers.schema "encode/decode any Schema" (expectRoundTrip encodeSchema (decodeSchema [])) -- TOO LONG & Maximum call stack size exceeded :(
        , fuzz Fuzzers.schemaInfo "encode/decode any SchemaInfo" (expectRoundTrip encodeSchemaInfo decodeSchemaInfo)
        , fuzz Fuzzers.fileInfo "encode/decode any FileInfo" (expectRoundTrip encodeFileInfo decodeFileInfo)

        -- , fuzz Fuzzers.table "encode/decode any Table" (expectRoundTrip encodeTable decodeTable) -- TOO LONG :(
        , fuzz Fuzzers.column "encode/decode any Column" (expectRoundTrip encodeColumn decodeColumn)
        , fuzz Fuzzers.primaryKey "encode/decode any PrimaryKey" (expectRoundTrip encodePrimaryKey decodePrimaryKey)
        , fuzz Fuzzers.foreignKey "encode/decode any ForeignKey" (expectRoundTrip encodeForeignKey decodeForeignKey)
        , fuzz Fuzzers.unique "encode/decode any Unique" (expectRoundTrip encodeUnique decodeUnique)
        , fuzz Fuzzers.index "encode/decode any Index" (expectRoundTrip encodeIndex decodeIndex)
        , fuzz Fuzzers.source "encode/decode any Source" (expectRoundTrip encodeSource decodeSource)
        , fuzz Fuzzers.sourceLine "encode/decode any SourceLine" (expectRoundTrip encodeSourceLine decodeSourceLine)

        -- , fuzz Fuzzers.layout "encode/decode any Layout" (expectRoundTrip encodeLayout decodeLayout) -- TOO LONG & Dict order matter :(
        , fuzz Fuzzers.canvasProps "encode/decode any CanvasProps" (expectRoundTrip encodeCanvasProps decodeCanvasProps)
        , fuzz Fuzzers.tableProps "encode/decode any TableProps" (expectRoundTrip encodeTableProps decodeTableProps)
        , fuzz Fuzzers.position "encode/decode any Position" (expectRoundTrip encodePosition decodePosition)
        , fuzz Fuzzers.size "encode/decode any Size" (expectRoundTrip encodeSize decodeSize)
        , fuzz Fuzzers.tableId "encode/decode any TableId" (expectRoundTrip encodeTableId decodeTableId)
        , fuzz Fuzzers.schemaName "encode/decode any SchemaName" (expectRoundTrip encodeSchemaName decodeSchemaName)
        , fuzz Fuzzers.tableName "encode/decode any TableName" (expectRoundTrip encodeTableName decodeTableName)
        , fuzz Fuzzers.columnName "encode/decode any ColumnName" (expectRoundTrip encodeColumnName decodeColumnName)
        , fuzz Fuzzers.columnIndex "encode/decode any ColumnIndex" (expectRoundTrip encodeColumnIndex decodeColumnIndex)
        , fuzz Fuzzers.columnType "encode/decode any ColumnType" (expectRoundTrip encodeColumnType decodeColumnType)
        , fuzz Fuzzers.columnValue "encode/decode any ColumnValue" (expectRoundTrip encodeColumnValue decodeColumnValue)
        , fuzz Fuzzers.primaryKeyName "encode/decode any PrimaryKeyName" (expectRoundTrip encodePrimaryKeyName decodePrimaryKeyName)
        , fuzz Fuzzers.foreignKeyName "encode/decode any ForeignKeyName" (expectRoundTrip encodeForeignKeyName decodeForeignKeyName)
        , fuzz Fuzzers.uniqueName "encode/decode any UniqueName" (expectRoundTrip encodeUniqueName decodeUniqueName)
        , fuzz Fuzzers.indexName "encode/decode any IndexName" (expectRoundTrip encodeIndexName decodeIndexName)
        , fuzz Fuzzers.tableComment "encode/decode any TableComment" (expectRoundTrip encodeTableComment decodeTableComment)
        , fuzz Fuzzers.columnComment "encode/decode any ColumnComment" (expectRoundTrip encodeColumnComment decodeColumnComment)
        , fuzz Fuzzers.zoomLevel "encode/decode any ZoomLevel" (expectRoundTrip encodeZoomLevel decodeZoomLevel)
        , fuzz Fuzzers.color "encode/decode any Color" (expectRoundTrip encodeColor decodeColor)
        , fuzz Fuzzers.posix "encode/decode any Posix" (expectRoundTrip encodePosix decodePosix)
        ]


expectRoundTrip : (a -> Encode.Value) -> Decode.Decoder a -> a -> Expectation
expectRoundTrip encode decoder a =
    a |> encode |> Encode.encode 0 |> Decode.decodeString decoder |> Expect.equal (Ok a)
