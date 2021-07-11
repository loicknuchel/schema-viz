module SqlParser.Parsers.CreateIndex exposing (ParsedIndex, parseCreateIndex)

import Libs.Regex as R
import SqlParser.Utils.Helpers exposing (buildRawSql, parseIndexDefinition)
import SqlParser.Utils.Types exposing (ParseError, SqlColumnName, SqlConstraintName, SqlStatement, SqlTableRef)


type alias ParsedIndex =
    { name : SqlConstraintName, table : SqlTableRef, columns : List SqlColumnName, definition : String }


parseCreateIndex : SqlStatement -> Result (List ParseError) ParsedIndex
parseCreateIndex statement =
    case statement |> buildRawSql |> R.matches "^CREATE INDEX[ \t]+(?<name>[^ ]+)[ \t]+ON[ \t]+(?:(?<schema>[^ .]+)\\.)?(?<table>[^ (]+)[ \t]*(?<definition>.+);$" of
        (Just name) :: schema :: (Just table) :: (Just definition) :: [] ->
            parseIndexDefinition definition
                |> Result.map (\columns -> { name = name, table = { schema = schema, table = table }, columns = columns, definition = definition })

        _ ->
            Err [ "Can't parse create index: '" ++ buildRawSql statement ++ "'" ]
