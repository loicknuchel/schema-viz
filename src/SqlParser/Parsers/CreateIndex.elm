module SqlParser.Parsers.CreateIndex exposing (ParsedIndex, parseCreateIndex)

import Libs.Regex as R
import SqlParser.Utils.Helpers exposing (parseIndexDefinition)
import SqlParser.Utils.Types exposing (ConstraintName, ParseError, RawSql, SqlColumnName, SqlTableRef)


type alias ParsedIndex =
    { name : ConstraintName, table : SqlTableRef, columns : List SqlColumnName, definition : String }


parseCreateIndex : RawSql -> Result (List ParseError) ParsedIndex
parseCreateIndex sql =
    case sql |> R.matches "^CREATE INDEX[ \t]+(?<name>[^ ]+)[ \t]+ON[ \t]+(?:(?<schema>[^ .]+)\\.)?(?<table>[^ (]+)[ \t]*(?<definition>.+);$" of
        (Just name) :: schema :: (Just table) :: (Just definition) :: [] ->
            parseIndexDefinition definition
                |> Result.map (\columns -> { name = name, table = { schema = schema, table = table }, columns = columns, definition = definition })

        _ ->
            Err [ "Can't parse create index: '" ++ sql ++ "'" ]
