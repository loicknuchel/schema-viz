module JsonFormats.SchemaFormat exposing (decodeCanvasProps, decodeColumn, decodeColumnName, decodeColumnProps, decodeColumnState, decodeForeignKey, decodeIndex, decodeInfo, decodeLayout, decodePosition, decodePrimaryKey, decodeSchema, decodeSize, decodeTable, decodeTableProps, decodeTableState, decodeTableStatus, decodeUnique, encodeCanvasProps, encodeColumn, encodeColumnName, encodeColumnProps, encodeColumnState, encodeForeignKey, encodeIndex, encodeInfo, encodeLayout, encodePosition, encodePrimaryKey, encodeSchema, encodeSize, encodeTable, encodeTableProps, encodeTableState, encodeTableStatus, encodeUnique)

import AssocList as Dict exposing (Dict)
import Dict as ElmDict
import Json.Decode as Decode
import Json.Encode as Encode
import Libs.Std exposing (dictFromList, maybeFilter)
import Mappers.SchemaMapper exposing (buildSchema, initTableState)
import Models.Schema exposing (CanvasProps, Column, ColumnComment(..), ColumnIndex(..), ColumnName(..), ColumnProps, ColumnState, ColumnType(..), ColumnValue(..), ForeignKey, ForeignKeyName(..), Index, IndexName(..), Layout, PrimaryKey, PrimaryKeyName(..), Schema, SchemaInfo, SchemaName(..), Table, TableComment(..), TableId(..), TableName(..), TableProps, TableState, TableStatus(..), Unique, UniqueName(..), formatTableId, parseTableId)
import Models.Utils exposing (Position, Size)
import Time


encodeSchema : Schema -> Encode.Value
encodeSchema value =
    encodeObject
        [ ( "name", value.name |> Encode.string )
        , ( "info", value.info |> encodeInfo )
        , ( "tables", value.tables |> Dict.values |> Encode.list encodeTable )
        , ( "layouts", value.layouts |> Encode.list encodeLayout )
        ]


decodeSchema : List String -> Decode.Decoder Schema
decodeSchema takenNames =
    Decode.map4 (buildSchema takenNames)
        (Decode.field "name" Decode.string)
        (Decode.field "info" decodeInfo)
        (Decode.field "tables" (Decode.list decodeTable))
        (Decode.field "layouts" (Decode.list decodeLayout))


encodeInfo : SchemaInfo -> Encode.Value
encodeInfo value =
    encodeObject
        [ ( "created", value.created |> Time.posixToMillis |> Encode.int )
        , ( "updated", value.updated |> Time.posixToMillis |> Encode.int )
        , ( "fileLastModified", value.fileLastModified |> Maybe.map Time.posixToMillis |> encodeMaybe Encode.int )
        ]


decodeInfo : Decode.Decoder SchemaInfo
decodeInfo =
    Decode.map3 SchemaInfo
        (Decode.field "created" Decode.int |> Decode.map Time.millisToPosix)
        (Decode.field "updated" Decode.int |> Decode.map Time.millisToPosix)
        (Decode.maybe (Decode.field "fileLastModified" Decode.int |> Decode.map Time.millisToPosix))


encodeTable : Table -> Encode.Value
encodeTable value =
    encodeObject
        [ ( "schema", value.schema |> (\(SchemaName v) -> v) |> Encode.string )
        , ( "table", value.table |> (\(TableName v) -> v) |> Encode.string )
        , ( "columns", value.columns |> Dict.values |> Encode.list encodeColumn )
        , ( "primaryKey", value.primaryKey |> encodeMaybe encodePrimaryKey )
        , ( "uniques", value.uniques |> Encode.list encodeUnique )
        , ( "indexes", value.indexes |> Encode.list encodeIndex )
        , ( "comment", value.comment |> encodeMaybe (\(TableComment v) -> Encode.string v) )
        , ( "state", value.state |> encodeMaybeWithoutDefault encodeTableState (initTableState value.id) )
        ]


