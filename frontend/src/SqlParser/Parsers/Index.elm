module SqlParser.Parsers.Index exposing (ParsedIndex, parseCreateIndex)

import SqlParser.Utils.Helpers exposing (parseIndexDefinition, regexMatches)
import SqlParser.Utils.Types exposing (ColumnName, ConstraintName, ParseError, RawSql, TableRef)


type alias ParsedIndex =
    { name : ConstraintName, table : TableRef, columns : List ColumnName, definition : String }


parseCreateIndex : RawSql -> Result (List ParseError) ParsedIndex
parseCreateIndex sql =
    case sql |> regexMatches "^CREATE INDEX[ \t]+(?<name>[^ ]+)[ \t]+ON[ \t]+(?:(?<schema>[^ .]+)\\.)?(?<table>[^ (]+)[ \t]*(?<definition>.+);$" of
        (Just name) :: schema :: (Just table) :: (Just definition) :: [] ->
            parseIndexDefinition definition
                |> Result.map (\columns -> { name = name, table = { schema = schema, table = table }, columns = columns, definition = definition })

        _ ->
            Err [ "Can't parse create index: '" ++ sql ++ "'" ]
