module JsonFormats.SchemaFormat exposing (decodeCanvasProps, decodeColumn, decodeColumnName, decodeColumnProps, decodeColumnState, decodeForeignKey, decodeIndex, decodeLayout, decodePosition, decodePrimaryKey, decodeSchema, decodeSize, decodeTable, decodeTableProps, decodeTableState, decodeTableStatus, decodeUnique, encodeCanvasProps, encodeColumn, encodeColumnName, encodeColumnProps, encodeColumnState, encodeForeignKey, encodeIndex, encodeLayout, encodePosition, encodePrimaryKey, encodeSchema, encodeSize, encodeTable, encodeTableProps, encodeTableState, encodeTableStatus, encodeUnique)

import AssocList as Dict exposing (Dict)
import Dict as ElmDict
import Json.Decode as Decode
import Json.Encode as Encode
import Libs.Std exposing (dictFromList)
import Mappers.SchemaMapper exposing (buildSchema)
import Models.Schema exposing (CanvasProps, Column, ColumnComment(..), ColumnIndex(..), ColumnName(..), ColumnProps, ColumnState, ColumnType(..), ForeignKey, ForeignKeyName(..), Index, IndexName(..), Layout, PrimaryKey, PrimaryKeyName(..), Schema, SchemaName(..), Table, TableComment(..), TableId(..), TableName(..), TableProps, TableState, TableStatus(..), Unique, UniqueName(..))
import Models.Utils exposing (Position, Size)
import Views.Helpers exposing (formatTableId, parseTableId)


encodeSchema : Schema -> Encode.Value
encodeSchema value =
    Encode.object
        [ ( "name", value.name |> Encode.string )
        , ( "layouts", value.layouts |> Encode.list encodeLayout )
        , ( "tables", value.tables |> Dict.values |> Encode.list encodeTable )
        ]


decodeSchema : Decode.Decoder Schema
decodeSchema =
    Decode.map3 buildSchema
        (Decode.field "name" Decode.string)
        (Decode.field "layouts" (Decode.list decodeLayout))
        (Decode.field "tables" (Decode.list decodeTable))


encodeTable : Table -> Encode.Value
encodeTable value =
    Encode.object
        [ ( "schema", value.schema |> (\(SchemaName v) -> v) |> Encode.string )
        , ( "table", value.table |> (\(TableName v) -> v) |> Encode.string )
        , ( "columns", value.columns |> Dict.values |> Encode.list encodeColumn )
        , ( "primaryKey", value.primaryKey |> encodeMaybe encodePrimaryKey )
        , ( "uniques", value.uniques |> Encode.list encodeUnique )
        , ( "indexes", value.indexes |> Encode.list encodeIndex )
        , ( "comment", value.comment |> encodeMaybe (\(TableComment v) -> Encode.string v) )
        , ( "state", value.state |> encodeTableState )
        ]


decodeTable : Decode.Decoder Table
decodeTable =
    decodeMap9 Table
        (Decode.map2 (\schema table -> TableId (SchemaName schema) (TableName table)) (Decode.field "schema" Decode.string) (Decode.field "table" Decode.string))
        (Decode.field "schema" Decode.string |> Decode.map SchemaName)
        (Decode.field "table" Decode.string |> Decode.map TableName)
        (Decode.field "columns" (Decode.list decodeColumn |> Decode.map (dictFromList .column)))
        (Decode.field "primaryKey" (Decode.maybe decodePrimaryKey))
        (Decode.field "uniques" (Decode.list decodeUnique))
        (Decode.field "indexes" (Decode.list decodeIndex))
        (Decode.field "comment" (Decode.maybe (Decode.string |> Decode.map TableComment)))
        (Decode.field "state" decodeTableState)


encodeTableState : TableState -> Encode.Value
encodeTableState value =
    Encode.object
        [ ( "status", value.status |> encodeTableStatus )
        , ( "size", value.size |> encodeSize )
        , ( "position", value.position |> encodePosition )
        , ( "color", value.color |> Encode.string )
        , ( "selected", value.selected |> Encode.bool )
        ]


decodeTableState : Decode.Decoder TableState
decodeTableState =
    Decode.map5 TableState
        (Decode.field "status" decodeTableStatus)
        (Decode.field "size" decodeSize)
        (Decode.field "position" decodePosition)
        (Decode.field "color" Decode.string)
        (Decode.field "selected" Decode.bool)


encodeTableStatus : TableStatus -> Encode.Value
encodeTableStatus value =
    Encode.string
        (case value of
            Uninitialized ->
                "Uninitialized"

            Initializing ->
                "Initializing"

            Hidden ->
                "Hidden"

            Shown ->
                "Shown"
        )


