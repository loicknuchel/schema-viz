module SqlParser.Utils.Types exposing (ConstraintName, ForeignKeyRef, ParseError, RawSql, SqlColumnName, SqlColumnType, SqlColumnValue, SqlSchemaName, SqlTableName, SqlTableRef)


type alias RawSql =
    String


type alias ParseError =
    String


type alias ConstraintName =
    String


type alias SqlSchemaName =
    String


type alias SqlTableName =
    String


type alias SqlColumnName =
    String


type alias SqlColumnType =
    String


type alias SqlColumnValue =
    String


type alias SqlTableRef =
    { schema : Maybe SqlSchemaName, table : SqlTableName }


type alias ForeignKeyRef =
    { schema : Maybe SqlSchemaName, table : SqlTableName, column : Maybe SqlColumnName }
