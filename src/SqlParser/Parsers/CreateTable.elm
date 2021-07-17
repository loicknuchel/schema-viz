module SqlParser.Parsers.CreateTable exposing (ParsedColumn, ParsedTable, parseCreateTable, parseCreateTableColumn)

import Libs.List as L
import Libs.Nel as Nel exposing (Nel)
import Libs.Regex as R
import SqlParser.Utils.Helpers exposing (buildRawSql, commaSplit, noEnclosingQuotes)
import SqlParser.Utils.Types exposing (ParseError, RawSql, SqlColumnName, SqlColumnType, SqlColumnValue, SqlConstraintName, SqlForeignKeyRef, SqlSchemaName, SqlStatement, SqlTableName)



-- deps = { to = { only = [ "Libs.*", "SqlParser\\.Utils.*", "SqlParser\\.Parsers.*" ] } }


type alias ParsedTable =
    { schema : Maybe SqlSchemaName
    , table : SqlTableName
    , columns : Nel ParsedColumn
    , source : SqlStatement
    }


type alias ParsedColumn =
    { name : SqlColumnName
    , kind : SqlColumnType
    , nullable : Bool
    , default : Maybe SqlColumnValue
    , primaryKey : Maybe SqlConstraintName
    , foreignKey : Maybe ( SqlConstraintName, SqlForeignKeyRef )
    }


parseCreateTable : SqlStatement -> Result (List ParseError) ParsedTable
parseCreateTable statement =
    case statement |> buildRawSql |> R.matches "^CREATE TABLE[ \t]+(?:(?<schema>[^ .]+)\\.)?(?<table>[^ .]+)[ \t]*\\((?<body>[^;]+?)\\)(?:[ \t]+WITH[ \t]+\\((?<options>.*?)\\))?;$" of
        schema :: (Just table) :: (Just columns) :: _ :: [] ->
            commaSplit columns
                |> List.map String.trim
                -- TODO parse constraint: ex in accounts table
                |> List.filter (\c -> not (c |> String.toUpper |> String.startsWith "CONSTRAINT"))
                |> List.map parseCreateTableColumn
                |> L.resultSeq
                |> Result.andThen (\cols -> cols |> Nel.fromList |> Result.fromMaybe [ "Create table can't have empty columns" ])
                |> Result.map (\cols -> { schema = schema, table = table, columns = cols, source = statement })

        _ ->
            Err [ "Can't parse table: '" ++ buildRawSql statement ++ "'" ]


parseCreateTableColumn : RawSql -> Result ParseError ParsedColumn
parseCreateTableColumn sql =
    case sql |> R.matches "^(?<name>[^ ]+)[ \t]+(?<type>.*?)(?:[ \t]+DEFAULT[ \t]+(?<default>.*?))?(?<nullable>[ \t]+NOT NULL)?(?:[ \t]+CONSTRAINT[ \t]+(?<constraint>.*))?$" of
        (Just name) :: (Just kind) :: default :: nullable :: maybeConstraint :: [] ->
            maybeConstraint
                |> Maybe.map
                    (\constraint ->
                        if constraint |> String.toUpper |> String.contains "PRIMARY KEY" then
                            parseCreateTableColumnPrimaryKey constraint |> Result.map (\pk -> ( Just pk, Nothing ))

                        else if constraint |> String.toUpper |> String.contains "REFERENCES" then
                            parseCreateTableColumnForeignKey constraint |> Result.map (\fk -> ( Nothing, Just fk ))

                        else
                            Err ("Constraint not handled: '" ++ constraint ++ "' in create table")
                    )
                |> Maybe.withDefault (Ok ( Nothing, Nothing ))
                |> Result.map (\( pk, fk ) -> { name = name |> noEnclosingQuotes, kind = kind, nullable = nullable == Nothing, default = default, primaryKey = pk, foreignKey = fk })

        _ ->
            Err ("Can't parse column: '" ++ sql ++ "'")


parseCreateTableColumnPrimaryKey : RawSql -> Result ParseError SqlConstraintName
parseCreateTableColumnPrimaryKey constraint =
    case constraint |> R.matches "^(?<constraint>[^ ]+)[ \t]+PRIMARY KEY$" of
        (Just constraintName) :: [] ->
            Ok constraintName

        _ ->
            Err ("Can't parse primary key: '" ++ constraint ++ "' in create table")


parseCreateTableColumnForeignKey : RawSql -> Result ParseError ( SqlConstraintName, SqlForeignKeyRef )
parseCreateTableColumnForeignKey constraint =
    case constraint |> R.matches "^(?<constraint>[^ ]+)[ \t]+REFERENCES[ \t]+(?:(?<schema>[^ .]+)\\.)?(?<table>[^ .]+)(?:\\.(?<column>[^ .]+))?$" of
        (Just constraintName) :: (Just table) :: (Just column) :: Nothing :: [] ->
            Ok ( constraintName, { schema = Nothing, table = table, column = Just column } )

        (Just constraintName) :: schema :: (Just table) :: column :: [] ->
            Ok ( constraintName, { schema = schema, table = table, column = column } )

        _ ->
            Err ("Can't parse foreign key: '" ++ constraint ++ "' in create table")