decodeTableStatus : Decode.Decoder TableStatus
decodeTableStatus =
    Decode.string
        |> Decode.andThen
            (\value ->
                case value of
                    "Uninitialized" ->
                        Decode.succeed Uninitialized

                    "Initializing" ->
                        Decode.succeed Initializing

                    "Hidden" ->
                        Decode.succeed Hidden

                    "Shown" ->
                        Decode.succeed Shown

                    other ->
                        Decode.fail ("invalid TableStatus '" ++ other ++ "'")
            )


encodeColumn : Column -> Encode.Value
encodeColumn value =
    Encode.object
        [ ( "index", value.index |> (\(ColumnIndex v) -> v) |> Encode.int )
        , ( "column", value.column |> encodeColumnName )
        , ( "kind", value.kind |> (\(ColumnType v) -> v) |> Encode.string )
        , ( "nullable", value.nullable |> Encode.bool )
        , ( "foreignKey", value.foreignKey |> encodeMaybe encodeForeignKey )
        , ( "comment", value.comment |> encodeMaybe (\(ColumnComment v) -> Encode.string v) )
        , ( "state", value.state |> encodeColumnState )
        ]


decodeColumn : Decode.Decoder Column
decodeColumn =
    Decode.map7 Column
        (Decode.field "index" Decode.int |> Decode.map ColumnIndex)
        (Decode.field "column" decodeColumnName)
        (Decode.field "kind" Decode.string |> Decode.map ColumnType)
        (Decode.field "nullable" Decode.bool)
        (Decode.field "foreignKey" (Decode.maybe decodeForeignKey))
        (Decode.field "comment" (Decode.maybe (Decode.string |> Decode.map ColumnComment)))
        (Decode.field "state" decodeColumnState)


encodeColumnState : ColumnState -> Encode.Value
encodeColumnState value =
    Encode.object
        [ ( "order", value.order |> encodeMaybe Encode.int )
        ]


decodeColumnState : Decode.Decoder ColumnState
decodeColumnState =
    Decode.map ColumnState
        (Decode.field "order" (Decode.maybe Decode.int))


encodePrimaryKey : PrimaryKey -> Encode.Value
encodePrimaryKey value =
    Encode.object
        [ ( "columns", value.columns |> Encode.list encodeColumnName )
        , ( "name", value.name |> (\(PrimaryKeyName v) -> v) |> Encode.string )
        ]


decodePrimaryKey : Decode.Decoder PrimaryKey
decodePrimaryKey =
    Decode.map2 PrimaryKey
        (Decode.field "columns" (Decode.list decodeColumnName))
        (Decode.field "name" Decode.string |> Decode.map PrimaryKeyName)


encodeUnique : Unique -> Encode.Value
encodeUnique value =
    Encode.object
        [ ( "columns", value.columns |> Encode.list encodeColumnName )
        , ( "name", value.name |> (\(UniqueName v) -> v) |> Encode.string )
        ]


decodeUnique : Decode.Decoder Unique
decodeUnique =
    Decode.map2 Unique
        (Decode.field "columns" (Decode.list decodeColumnName))
        (Decode.field "name" Decode.string |> Decode.map UniqueName)


encodeIndex : Index -> Encode.Value
encodeIndex value =
    Encode.object
        [ ( "columns", value.columns |> Encode.list encodeColumnName )
        , ( "definition", value.definition |> Encode.string )
        , ( "name", value.name |> (\(IndexName v) -> v) |> Encode.string )
        ]


decodeIndex : Decode.Decoder Index
decodeIndex =
    Decode.map3 Index
        (Decode.field "columns" (Decode.list decodeColumnName))
        (Decode.field "definition" Decode.string)
        (Decode.field "name" Decode.string |> Decode.map IndexName)


encodeForeignKey : ForeignKey -> Encode.Value
encodeForeignKey value =
    Encode.object
        [ ( "schema", value.schema |> (\(SchemaName v) -> v) |> Encode.string )
        , ( "table", value.table |> (\(TableName v) -> v) |> Encode.string )
        , ( "column", value.column |> encodeColumnName )
        , ( "name", value.name |> (\(ForeignKeyName v) -> v) |> Encode.string )
        ]


decodeForeignKey : Decode.Decoder ForeignKey
decodeForeignKey =
    Decode.map5 ForeignKey
        (Decode.map2 (\schema table -> TableId (SchemaName schema) (TableName table)) (Decode.field "schema" Decode.string) (Decode.field "table" Decode.string))
        (Decode.field "schema" Decode.string |> Decode.map SchemaName)
        (Decode.field "table" Decode.string |> Decode.map TableName)
        (Decode.field "column" decodeColumnName)
        (Decode.field "name" Decode.string |> Decode.map ForeignKeyName)


