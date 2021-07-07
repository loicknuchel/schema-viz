module SqlParser.Parsers.Select exposing (SelectColumn(..), SelectColumnBasic, SelectColumnComplex, SelectInfo, SelectTable(..), SelectTableBasic, SelectTableComplex, TableAlias, parseSelect, parseSelectColumn, parseSelectTable)

import Libs.Std exposing (listResultSeq, maybeToList)
import SqlParser.Utils.Helpers exposing (commaSplit, noEnclosingQuotes, regexMatches)
import SqlParser.Utils.Types exposing (ParseError, RawSql, SqlColumnName, SqlSchemaName, SqlTableName)


type alias SelectInfo =
    { columns : List SelectColumn, tables : List SelectTable, whereClause : Maybe String }


type SelectColumn
    = BasicColumn SelectColumnBasic
    | ComplexColumn SelectColumnComplex


type alias SelectColumnBasic =
    { table : Maybe TableAlias, column : SqlColumnName, alias : Maybe SqlColumnName }


type alias SelectColumnComplex =
    { formula : String, alias : SqlColumnName }


type SelectTable
    = BasicTable SelectTableBasic
    | ComplexTable SelectTableComplex


type alias SelectTableBasic =
    { schema : Maybe SqlSchemaName, table : SqlTableName, alias : Maybe SqlTableName }


type alias SelectTableComplex =
    { definition : String }


type alias TableAlias =
    String


parseSelect : RawSql -> Result (List ParseError) SelectInfo
parseSelect select =
    case select |> regexMatches "^SELECT(?:[ \t]+DISTINCT ON \\([^)]+\\))?[ \t]+(?<columns>.+?)(?:[ \t]+FROM[ \t]+(?<tables>.+?))?(?:[ \t]+WHERE[ \t]+(?<where>.+?))?$" of
        (Just columnsStr) :: tablesStr :: whereClause :: [] ->
            Result.map2 (\columns tables -> { columns = columns, tables = tables, whereClause = whereClause })
                (commaSplit columnsStr |> List.map String.trim |> List.map parseSelectColumn |> listResultSeq)
                (tablesStr |> maybeToList |> List.map parseSelectTable |> listResultSeq)

        _ ->
            Err [ "Can't parse select: '" ++ select ++ "'" ]


parseSelectColumn : RawSql -> Result ParseError SelectColumn
parseSelectColumn column =
    case column |> regexMatches "^(?:(?<table>[^ .]+)\\.)?(?<column>[^ :]+)(?:[ \t]+AS[ \t]+(?<alias>[^ ]+))?$" of
        table :: (Just columnName) :: alias :: [] ->
            Ok (BasicColumn { table = table, column = columnName |> noEnclosingQuotes, alias = alias })

        _ ->
            case column |> regexMatches "^(?<formula>.+?)[ \t]+AS[ \t]+(?<alias>[^ ]+)$" of
                (Just formula) :: (Just alias) :: [] ->
                    Ok (ComplexColumn { formula = formula, alias = alias })

                _ ->
                    Err ("Can't parse select column '" ++ column ++ "'")


parseSelectTable : RawSql -> Result ParseError SelectTable
parseSelectTable table =
    case table |> regexMatches "^(?:(?<schema>[^ .]+)\\.)?(?<table>[^ ]+)(?:[ \t]+(?<alias>[^ ]+))?$" of
        schema :: (Just tableName) :: alias :: [] ->
            Ok (BasicTable { schema = schema, table = tableName, alias = alias })

        _ ->
            Ok (ComplexTable { definition = table })
