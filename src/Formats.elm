module Formats exposing (..)

import Http exposing (Error(..))
import Models.Schema exposing (Column, ColumnName(..), ColumnType(..), SchemaName(..), Table, TableName(..))
import Models.Utils exposing (Size)


formatTableId : Table -> String
formatTableId table =
    case ( table.schema, table.table ) of
        ( SchemaName schema, TableName name ) ->
            schema ++ "." ++ name


formatTableName : Table -> String
formatTableName table =
    case ( table.schema, table.table ) of
        ( SchemaName schema, TableName name ) ->
            schema ++ "." ++ name


formatColumnName : Column -> String
formatColumnName column =
    case column.column of
        ColumnName name ->
            name


formatColumnType : Column -> String
formatColumnType column =
    case column.kind of
        ColumnType kind ->
            kind


formatSize : Size -> String
formatSize size =
    String.fromFloat size.width ++ "x" ++ String.fromFloat size.height


formatHttpError : Http.Error -> String
formatHttpError error =
    case error of
        BadUrl url ->
            "The URL " ++ url ++ " was invalid"

        Timeout ->
            "Unable to reach the server, try again"

        NetworkError ->
            "Unable to reach the server, check your network connection"

        BadStatus 500 ->
            "The server had a problem, try again later"

        BadStatus 400 ->
            "Verify your information and try again"

        BadStatus _ ->
            "Unknown error"

        BadBody errorMessage ->
            errorMessage
