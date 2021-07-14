module JsonFormats.SchemaFormat exposing (decodeCanvasProps, decodeColumn, decodeColumnName, decodeForeignKey, decodeIndex, decodeInfo, decodeLayout, decodePosition, decodePrimaryKey, decodeSchema, decodeSize, decodeTable, decodeTableProps, decodeUnique, encodeCanvasProps, encodeColumn, encodeColumnName, encodeForeignKey, encodeIndex, encodeInfo, encodeLayout, encodePosition, encodePrimaryKey, encodeSchema, encodeSize, encodeTable, encodeTableProps, encodeUnique)

import AssocList as Dict
import Json.Decode as Decode
import Json.Encode as Encode exposing (Value)
import Libs.Dict as D
import Libs.Json.Decode as D
import Libs.Json.Encode as E
import Libs.Maybe as M
import Models.Schema exposing (CanvasProps, Column, ColumnComment(..), ColumnIndex(..), ColumnName(..), ColumnType(..), ColumnValue(..), FileInfo, ForeignKey, ForeignKeyName(..), Index, IndexName(..), Layout, PrimaryKey, PrimaryKeyName(..), Schema, SchemaInfo, SchemaName(..), Source, SourceLine, Table, TableComment(..), TableId(..), TableName(..), TableProps, Unique, UniqueName(..), buildSchema, initLayout, stringAsTableId, tableIdAsString)
import Models.Utils exposing (Position, Size)
import Time



-- deps = { to = { only = [ "Libs.*", "Models.*" ] } }


encodeSchema : Schema -> Value
encodeSchema value =
    E.object
        [ ( "id", value.id |> Encode.string )
        , ( "info", value.info |> encodeInfo )
        , ( "tables", value.tables |> Dict.values |> Encode.list encodeTable )
        , ( "layout", value.layout |> encodeMaybeWithoutDefault (\_ -> encodeLayout) initLayout )
        , ( "layoutName", value.layoutName |> encodeMaybe Encode.string )
        , ( "layouts", value.layouts |> encodeMaybeWithoutDefault (\_ -> E.dict identity encodeLayout) Dict.empty )
        ]


decodeSchema : List String -> Decode.Decoder Schema
decodeSchema takenNames =
    Decode.map6 (buildSchema takenNames)
        (Decode.field "id" Decode.string)
        (Decode.field "info" decodeInfo)
        (Decode.field "tables" (Decode.list decodeTable))
        (decodeMaybeWithDefault (\_ -> Decode.field "layout" decodeLayout) initLayout)
        (Decode.maybe (Decode.field "layoutName" Decode.string))
        (decodeMaybeWithDefault (\_ -> Decode.field "layouts" (D.dict identity decodeLayout)) Dict.empty)


encodeInfo : SchemaInfo -> Value
encodeInfo value =
    E.object
        [ ( "created", value.created |> Time.posixToMillis |> Encode.int )
        , ( "updated", value.updated |> Time.posixToMillis |> Encode.int )
        , ( "file", value.file |> encodeMaybe encodeFileInfo )
        ]


decodeInfo : Decode.Decoder SchemaInfo
decodeInfo =
    Decode.map3 SchemaInfo
        (Decode.field "created" Decode.int |> Decode.map Time.millisToPosix)
        (Decode.field "updated" Decode.int |> Decode.map Time.millisToPosix)
        (Decode.maybe (Decode.field "file" decodeFileInfo))


encodeFileInfo : FileInfo -> Value
encodeFileInfo value =
    E.object
        [ ( "name", value.name |> Encode.string )
        , ( "lastModified", value.lastModified |> Time.posixToMillis |> Encode.int )
        ]


decodeFileInfo : Decode.Decoder FileInfo
decodeFileInfo =
    Decode.map2 FileInfo
        (Decode.field "name" Decode.string)
        (Decode.field "lastModified" Decode.int |> Decode.map Time.millisToPosix)


