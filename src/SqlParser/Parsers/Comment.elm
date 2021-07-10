module SqlParser.Parsers.Comment exposing (Comment, CommentOnColumn, CommentOnTable, parseColumnComment, parseTableComment)

import Libs.Regex as R
import SqlParser.Utils.Types exposing (ParseError, RawSql, SqlColumnName, SqlSchemaName, SqlTableName)


type alias CommentOnTable =
    { schema : Maybe SqlSchemaName, table : SqlTableName, comment : Comment }


type alias CommentOnColumn =
    { schema : Maybe SqlSchemaName, table : SqlTableName, column : SqlColumnName, comment : Comment }


type alias Comment =
    String


parseTableComment : RawSql -> Result (List ParseError) CommentOnTable
parseTableComment sql =
    case sql |> R.matches "^COMMENT ON TABLE[ \t]+(?:(?<schema>[^ .]+)\\.)?(?<table>[^ .]+)[ \t]+IS[ \t]+'(?<comment>(?:[^']|'')+)';$" of
        schema :: (Just table) :: (Just comment) :: [] ->
            Ok { schema = schema, table = table, comment = comment |> String.replace "''" "'" }

        _ ->
            Err [ "Can't parse table comment: '" ++ sql ++ "'" ]


parseColumnComment : RawSql -> Result (List ParseError) CommentOnColumn
parseColumnComment sql =
    case sql |> R.matches "^COMMENT ON COLUMN[ \t]+(?:(?<schema>[^ .]+)\\.)?(?<table>[^ .]+)\\.(?<column>[^ .]+)[ \t]+IS[ \t]+'(?<comment>(?:[^']|'')+)';$" of
        schema :: (Just table) :: (Just column) :: (Just comment) :: [] ->
            Ok { schema = schema, table = table, column = column, comment = comment |> String.replace "''" "'" }

        _ ->
            Err [ "Can't parse column comment: '" ++ sql ++ "'" ]
