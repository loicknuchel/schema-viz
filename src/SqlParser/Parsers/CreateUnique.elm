module SqlParser.Parsers.CreateUnique exposing (ParsedUnique, parseCreateUniqueIndex)

import Libs.Regex as R
import SqlParser.Utils.Helpers exposing (parseIndexDefinition)
import SqlParser.Utils.Types exposing (ConstraintName, ParseError, RawSql, SqlColumnName, SqlTableRef)


type alias ParsedUnique =
    { name : ConstraintName, table : SqlTableRef, columns : List SqlColumnName, definition : String }


parseCreateUniqueIndex : RawSql -> Result (List ParseError) ParsedUnique
parseCreateUniqueIndex sql =
    case sql |> R.matches "^CREATE UNIQUE INDEX[ \t]+(?<name>[^ ]+)[ \t]+ON[ \t]+(?:(?<schema>[^ .]+)\\.)?(?<table>[^ (]+)[ \t]*(?<definition>.+);$" of
        (Just name) :: schema :: (Just table) :: (Just definition) :: [] ->
            parseIndexDefinition definition
                |> Result.map (\columns -> { name = name, table = { schema = schema, table = table }, columns = columns, definition = definition })

        _ ->
            Err [ "Can't parse create unique index: '" ++ sql ++ "'" ]