encodeTable : Table -> Value
encodeTable value =
    E.object
        [ ( "schema", value.schema |> (\(SchemaName v) -> v) |> Encode.string )
        , ( "table", value.table |> (\(TableName v) -> v) |> Encode.string )
        , ( "columns", value.columns |> Dict.values |> Encode.list encodeColumn )
        , ( "primaryKey", value.primaryKey |> encodeMaybe encodePrimaryKey )
        , ( "uniques", value.uniques |> Encode.list encodeUnique )
        , ( "indexes", value.indexes |> Encode.list encodeIndex )
        , ( "comment", value.comment |> encodeMaybe (\(TableComment v) -> Encode.string v) )
        , ( "sources", value.sources |> encodeMaybeWithoutDefault (\_ -> Encode.list encodeSource) [] )
        ]


decodeTable : Decode.Decoder Table
decodeTable =
    Decode.map2 (\schema table -> ( TableId schema table, schema, table ))
        (Decode.field "schema" Decode.string |> Decode.map SchemaName)
        (Decode.field "table" Decode.string |> Decode.map TableName)
        |> Decode.andThen
            (\( tableId, schema, table ) ->
                D.map9 Table
                    (Decode.succeed tableId)
                    (Decode.succeed schema)
                    (Decode.succeed table)
                    (Decode.field "columns" (Decode.list decodeColumn |> Decode.map (D.fromList .column)))
                    (Decode.maybe (Decode.field "primaryKey" decodePrimaryKey))
                    (Decode.field "uniques" (Decode.list decodeUnique))
                    (Decode.field "indexes" (Decode.list decodeIndex))
                    (Decode.maybe (Decode.field "comment" (Decode.string |> Decode.map TableComment)))
                    (decodeMaybeWithDefault (\_ -> Decode.field "sources" (Decode.list decodeSource)) [])
            )


encodeSource : Source -> Value
encodeSource value =
    E.object
        [ ( "file", value.file |> Encode.string )
        , ( "lines", value.lines |> E.nel encodeSourceLine )
        ]


decodeSource : Decode.Decoder Source
decodeSource =
    Decode.map2 Source
        (Decode.field "file" Decode.string)
        (Decode.field "lines" (D.nel decodeSourceLine))


encodeSourceLine : SourceLine -> Value
encodeSourceLine value =
    E.object
        [ ( "no", value.no |> Encode.int )
        , ( "text", value.text |> Encode.string )
        ]


decodeSourceLine : Decode.Decoder SourceLine
decodeSourceLine =
    Decode.map2 SourceLine
        (Decode.field "no" Decode.int)
        (Decode.field "text" Decode.string)


encodeColumn : Column -> Value
encodeColumn value =
    E.object
        [ ( "index", value.index |> (\(ColumnIndex v) -> v) |> Encode.int )
        , ( "column", value.column |> encodeColumnName )
        , ( "type", value.kind |> (\(ColumnType v) -> v) |> Encode.string )
        , ( "nullable", value.nullable |> Encode.bool )
        , ( "default", value.default |> encodeMaybe (\(ColumnValue v) -> Encode.string v) )
        , ( "foreignKey", value.foreignKey |> encodeMaybe encodeForeignKey )
        , ( "comment", value.comment |> encodeMaybe (\(ColumnComment v) -> Encode.string v) )
        ]


decodeColumn : Decode.Decoder Column
decodeColumn =
    Decode.map7 Column
        (Decode.field "index" Decode.int |> Decode.map ColumnIndex)
        (Decode.field "column" decodeColumnName)
        (Decode.field "type" Decode.string |> Decode.map ColumnType)
        (Decode.field "nullable" Decode.bool)
        (Decode.maybe (Decode.field "default" (Decode.string |> Decode.map ColumnValue)))
        (Decode.maybe (Decode.field "foreignKey" decodeForeignKey))
        (Decode.maybe (Decode.field "comment" (Decode.string |> Decode.map ColumnComment)))


