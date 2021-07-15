module JsonFormats.SchemaFormat exposing (decodeCanvasProps, decodeColor, decodeColumn, decodeColumnComment, decodeColumnIndex, decodeColumnName, decodeColumnType, decodeColumnValue, decodeFileInfo, decodeForeignKey, decodeForeignKeyName, decodeIndex, decodeIndexName, decodeLayout, decodePosition, decodePosix, decodePrimaryKey, decodePrimaryKeyName, decodeSchema, decodeSchemaInfo, decodeSchemaName, decodeSize, decodeSource, decodeSourceLine, decodeTable, decodeTableComment, decodeTableId, decodeTableName, decodeTableProps, decodeUnique, decodeUniqueName, decodeZoomLevel, encodeCanvasProps, encodeColor, encodeColumn, encodeColumnComment, encodeColumnIndex, encodeColumnName, encodeColumnType, encodeColumnValue, encodeFileInfo, encodeForeignKey, encodeForeignKeyName, encodeIndex, encodeIndexName, encodeLayout, encodePosition, encodePosix, encodePrimaryKey, encodePrimaryKeyName, encodeSchema, encodeSchemaInfo, encodeSchemaName, encodeSize, encodeSource, encodeSourceLine, encodeTable, encodeTableComment, encodeTableId, encodeTableName, encodeTableProps, encodeUnique, encodeUniqueName, encodeZoomLevel)

import AssocList as Dict
import Json.Decode as Decode
import Json.Encode as Encode exposing (Value)
import Libs.Dict as D
import Libs.Json.Decode as D
import Libs.Json.Encode as E
import Libs.Maybe as M
import Models.Schema exposing (CanvasProps, Column, ColumnComment(..), ColumnIndex(..), ColumnName(..), ColumnType(..), ColumnValue(..), FileInfo, ForeignKey, ForeignKeyName(..), Index, IndexName(..), Layout, PrimaryKey, PrimaryKeyName(..), Schema, SchemaInfo, SchemaName(..), Source, SourceLine, Table, TableComment(..), TableId(..), TableName(..), TableProps, Unique, UniqueName(..), buildSchema, initLayout, stringAsTableId, tableIdAsString)
import Models.Utils exposing (Color, Position, Size, ZoomLevel)
import Time



-- deps = { to = { only = [ "Libs.*", "Models.*" ] } }


encodeSchema : Schema -> Value
encodeSchema value =
    E.object
        [ ( "id", value.id |> Encode.string )
        , ( "info", value.info |> encodeSchemaInfo )
        , ( "tables", value.tables |> Dict.values |> Encode.list encodeTable )
        , ( "layout", value.layout |> encodeMaybeWithoutDefault (\_ -> encodeLayout) initLayout )
        , ( "layoutName", value.layoutName |> encodeMaybe Encode.string )
        , ( "layouts", value.layouts |> encodeMaybeWithoutDefault (\_ -> E.dict identity encodeLayout) Dict.empty )
        ]


decodeSchema : List String -> Decode.Decoder Schema
decodeSchema takenNames =
    Decode.map6 (buildSchema takenNames)
        (Decode.field "id" Decode.string)
        (Decode.field "info" decodeSchemaInfo)
        (Decode.field "tables" (Decode.list decodeTable))
        (decodeMaybeWithDefault (\_ -> Decode.field "layout" decodeLayout) initLayout)
        (Decode.maybe (Decode.field "layoutName" Decode.string))
        (decodeMaybeWithDefault (\_ -> Decode.field "layouts" (D.dict identity decodeLayout)) Dict.empty)


encodeSchemaInfo : SchemaInfo -> Value
encodeSchemaInfo value =
    E.object
        [ ( "created", value.created |> encodePosix )
        , ( "updated", value.updated |> encodePosix )
        , ( "file", value.file |> encodeMaybe encodeFileInfo )
        ]


decodeSchemaInfo : Decode.Decoder SchemaInfo
decodeSchemaInfo =
    Decode.map3 SchemaInfo
        (Decode.field "created" decodePosix)
        (Decode.field "updated" decodePosix)
        (Decode.maybe (Decode.field "file" decodeFileInfo))


encodeFileInfo : FileInfo -> Value
encodeFileInfo value =
    E.object
        [ ( "name", value.name |> Encode.string )
        , ( "lastModified", value.lastModified |> encodePosix )
        ]


decodeFileInfo : Decode.Decoder FileInfo
decodeFileInfo =
    Decode.map2 FileInfo
        (Decode.field "name" Decode.string)
        (Decode.field "lastModified" decodePosix)


