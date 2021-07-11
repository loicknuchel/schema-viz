module SqlParser.Parsers.CreateUnique exposing (ParsedUnique, parseCreateUniqueIndex)

import Libs.Regex as R
import SqlParser.Utils.Helpers exposing (buildRawSql, parseIndexDefinition)
import SqlParser.Utils.Types exposing (ParseError, SqlColumnName, SqlConstraintName, SqlStatement, SqlTableRef)


type alias ParsedUnique =
    { name : SqlConstraintName, table : SqlTableRef, columns : List SqlColumnName, definition : String }


parseCreateUniqueIndex : SqlStatement -> Result (List ParseError) ParsedUnique
parseCreateUniqueIndex statement =
    case statement |> buildRawSql |> R.matches "^CREATE UNIQUE INDEX[ \t]+(?<name>[^ ]+)[ \t]+ON[ \t]+(?:(?<schema>[^ .]+)\\.)?(?<table>[^ (]+)[ \t]*(?<definition>.+);$" of
        (Just name) :: schema :: (Just table) :: (Just definition) :: [] ->
            parseIndexDefinition definition
                |> Result.map (\columns -> { name = name, table = { schema = schema, table = table }, columns = columns, definition = definition })

        _ ->
            Err [ "Can't parse create unique index: '" ++ buildRawSql statement ++ "'" ]