encodePrimaryKey : PrimaryKey -> Value
encodePrimaryKey value =
    E.object
        [ ( "columns", value.columns |> Encode.list encodeColumnName )
        , ( "name", value.name |> (\(PrimaryKeyName v) -> v) |> Encode.string )
        ]


decodePrimaryKey : Decode.Decoder PrimaryKey
decodePrimaryKey =
    Decode.map2 PrimaryKey
        (Decode.field "columns" (Decode.list decodeColumnName))
        (Decode.field "name" Decode.string |> Decode.map PrimaryKeyName)


encodeIndex : Index -> Value
encodeIndex value =
    E.object
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


encodeUnique : Unique -> Value
encodeUnique value =
    E.object
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


encodeForeignKey : ForeignKey -> Value
encodeForeignKey value =
    E.object
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


encodeColumnName : ColumnName -> Value
encodeColumnName (ColumnName value) =
    Encode.string value


decodeColumnName : Decode.Decoder ColumnName
decodeColumnName =
    Decode.string |> Decode.map ColumnName


encodeLayout : Layout -> Value
encodeLayout value =
    E.object
        [ ( "canvas", value.canvas |> encodeCanvasProps )
        , ( "tables", value.tables |> E.dict tableIdAsString encodeTableProps )
        , ( "hiddenTables", value.hiddenTables |> E.dict tableIdAsString encodeTableProps )
        ]


decodeLayout : Decode.Decoder Layout
decodeLayout =
    Decode.map3 Layout
        (Decode.field "canvas" decodeCanvasProps)
        (Decode.field "tables" (D.dict stringAsTableId decodeTableProps))
        (Decode.field "hiddenTables" (D.dict stringAsTableId decodeTableProps))


encodeCanvasProps : CanvasProps -> Value
encodeCanvasProps value =
    E.object
        [ ( "position", value.position |> encodePosition )
        , ( "zoom", value.zoom |> Encode.float )
        ]


decodeCanvasProps : Decode.Decoder CanvasProps
decodeCanvasProps =
    Decode.map2 CanvasProps
        (Decode.field "position" decodePosition)
        (Decode.field "zoom" Decode.float)


encodeTableProps : TableProps -> Value
encodeTableProps value =
    E.object
        [ ( "position", value.position |> encodePosition )
        , ( "color", value.color |> Encode.string )
        , ( "selected", value.selected |> Encode.bool )
        , ( "columns", value.columns |> Encode.list encodeColumnName )
        ]


decodeTableProps : Decode.Decoder TableProps
decodeTableProps =
    Decode.map4 TableProps
        (Decode.field "position" decodePosition)
        (Decode.field "color" Decode.string)
        (Decode.field "selected" Decode.bool)
        (Decode.field "columns" (Decode.list decodeColumnName))


encodePosition : Position -> Value
encodePosition value =
    E.object
        [ ( "left", value.left |> Encode.float )
        , ( "top", value.top |> Encode.float )
        ]


decodePosition : Decode.Decoder Position
decodePosition =
    Decode.map2 Position
        (Decode.field "left" Decode.float)
        (Decode.field "top" Decode.float)


encodeSize : Size -> Value
encodeSize value =
    E.object
        [ ( "width", value.width |> Encode.float )
        , ( "height", value.height |> Encode.float )
        ]


decodeSize : Decode.Decoder Size
decodeSize =
    Decode.map2 Size
        (Decode.field "width" Decode.float)
        (Decode.field "height" Decode.float)


encodeMaybe : (a -> Value) -> Maybe a -> Value
encodeMaybe encoder maybe =
    maybe |> Maybe.map encoder |> Maybe.withDefault Encode.null


encodeMaybeWithoutDefault : (a -> a -> Value) -> a -> a -> Value
encodeMaybeWithoutDefault encode default value =
    Just value |> M.filter (\v -> not (v == default)) |> encodeMaybe (encode default)


decodeMaybeWithDefault : (a -> Decode.Decoder a) -> a -> Decode.Decoder a
decodeMaybeWithDefault decoder a =
    Decode.maybe (decoder a) |> Decode.map (Maybe.withDefault a)