decodeTable : Decode.Decoder Table
decodeTable =
    Decode.map2 (\schema table -> ( TableId schema table, schema, table ))
        (Decode.field "schema" Decode.string |> Decode.map SchemaName)
        (Decode.field "table" Decode.string |> Decode.map TableName)
        |> Decode.andThen
            (\( tableId, schema, table ) ->
                decodeMap9 Table
                    (Decode.succeed tableId)
                    (Decode.succeed schema)
                    (Decode.succeed table)
                    (Decode.field "columns" (Decode.list decodeColumn |> Decode.map (dictFromList .column)))
                    (Decode.maybe (Decode.field "primaryKey" decodePrimaryKey))
                    (Decode.field "uniques" (Decode.list decodeUnique))
                    (Decode.field "indexes" (Decode.list decodeIndex))
                    (Decode.maybe (Decode.field "comment" (Decode.string |> Decode.map TableComment)))
                    (decodeMaybeWithDefault (\state -> Decode.field "state" (decodeTableState state)) (initTableState tableId))
            )


encodeTableState : TableState -> TableState -> Encode.Value
encodeTableState default value =
    encodeObject
        [ ( "status", value.status |> encodeMaybeWithoutDefault (\_ -> encodeTableStatus) default.status )
        , ( "size", value.size |> encodeMaybeWithoutDefault (\_ -> encodeSize) default.size )
        , ( "position", value.position |> encodeMaybeWithoutDefault (\_ -> encodePosition) default.position )
        , ( "color", value.color |> encodeMaybeWithoutDefault (\_ -> Encode.string) default.color )
        , ( "selected", value.selected |> encodeMaybeWithoutDefault (\_ -> Encode.bool) default.selected )
        ]


decodeTableState : TableState -> Decode.Decoder TableState
decodeTableState default =
    Decode.map5 TableState
        (decodeMaybeWithDefault (\_ -> Decode.field "status" decodeTableStatus) default.status)
        (decodeMaybeWithDefault (\_ -> Decode.field "size" decodeSize) default.size)
        (decodeMaybeWithDefault (\_ -> Decode.field "position" decodePosition) default.position)
        (decodeMaybeWithDefault (\_ -> Decode.field "color" Decode.string) default.color)
        (decodeMaybeWithDefault (\_ -> Decode.field "selected" Decode.bool) default.selected)


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
    encodeObject
        [ ( "index", value.index |> (\(ColumnIndex v) -> v) |> Encode.int )
        , ( "column", value.column |> encodeColumnName )
        , ( "type", value.kind |> (\(ColumnType v) -> v) |> Encode.string )
        , ( "nullable", value.nullable |> Encode.bool )
        , ( "default", value.default |> encodeMaybe (\(ColumnValue v) -> Encode.string v) )
        , ( "foreignKey", value.foreignKey |> encodeMaybe encodeForeignKey )
        , ( "comment", value.comment |> encodeMaybe (\(ColumnComment v) -> Encode.string v) )
        , ( "state", value.state |> encodeColumnState )
        ]


decodeColumn : Decode.Decoder Column
decodeColumn =
    Decode.map8 Column
        (Decode.field "index" Decode.int |> Decode.map ColumnIndex)
        (Decode.field "column" decodeColumnName)
        (Decode.field "type" Decode.string |> Decode.map ColumnType)
        (Decode.field "nullable" Decode.bool)
        (Decode.maybe (Decode.field "default" (Decode.string |> Decode.map ColumnValue)))
        (Decode.maybe (Decode.field "foreignKey" decodeForeignKey))
        (Decode.maybe (Decode.field "comment" (Decode.string |> Decode.map ColumnComment)))
        (Decode.field "state" decodeColumnState)


encodeColumnState : ColumnState -> Encode.Value
encodeColumnState value =
    encodeObject
        [ ( "order", value.order |> encodeMaybe Encode.int )
        ]


