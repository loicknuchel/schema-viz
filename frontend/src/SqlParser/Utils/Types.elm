module SqlParser.Utils.Types exposing (ColumnName, ConstraintName, ParseError, RawSql, SchemaName, TableName, TableRef)


type alias RawSql =
    String


type alias ParseError =
    String


type alias ConstraintName =
    String


type alias SchemaName =
    String


type alias TableName =
    String


type alias ColumnName =
    String


type alias TableRef =
    { schema : Maybe SchemaName, table : TableName }