encodeTable : Table -> Value
encodeTable value =
    E.object
        [ ( "schema", value.schema |> encodeSchemaName )
        , ( "table", value.table |> encodeTableName )
        , ( "columns", value.columns |> Dict.values |> Encode.list encodeColumn )
        , ( "primaryKey", value.primaryKey |> encodeMaybe encodePrimaryKey )
        , ( "uniques", value.uniques |> Encode.list encodeUnique )
        , ( "indexes", value.indexes |> Encode.list encodeIndex )
        , ( "comment", value.comment |> encodeMaybe encodeTableComment )
        , ( "sources", value.sources |> encodeMaybeWithoutDefault (\_ -> Encode.list encodeSource) [] )
        ]


decodeTable : Decode.Decoder Table
decodeTable =
    Decode.map8 (\schema table columns primaryKey uniques indexes comment sources -> Table (TableId schema table) schema table columns primaryKey uniques indexes comment sources)
        (Decode.field "schema" decodeSchemaName)
        (Decode.field "table" decodeTableName)
        (Decode.field "columns" (Decode.list decodeColumn |> Decode.map (D.fromList .column)))
        (Decode.maybe (Decode.field "primaryKey" decodePrimaryKey))
        (Decode.field "uniques" (Decode.list decodeUnique))
        (Decode.field "indexes" (Decode.list decodeIndex))
        (Decode.maybe (Decode.field "comment" decodeTableComment))
        (decodeMaybeWithDefault (\_ -> Decode.field "sources" (Decode.list decodeSource)) [])


encodeColumn : Column -> Value
encodeColumn value =
    E.object
        [ ( "index", value.index |> encodeColumnIndex )
        , ( "column", value.column |> encodeColumnName )
        , ( "type", value.kind |> encodeColumnType )
        , ( "nullable", value.nullable |> Encode.bool )
        , ( "default", value.default |> encodeMaybe encodeColumnValue )
        , ( "foreignKey", value.foreignKey |> encodeMaybe encodeForeignKey )
        , ( "comment", value.comment |> encodeMaybe encodeColumnComment )
        ]


decodeColumn : Decode.Decoder Column
decodeColumn =
    Decode.map7 Column
        (Decode.field "index" decodeColumnIndex)
        (Decode.field "column" decodeColumnName)
        (Decode.field "type" decodeColumnType)
        (Decode.field "nullable" Decode.bool)
        (Decode.maybe (Decode.field "default" decodeColumnValue))
        (Decode.maybe (Decode.field "foreignKey" decodeForeignKey))
        (Decode.maybe (Decode.field "comment" decodeColumnComment))


encodePrimaryKey : PrimaryKey -> Value
encodePrimaryKey value =
    E.object
        [ ( "columns", value.columns |> Encode.list encodeColumnName )
        , ( "name", value.name |> encodePrimaryKeyName )
        ]


decodePrimaryKey : Decode.Decoder PrimaryKey
decodePrimaryKey =
    Decode.map2 PrimaryKey
        (Decode.field "columns" (Decode.list decodeColumnName))
        (Decode.field "name" decodePrimaryKeyName)


encodeForeignKey : ForeignKey -> Value
encodeForeignKey value =
    E.object
        [ ( "schema", value.schema |> encodeSchemaName )
        , ( "table", value.table |> encodeTableName )
        , ( "column", value.column |> encodeColumnName )
        , ( "name", value.name |> encodeForeignKeyName )
        ]


decodeForeignKey : Decode.Decoder ForeignKey
decodeForeignKey =
    Decode.map4 (\schema table column name -> ForeignKey (TableId schema table) schema table column name)
        (Decode.field "schema" decodeSchemaName)
        (Decode.field "table" decodeTableName)
        (Decode.field "column" decodeColumnName)
        (Decode.field "name" decodeForeignKeyName)


encodeUnique : Unique -> Value
encodeUnique value =
    E.object
        [ ( "name", value.name |> encodeUniqueName )
        , ( "columns", value.columns |> Encode.list encodeColumnName )
        , ( "definition", value.definition |> Encode.string )
        ]


decodeUnique : Decode.Decoder Unique
decodeUnique =
    Decode.map3 Unique
        (Decode.field "name" decodeUniqueName)
        (Decode.field "columns" (Decode.list decodeColumnName))
        (Decode.field "definition" Decode.string)


encodeIndex : Index -> Value
encodeIndex value =
    E.object
        [ ( "name", value.name |> encodeIndexName )
        , ( "columns", value.columns |> Encode.list encodeColumnName )
        , ( "definition", value.definition |> Encode.string )
        ]


decodeIndex : Decode.Decoder Index
decodeIndex =
    Decode.map3 Index
        (Decode.field "name" decodeIndexName)
        (Decode.field "columns" (Decode.list decodeColumnName))
        (Decode.field "definition" Decode.string)


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
        , ( "zoom", value.zoom |> encodeZoomLevel )
        ]


decodeCanvasProps : Decode.Decoder CanvasProps
decodeCanvasProps =
    Decode.map2 CanvasProps
        (Decode.field "position" decodePosition)
        (Decode.field "zoom" decodeZoomLevel)


