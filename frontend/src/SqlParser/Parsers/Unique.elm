module SqlParser.Parsers.Unique exposing (ParsedUnique, parseCreateUniqueIndex)

import SqlParser.Utils.Helpers exposing (parseIndexDefinition, regexMatches)
import SqlParser.Utils.Types exposing (ColumnName, ConstraintName, ParseError, RawSql, TableRef)


type alias ParsedUnique =
    { name : ConstraintName, table : TableRef, columns : List ColumnName, definition : String }


parseCreateUniqueIndex : RawSql -> Result (List ParseError) ParsedUnique
parseCreateUniqueIndex sql =
    case sql |> regexMatches "^CREATE UNIQUE INDEX[ \t]+(?<name>[^ ]+)[ \t]+ON[ \t]+(?:(?<schema>[^ .]+)\\.)?(?<table>[^ (]+)[ \t]*(?<definition>.+);$" of
        (Just name) :: schema :: (Just table) :: (Just definition) :: [] ->
            parseIndexDefinition definition
                |> Result.map (\columns -> { name = name, table = { schema = schema, table = table }, columns = columns, definition = definition })

        _ ->
            Err [ "Can't parse create unique index: '" ++ sql ++ "'" ]
