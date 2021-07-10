module SqlParser.Parsers.CreateView exposing (ParsedView, parseView)

import Libs.Regex as R
import SqlParser.Parsers.Select exposing (SelectInfo, parseSelect)
import SqlParser.Utils.Types exposing (ParseError, RawSql, SqlSchemaName, SqlTableName)


type alias ParsedView =
    { schema : Maybe SqlSchemaName, table : SqlTableName, select : SelectInfo, materialized : Bool, extra : Maybe String }


parseView : RawSql -> Result (List ParseError) ParsedView
parseView sql =
    case sql |> R.matches "^CREATE (MATERIALIZED )?VIEW[ \t]+(?:(?<schema>[^ .]+)\\.)?(?<table>[^ ]+)[ \t]+AS[ \t]+(?<select>.+?)(?:[ \t]+(?<extra>WITH (?:NO )?DATA))?;$" of
        materialized :: schema :: (Just table) :: (Just select) :: extra :: [] ->
            parseSelect select
                |> Result.map (\parsedSelect -> { schema = schema, table = table, select = parsedSelect, materialized = not (materialized == Nothing), extra = extra })

        _ ->
            Err [ "Can't parse create view: '" ++ sql ++ "'" ]