decodeColumnState : Decode.Decoder ColumnState
decodeColumnState =
    Decode.map ColumnState
        (Decode.field "order" (Decode.maybe Decode.int))


encodePrimaryKey : PrimaryKey -> Encode.Value
encodePrimaryKey value =
    encodeObject
        [ ( "columns", value.columns |> Encode.list encodeColumnName )
        , ( "name", value.name |> (\(PrimaryKeyName v) -> v) |> Encode.string )
        ]


decodePrimaryKey : Decode.Decoder PrimaryKey
decodePrimaryKey =
    Decode.map2 PrimaryKey
        (Decode.field "columns" (Decode.list decodeColumnName))
        (Decode.field "name" Decode.string |> Decode.map PrimaryKeyName)


encodeIndex : Index -> Encode.Value
encodeIndex value =
    encodeObject
        [ ( "name", value.name |> (\(IndexName v) -> v) |> Encode.string )
        , ( "columns", value.columns |> Encode.list encodeColumnName )
        , ( "definition", value.definition |> Encode.string )
        ]


decodeIndex : Decode.Decoder Index
decodeIndex =
    Decode.map3 Index
        (Decode.field "name" Decode.string |> Decode.map IndexName)
        (Decode.field "columns" (Decode.list decodeColumnName))
        (Decode.field "definition" Decode.string)


encodeUnique : Unique -> Encode.Value
encodeUnique value =
    encodeObject
        [ ( "name", value.name |> (\(UniqueName v) -> v) |> Encode.string )
        , ( "columns", value.columns |> Encode.list encodeColumnName )
        , ( "definition", value.definition |> Encode.string )
        ]


decodeUnique : Decode.Decoder Unique
decodeUnique =
    Decode.map3 Unique
        (Decode.field "name" Decode.string |> Decode.map UniqueName)
        (Decode.field "columns" (Decode.list decodeColumnName))
        (Decode.field "definition" Decode.string)


encodeForeignKey : ForeignKey -> Encode.Value
encodeForeignKey value =
    encodeObject
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
    encodeObject
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
    encodeObject
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
    encodeObject
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
    encodeObject
        [ ( "position", value.position |> Encode.int )
        ]


decodeColumnProps : Decode.Decoder ColumnProps
decodeColumnProps =
    Decode.map ColumnProps
        (Decode.field "position" Decode.int)


encodePosition : Position -> Encode.Value
encodePosition value =
    encodeObject
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
    encodeObject
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


encodeMaybeWithoutDefault : (a -> a -> Encode.Value) -> a -> a -> Encode.Value
encodeMaybeWithoutDefault encode default value =
    Just value |> maybeFilter (\v -> not (v == default)) |> encodeMaybe (encode default)


decodeMaybeWithDefault : (a -> Decode.Decoder a) -> a -> Decode.Decoder a
decodeMaybeWithDefault decoder a =
    Decode.maybe (decoder a) |> Decode.map (Maybe.withDefault a)


encodeObject : List ( String, Encode.Value ) -> Encode.Value
encodeObject attrs =
    Encode.object (attrs |> List.filter (\( _, value ) -> not (value == Encode.null)))


decodeMap9 : (a -> b -> c -> d -> e -> f -> g -> h -> i -> value) -> Decode.Decoder a -> Decode.Decoder b -> Decode.Decoder c -> Decode.Decoder d -> Decode.Decoder e -> Decode.Decoder f -> Decode.Decoder g -> Decode.Decoder h -> Decode.Decoder i -> Decode.Decoder value
decodeMap9 callback da db dc dd de df dg dh di =
    Decode.map2 (\( ( a, b, c ), ( d, e, f ) ) ( g, h, i ) -> callback a b c d e f g h i)
        (Decode.map6 (\a b c d e f -> ( ( a, b, c ), ( d, e, f ) )) da db dc dd de df)
        (Decode.map3 (\g h i -> ( g, h, i )) dg dh di)
