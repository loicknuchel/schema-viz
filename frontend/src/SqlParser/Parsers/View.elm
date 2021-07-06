module SqlParser.Parsers.View exposing (..)

import SqlParser.Utils.Helpers exposing (regexMatches)
import SqlParser.Utils.Types exposing (ParseError, RawSql, SchemaName, TableName)


type alias ParsedView =
    { schema : Maybe SchemaName, table : TableName, definition : String }


parseView : RawSql -> Result (List ParseError) ParsedView
parseView sql =
    case sql |> regexMatches "^CREATE (?:MATERIALIZED )?VIEW[ \t]+(?:(?<schema>[^ .]+)\\.)?(?<table>[^ ]+)[ \t]+AS[ \t]+(?<definition>.+);$" of
        schema :: (Just table) :: (Just definition) :: [] ->
            Ok { schema = schema, table = table, definition = definition }

        _ ->
            Err [ "Can't parse create view: '" ++ sql ++ "'" ]
