module SqlParser.SqlParser exposing (Command(..), parseCommand)

import SqlParser.Parsers.AlterTable exposing (TableUpdate, parseAlterTable)
import SqlParser.Parsers.Comment exposing (CommentOnColumn, CommentOnTable, parseColumnComment, parseTableComment)
import SqlParser.Parsers.CreateIndex exposing (ParsedIndex, parseCreateIndex)
import SqlParser.Parsers.CreateTable exposing (ParsedTable, parseCreateTable)
import SqlParser.Parsers.CreateUnique exposing (ParsedUnique, parseCreateUniqueIndex)
import SqlParser.Parsers.CreateView exposing (ParsedView, parseView)
import SqlParser.Utils.Types exposing (ParseError, RawSql)


type Command
    = CreateTable ParsedTable
    | CreateView ParsedView
    | AlterTable TableUpdate
    | CreateIndex ParsedIndex
    | CreateUnique ParsedUnique
    | TableComment CommentOnTable
    | ColumnComment CommentOnColumn
    | Ignored RawSql


parseCommand : RawSql -> Result (List ParseError) Command
parseCommand sql =
    if sql |> String.toUpper |> String.startsWith "CREATE TABLE " then
        parseCreateTable sql |> Result.map CreateTable

    else if sql |> String.toUpper |> String.startsWith "CREATE VIEW " then
        parseView sql |> Result.map CreateView

    else if sql |> String.toUpper |> String.startsWith "CREATE MATERIALIZED VIEW " then
        parseView sql |> Result.map CreateView

    else if sql |> String.toUpper |> String.startsWith "ALTER TABLE " then
        parseAlterTable sql |> Result.map AlterTable

    else if sql |> String.toUpper |> String.startsWith "CREATE INDEX " then
        parseCreateIndex sql |> Result.map CreateIndex

    else if sql |> String.toUpper |> String.startsWith "CREATE UNIQUE INDEX " then
        parseCreateUniqueIndex sql |> Result.map CreateUnique

    else if sql |> String.toUpper |> String.startsWith "COMMENT ON TABLE " then
        parseTableComment sql |> Result.map TableComment

    else if sql |> String.toUpper |> String.startsWith "COMMENT ON COLUMN " then
        parseColumnComment sql |> Result.map ColumnComment

    else if sql |> String.toUpper |> String.startsWith "CREATE OR REPLACE VIEW " then
        Ok (Ignored sql)

    else if sql |> String.toUpper |> String.startsWith "COMMENT ON VIEW " then
        Ok (Ignored sql)

    else if sql |> String.toUpper |> String.startsWith "COMMENT ON INDEX " then
        Ok (Ignored sql)

    else if sql |> String.toUpper |> String.startsWith "CREATE TYPE " then
        Ok (Ignored sql)

    else if sql |> String.toUpper |> String.startsWith "ALTER TYPE " then
        Ok (Ignored sql)

    else if sql |> String.toUpper |> String.startsWith "CREATE FUNCTION " then
        Ok (Ignored sql)

    else if sql |> String.toUpper |> String.startsWith "ALTER FUNCTION " then
        Ok (Ignored sql)

    else if sql |> String.toUpper |> String.startsWith "CREATE OPERATOR " then
        Ok (Ignored sql)

    else if sql |> String.toUpper |> String.startsWith "ALTER OPERATOR " then
        Ok (Ignored sql)

    else if sql |> String.toUpper |> String.startsWith "CREATE SCHEMA " then
        Ok (Ignored sql)

    else if sql |> String.toUpper |> String.startsWith "CREATE EXTENSION " then
        Ok (Ignored sql)

    else if sql |> String.toUpper |> String.startsWith "COMMENT ON EXTENSION " then
        Ok (Ignored sql)

    else if sql |> String.toUpper |> String.startsWith "CREATE TEXT SEARCH CONFIGURATION " then
        Ok (Ignored sql)

    else if sql |> String.toUpper |> String.startsWith "ALTER TEXT SEARCH CONFIGURATION " then
        Ok (Ignored sql)

    else if sql |> String.toUpper |> String.startsWith "CREATE SEQUENCE " then
        Ok (Ignored sql)

    else if sql |> String.toUpper |> String.startsWith "ALTER SEQUENCE " then
        Ok (Ignored sql)

    else if sql |> String.toUpper |> String.startsWith "SELECT " then
        Ok (Ignored sql)

    else if sql |> String.toUpper |> String.startsWith "INSERT INTO " then
        Ok (Ignored sql)

    else if sql |> String.toUpper |> String.startsWith "SET " then
        Ok (Ignored sql)

    else
        Err [ "Statement not handled: '" ++ sql ++ "'" ]
