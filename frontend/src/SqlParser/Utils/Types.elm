module SqlParser.Utils.Types exposing (ConstraintName, ParseError, RawSql, SqlColumnName, SqlSchemaName, SqlTableName, SqlTableRef)


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


type alias SqlTableRef =
    { schema : Maybe SqlSchemaName, table : SqlTableName }