encodeTableProps : TableProps -> Value
encodeTableProps value =
    E.object
        [ ( "position", value.position |> encodePosition )
        , ( "color", value.color |> encodeColor )
        , ( "selected", value.selected |> Encode.bool )
        , ( "columns", value.columns |> Encode.list encodeColumnName )
        ]


decodeTableProps : Decode.Decoder TableProps
decodeTableProps =
    Decode.map4 TableProps
        (Decode.field "position" decodePosition)
        (Decode.field "color" decodeColor)
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


encodeZoomLevel : ZoomLevel -> Value
encodeZoomLevel value =
    Encode.float value


decodeZoomLevel : Decode.Decoder ZoomLevel
decodeZoomLevel =
    Decode.float


encodeColor : Color -> Value
encodeColor value =
    Encode.string value


decodeColor : Decode.Decoder Color
decodeColor =
    Decode.string


encodeTableId : TableId -> Value
encodeTableId value =
    Encode.string (tableIdAsString value)


decodeTableId : Decode.Decoder TableId
decodeTableId =
    Decode.string |> Decode.map stringAsTableId


encodeSchemaName : SchemaName -> Value
encodeSchemaName (SchemaName value) =
    Encode.string value


decodeSchemaName : Decode.Decoder SchemaName
decodeSchemaName =
    Decode.string |> Decode.map SchemaName


encodeTableName : TableName -> Value
encodeTableName (TableName value) =
    Encode.string value


decodeTableName : Decode.Decoder TableName
decodeTableName =
    Decode.string |> Decode.map TableName


encodeColumnName : ColumnName -> Value
encodeColumnName (ColumnName value) =
    Encode.string value


decodeColumnName : Decode.Decoder ColumnName
decodeColumnName =
    Decode.string |> Decode.map ColumnName


encodeColumnIndex : ColumnIndex -> Value
encodeColumnIndex (ColumnIndex value) =
    Encode.int value


decodeColumnIndex : Decode.Decoder ColumnIndex
decodeColumnIndex =
    Decode.int |> Decode.map ColumnIndex


encodeColumnType : ColumnType -> Value
encodeColumnType (ColumnType value) =
    Encode.string value


decodeColumnType : Decode.Decoder ColumnType
decodeColumnType =
    Decode.string |> Decode.map ColumnType


encodeColumnValue : ColumnValue -> Value
encodeColumnValue (ColumnValue value) =
    Encode.string value


decodeColumnValue : Decode.Decoder ColumnValue
decodeColumnValue =
    Decode.string |> Decode.map ColumnValue


encodePrimaryKeyName : PrimaryKeyName -> Value
encodePrimaryKeyName (PrimaryKeyName value) =
    Encode.string value


decodePrimaryKeyName : Decode.Decoder PrimaryKeyName
decodePrimaryKeyName =
    Decode.string |> Decode.map PrimaryKeyName


encodeForeignKeyName : ForeignKeyName -> Value
encodeForeignKeyName (ForeignKeyName value) =
    Encode.string value


decodeForeignKeyName : Decode.Decoder ForeignKeyName
decodeForeignKeyName =
    Decode.string |> Decode.map ForeignKeyName


encodeUniqueName : UniqueName -> Value
encodeUniqueName (UniqueName value) =
    Encode.string value


decodeUniqueName : Decode.Decoder UniqueName
decodeUniqueName =
    Decode.string |> Decode.map UniqueName


encodeIndexName : IndexName -> Value
encodeIndexName (IndexName value) =
    Encode.string value


decodeIndexName : Decode.Decoder IndexName
decodeIndexName =
    Decode.string |> Decode.map IndexName


encodeTableComment : TableComment -> Value
encodeTableComment (TableComment value) =
    Encode.string value


decodeTableComment : Decode.Decoder TableComment
decodeTableComment =
    Decode.string |> Decode.map TableComment


encodeColumnComment : ColumnComment -> Value
encodeColumnComment (ColumnComment value) =
    Encode.string value


decodeColumnComment : Decode.Decoder ColumnComment
decodeColumnComment =
    Decode.string |> Decode.map ColumnComment


encodePosix : Time.Posix -> Value
encodePosix value =
    value |> Time.posixToMillis |> Encode.int


decodePosix : Decode.Decoder Time.Posix
decodePosix =
    Decode.int |> Decode.map Time.millisToPosix


encodeMaybe : (a -> Value) -> Maybe a -> Value
encodeMaybe encoder maybe =
    maybe |> Maybe.map encoder |> Maybe.withDefault Encode.null


encodeMaybeWithoutDefault : (a -> a -> Value) -> a -> a -> Value
encodeMaybeWithoutDefault encode default value =
    Just value |> M.filter (\v -> not (v == default)) |> encodeMaybe (encode default)


decodeMaybeWithDefault : (a -> Decode.Decoder a) -> a -> Decode.Decoder a
decodeMaybeWithDefault decoder a =
    Decode.maybe (decoder a) |> Decode.map (Maybe.withDefault a)
