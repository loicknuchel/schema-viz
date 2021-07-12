module SqlParser.SqlParser exposing (Command(..), parseCommand)

import SqlParser.Parsers.AlterTable exposing (TableUpdate, parseAlterTable)
import SqlParser.Parsers.Comment exposing (CommentOnColumn, CommentOnTable, parseColumnComment, parseTableComment)
import SqlParser.Parsers.CreateIndex exposing (ParsedIndex, parseCreateIndex)
import SqlParser.Parsers.CreateTable exposing (ParsedTable, parseCreateTable)
import SqlParser.Parsers.CreateUnique exposing (ParsedUnique, parseCreateUniqueIndex)
import SqlParser.Parsers.CreateView exposing (ParsedView, parseView)
import SqlParser.Utils.Helpers exposing (buildRawSql)
import SqlParser.Utils.Types exposing (ParseError, SqlStatement)



-- deps = { to = { only = [ "Libs.*", "SqlParser\\.Utils.*", "SqlParser\\.Parsers.*" ] } }


type Command
    = CreateTable ParsedTable
    | CreateView ParsedView
    | AlterTable TableUpdate
    | CreateIndex ParsedIndex
    | CreateUnique ParsedUnique
    | TableComment CommentOnTable
    | ColumnComment CommentOnColumn
    | Ignored SqlStatement


parseCommand : SqlStatement -> Result (List ParseError) Command
parseCommand statement =
    if statement.head.text |> String.toUpper |> String.startsWith "CREATE TABLE " then
        parseCreateTable statement |> Result.map CreateTable

    else if statement.head.text |> String.toUpper |> String.startsWith "CREATE VIEW " then
        parseView statement |> Result.map CreateView

    else if statement.head.text |> String.toUpper |> String.startsWith "CREATE MATERIALIZED VIEW " then
        parseView statement |> Result.map CreateView

    else if statement.head.text |> String.toUpper |> String.startsWith "ALTER TABLE " then
        parseAlterTable statement |> Result.map AlterTable

    else if statement.head.text |> String.toUpper |> String.startsWith "CREATE INDEX " then
        parseCreateIndex statement |> Result.map CreateIndex

    else if statement.head.text |> String.toUpper |> String.startsWith "CREATE UNIQUE INDEX " then
        parseCreateUniqueIndex statement |> Result.map CreateUnique

    else if statement.head.text |> String.toUpper |> String.startsWith "COMMENT ON TABLE " then
        parseTableComment statement |> Result.map TableComment

    else if statement.head.text |> String.toUpper |> String.startsWith "COMMENT ON COLUMN " then
        parseColumnComment statement |> Result.map ColumnComment

    else if statement.head.text |> String.toUpper |> String.startsWith "CREATE OR REPLACE VIEW " then
        Ok (Ignored statement)

    else if statement.head.text |> String.toUpper |> String.startsWith "COMMENT ON VIEW " then
        Ok (Ignored statement)

    else if statement.head.text |> String.toUpper |> String.startsWith "COMMENT ON INDEX " then
        Ok (Ignored statement)

    else if statement.head.text |> String.toUpper |> String.startsWith "CREATE TYPE " then
        Ok (Ignored statement)

    else if statement.head.text |> String.toUpper |> String.startsWith "ALTER TYPE " then
        Ok (Ignored statement)

    else if statement.head.text |> String.toUpper |> String.startsWith "CREATE FUNCTION " then
        Ok (Ignored statement)

    else if statement.head.text |> String.toUpper |> String.startsWith "ALTER FUNCTION " then
        Ok (Ignored statement)

    else if statement.head.text |> String.toUpper |> String.startsWith "CREATE OPERATOR " then
        Ok (Ignored statement)

    else if statement.head.text |> String.toUpper |> String.startsWith "ALTER OPERATOR " then
        Ok (Ignored statement)

    else if statement.head.text |> String.toUpper |> String.startsWith "CREATE SCHEMA " then
        Ok (Ignored statement)

    else if statement.head.text |> String.toUpper |> String.startsWith "CREATE EXTENSION " then
        Ok (Ignored statement)

    else if statement.head.text |> String.toUpper |> String.startsWith "COMMENT ON EXTENSION " then
        Ok (Ignored statement)

    else if statement.head.text |> String.toUpper |> String.startsWith "CREATE TEXT SEARCH CONFIGURATION " then
        Ok (Ignored statement)

    else if statement.head.text |> String.toUpper |> String.startsWith "ALTER TEXT SEARCH CONFIGURATION " then
        Ok (Ignored statement)

    else if statement.head.text |> String.toUpper |> String.startsWith "CREATE SEQUENCE " then
        Ok (Ignored statement)

    else if statement.head.text |> String.toUpper |> String.startsWith "ALTER SEQUENCE " then
        Ok (Ignored statement)

    else if statement.head.text |> String.toUpper |> String.startsWith "SELECT " then
        Ok (Ignored statement)

    else if statement.head.text |> String.toUpper |> String.startsWith "INSERT INTO " then
        Ok (Ignored statement)

    else if statement.head.text |> String.toUpper |> String.startsWith "SET " then
        Ok (Ignored statement)

    else
        Err [ "Statement not handled: '" ++ buildRawSql statement ++ "'" ]