encodeColumnName : ColumnName -> Encode.Value
encodeColumnName (ColumnName value) =
    Encode.string value


decodeColumnName : Decode.Decoder ColumnName
decodeColumnName =
    Decode.string |> Decode.map ColumnName


encodeLayout : Layout -> Encode.Value
encodeLayout value =
    Encode.object
        [ ( "name", value.name |> Encode.string )
        , ( "canvas", value.canvas |> encodeCanvasProps )
        , ( "tables", value.tables |> encodeDict formatTableId encodeTableProps )
        ]


decodeLayout : Decode.Decoder Layout
decodeLayout =
    Decode.map3 Layout
        (Decode.field "name" Decode.string)
        (Decode.field "canvas" decodeCanvasProps)
        (Decode.field "tables" (decodeDict parseTableId decodeTableProps))


encodeCanvasProps : CanvasProps -> Encode.Value
encodeCanvasProps value =
    Encode.object
        [ ( "zoom", value.zoom |> Encode.float )
        , ( "position", value.position |> encodePosition )
        ]


decodeCanvasProps : Decode.Decoder CanvasProps
decodeCanvasProps =
    Decode.map2 CanvasProps
        (Decode.field "zoom" Decode.float)
        (Decode.field "position" decodePosition)


encodeTableProps : TableProps -> Encode.Value
encodeTableProps value =
    Encode.object
        [ ( "position", value.position |> encodePosition )
        , ( "color", value.color |> Encode.string )
        , ( "columns", value.columns |> encodeDict (\(ColumnName v) -> v) encodeColumnProps )
        ]


decodeTableProps : Decode.Decoder TableProps
decodeTableProps =
    Decode.map3 TableProps
        (Decode.field "position" decodePosition)
        (Decode.field "color" Decode.string)
        (Decode.field "columns" (decodeDict ColumnName decodeColumnProps))


encodeColumnProps : ColumnProps -> Encode.Value
encodeColumnProps value =
    Encode.object
        [ ( "position", value.position |> Encode.int )
        ]


decodeColumnProps : Decode.Decoder ColumnProps
decodeColumnProps =
    Decode.map ColumnProps
        (Decode.field "position" Decode.int)


encodePosition : Position -> Encode.Value
encodePosition value =
    Encode.object
        [ ( "left", value.left |> Encode.float )
        , ( "top", value.top |> Encode.float )
        ]


decodePosition : Decode.Decoder Position
decodePosition =
    Decode.map2 Position
        (Decode.field "left" Decode.float)
        (Decode.field "top" Decode.float)


encodeSize : Size -> Encode.Value
encodeSize value =
    Encode.object
        [ ( "width", value.width |> Encode.float )
        , ( "height", value.height |> Encode.float )
        ]


decodeSize : Decode.Decoder Size
decodeSize =
    Decode.map2 Size
        (Decode.field "width" Decode.float)
        (Decode.field "height" Decode.float)


encodeDict : (k -> String) -> (a -> Encode.Value) -> Dict k a -> Encode.Value
encodeDict encodeKey encodeValue dict =
    Encode.dict identity identity (dict |> Dict.toList |> List.map (\( k, a ) -> ( encodeKey k, encodeValue a )) |> ElmDict.fromList)


decodeDict : (String -> k) -> Decode.Decoder a -> Decode.Decoder (Dict k a)
decodeDict buildKey decoder =
    Decode.dict decoder |> Decode.map (\dict -> dict |> ElmDict.toList |> List.map (\( k, a ) -> ( buildKey k, a )) |> Dict.fromList)


encodeMaybe : (a -> Encode.Value) -> Maybe a -> Encode.Value
encodeMaybe encoder maybe =
    maybe |> Maybe.map encoder |> Maybe.withDefault Encode.null


decodeMap9 : (a -> b -> c -> d -> e -> f -> g -> h -> i -> value) -> Decode.Decoder a -> Decode.Decoder b -> Decode.Decoder c -> Decode.Decoder d -> Decode.Decoder e -> Decode.Decoder f -> Decode.Decoder g -> Decode.Decoder h -> Decode.Decoder i -> Decode.Decoder value
decodeMap9 callback da db dc dd de df dg dh di =
    Decode.map2 (\( ( a, b, c ), ( d, e, f ) ) ( g, h, i ) -> callback a b c d e f g h i)
        (Decode.map6 (\a b c d e f -> ( ( a, b, c ), ( d, e, f ) )) da db dc dd de df)
        (Decode.map3 (\g h i -> ( g, h, i )) dg dh di)
