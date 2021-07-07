module SqlParser.SqlParser exposing (CheckInner, ColumnType, ColumnUpdate(..), ColumnValue, Command(..), Comment, CommentOnColumn, CommentOnTable, ForeignKeyInner, ForeignKeyRef, ParsedColumn, ParsedTable, Predicate, PrimaryKeyInner, TableConstraint(..), TableUpdate(..), UniqueInner, User, parseAlterTable, parseColumnComment, parseCommand, parseCreateTable, parseCreateTableColumn, parseTableComment)

import Libs.Std exposing (listResultSeq)
import SqlParser.Parsers.Index exposing (ParsedIndex, parseCreateIndex)
import SqlParser.Parsers.Unique exposing (ParsedUnique, parseCreateUniqueIndex)
import SqlParser.Parsers.View exposing (ParsedView, parseView)
import SqlParser.Utils.Helpers exposing (commaSplit, noEnclosingQuotes, parseIndexDefinition, regexMatches)
import SqlParser.Utils.Types exposing (ConstraintName, ParseError, RawSql, SqlColumnName, SqlSchemaName, SqlTableName)


type Command
    = CreateTable ParsedTable
    | CreateView ParsedView
    | AlterTable TableUpdate
    | CreateIndex ParsedIndex
    | CreateUnique ParsedUnique
    | TableComment CommentOnTable
    | ColumnComment CommentOnColumn
    | Ignored RawSql


type alias ColumnType =
    String


type alias ColumnValue =
    String


type alias User =
    String


type alias ParsedTable =
    { schema : Maybe SqlSchemaName, table : SqlTableName, columns : List ParsedColumn }


type alias ParsedColumn =
    { name : SqlColumnName, kind : ColumnType, nullable : Bool, default : Maybe ColumnValue, primaryKey : Maybe ConstraintName, foreignKey : Maybe ( ConstraintName, ForeignKeyRef ) }


type TableUpdate
    = AddTableConstraint (Maybe SqlSchemaName) SqlTableName TableConstraint
    | AlterColumn (Maybe SqlSchemaName) SqlTableName ColumnUpdate
    | AddTableOwner (Maybe SqlSchemaName) SqlTableName User


type TableConstraint
    = ParsedPrimaryKey ConstraintName PrimaryKeyInner
    | ParsedForeignKey ConstraintName ForeignKeyInner
    | ParsedUnique ConstraintName UniqueInner
    | ParsedCheck ConstraintName CheckInner


type alias PrimaryKeyInner =
    List SqlColumnName


type alias ForeignKeyRef =
    { schema : Maybe SqlSchemaName, table : SqlTableName, column : Maybe SqlColumnName }


type alias ForeignKeyInner =
    { column : SqlColumnName, ref : ForeignKeyRef }


type alias UniqueInner =
    { columns : List SqlColumnName, definition : String }


type alias Predicate =
    String


type alias CheckInner =
    Predicate


type ColumnUpdate
    = ColumnDefault SqlColumnName ColumnValue
    | ColumnStatistics SqlColumnName Int


type alias Comment =
    String


type alias CommentOnTable =
    { schema : Maybe SqlSchemaName, table : SqlTableName, comment : Comment }


type alias CommentOnColumn =
    { schema : Maybe SqlSchemaName, table : SqlTableName, column : SqlColumnName, comment : Comment }


parseCommand : RawSql -> Result (List ParseError) Command
parseCommand sql =
    if sql |> String.toUpper |> String.startsWith "CREATE TABLE " then
        parseCreateTable sql |> Result.map CreateTable

    else if sql |> String.toUpper |> String.startsWith "CREATE VIEW " then
        parseView sql |> Result.map CreateView

    else if sql |> String.toUpper |> String.startsWith "CREATE MATERIALIZED VIEW " then
        parseView sql |> Result.map CreateView

    else if sql |> String.toUpper |> String.startsWith "ALTER TABLE " then
        parseAlterTable sql |> Result.map AlterTable

    else if sql |> String.toUpper |> String.startsWith "CREATE INDEX " then
        parseCreateIndex sql |> Result.map CreateIndex

    else if sql |> String.toUpper |> String.startsWith "CREATE UNIQUE INDEX " then
        parseCreateUniqueIndex sql |> Result.map CreateUnique

    else if sql |> String.toUpper |> String.startsWith "COMMENT ON TABLE " then
        parseTableComment sql |> Result.map TableComment

    else if sql |> String.toUpper |> String.startsWith "COMMENT ON COLUMN " then
        parseColumnComment sql |> Result.map ColumnComment

    else if sql |> String.toUpper |> String.startsWith "CREATE OR REPLACE VIEW " then
        Ok (Ignored sql)

    else if sql |> String.toUpper |> String.startsWith "COMMENT ON VIEW " then
        Ok (Ignored sql)

    else if sql |> String.toUpper |> String.startsWith "COMMENT ON INDEX " then
        Ok (Ignored sql)

    else if sql |> String.toUpper |> String.startsWith "CREATE TYPE " then
        Ok (Ignored sql)

    else if sql |> String.toUpper |> String.startsWith "ALTER TYPE " then
        Ok (Ignored sql)

    else if sql |> String.toUpper |> String.startsWith "CREATE FUNCTION " then
        Ok (Ignored sql)

    else if sql |> String.toUpper |> String.startsWith "ALTER FUNCTION " then
        Ok (Ignored sql)

    else if sql |> String.toUpper |> String.startsWith "CREATE OPERATOR " then
        Ok (Ignored sql)

    else if sql |> String.toUpper |> String.startsWith "ALTER OPERATOR " then
        Ok (Ignored sql)

    else if sql |> String.toUpper |> String.startsWith "CREATE SCHEMA " then
        Ok (Ignored sql)

    else if sql |> String.toUpper |> String.startsWith "CREATE EXTENSION " then
        Ok (Ignored sql)

    else if sql |> String.toUpper |> String.startsWith "COMMENT ON EXTENSION " then
        Ok (Ignored sql)

    else if sql |> String.toUpper |> String.startsWith "CREATE TEXT SEARCH CONFIGURATION " then
        Ok (Ignored sql)

    else if sql |> String.toUpper |> String.startsWith "ALTER TEXT SEARCH CONFIGURATION " then
        Ok (Ignored sql)

    else if sql |> String.toUpper |> String.startsWith "CREATE SEQUENCE " then
        Ok (Ignored sql)

    else if sql |> String.toUpper |> String.startsWith "ALTER SEQUENCE " then
        Ok (Ignored sql)

    else if sql |> String.toUpper |> String.startsWith "SELECT " then
        Ok (Ignored sql)

    else if sql |> String.toUpper |> String.startsWith "INSERT INTO " then
        Ok (Ignored sql)

    else if sql |> String.toUpper |> String.startsWith "SET " then
        Ok (Ignored sql)

    else
        Err [ "Statement not handled: '" ++ sql ++ "'" ]


parseCreateTable : RawSql -> Result (List ParseError) ParsedTable
parseCreateTable sql =
    case regexMatches "^CREATE TABLE[ \t]+(?:(?<schema>[^ .]+)\\.)?(?<table>[^ .]+)[ \t]*\\((?<body>[^;]+?)\\)(?:[ \t]+WITH[ \t]+\\((?<options>.*?)\\))?;$" sql of
        schema :: (Just table) :: (Just columns) :: _ :: [] ->
            commaSplit columns
                |> List.map String.trim
                -- TODO parse constraint: ex in accounts table
                |> List.filter (\c -> not (c |> String.toUpper |> String.startsWith "CONSTRAINT"))
                |> List.map parseCreateTableColumn
                |> listResultSeq
                |> Result.map (\c -> { schema = schema, table = table, columns = c })

        _ ->
            Err [ "Can't parse table: '" ++ sql ++ "'" ]


parseCreateTableColumn : RawSql -> Result ParseError ParsedColumn
parseCreateTableColumn sql =
    case regexMatches "^(?<name>[^ ]+)[ \t]+(?<type>.*?)(?:[ \t]+DEFAULT[ \t]+(?<default>.*?))?(?<nullable>[ \t]+NOT NULL)?(?:[ \t]+CONSTRAINT[ \t]+(?<constraint>.*))?$" sql of
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


parseCreateTableColumnPrimaryKey : RawSql -> Result ParseError ConstraintName
parseCreateTableColumnPrimaryKey constraint =
    case regexMatches "^(?<constraint>[^ ]+)[ \t]+PRIMARY KEY$" constraint of
        (Just constraintName) :: [] ->
            Ok constraintName

        _ ->
            Err ("Can't parse primary key: '" ++ constraint ++ "' in create table")


parseCreateTableColumnForeignKey : RawSql -> Result ParseError ( ConstraintName, ForeignKeyRef )
parseCreateTableColumnForeignKey constraint =
    case regexMatches "^(?<constraint>[^ ]+)[ \t]+REFERENCES[ \t]+(?:(?<schema>[^ .]+)\\.)?(?<table>[^ .]+)(?:\\.(?<column>[^ .]+))?$" constraint of
        (Just constraintName) :: (Just table) :: (Just column) :: Nothing :: [] ->
            Ok ( constraintName, { schema = Nothing, table = table, column = Just column } )

        (Just constraintName) :: schema :: (Just table) :: column :: [] ->
            Ok ( constraintName, { schema = schema, table = table, column = column } )

        _ ->
            Err ("Can't parse foreign key: '" ++ constraint ++ "' in create table")


parseAlterTable : RawSql -> Result (List ParseError) TableUpdate
parseAlterTable sql =
    case regexMatches "^ALTER TABLE(?:[ \t]+ONLY)?[ \t]+(?:(?<schema>[^ .]+)\\.)?(?<table>[^ .]+)[ \t]+(?<command>.*);$" sql of
        schema :: (Just table) :: (Just command) :: [] ->
            if command |> String.toUpper |> String.startsWith "ADD CONSTRAINT" then
                parseAlterTableAddConstraint command |> Result.map (AddTableConstraint schema table)

            else if command |> String.toUpper |> String.startsWith "ALTER COLUMN" then
                parseAlterTableAlterColumn command |> Result.map (AlterColumn schema table)

            else if command |> String.toUpper |> String.startsWith "OWNER TO" then
                parseAlterTableOwnerTo command |> Result.map (AddTableOwner schema table)

            else
                Err [ "Command not handled: '" ++ command ++ "'" ]

        _ ->
            Err [ "Can't parse alter table: '" ++ sql ++ "'" ]


parseAlterTableAddConstraint : RawSql -> Result (List ParseError) TableConstraint
parseAlterTableAddConstraint command =
    case regexMatches "^ADD CONSTRAINT[ \t]+(?<name>[^ .]+)[ \t]+(?<constraint>.*)$" command of
        (Just name) :: (Just constraint) :: [] ->
            if constraint |> String.toUpper |> String.startsWith "PRIMARY KEY" then
                parseAlterTableAddConstraintPrimaryKey constraint |> Result.map (ParsedPrimaryKey name)

            else if constraint |> String.toUpper |> String.startsWith "FOREIGN KEY" then
                parseAlterTableAddConstraintForeignKey constraint |> Result.map (ParsedForeignKey name)

            else if constraint |> String.toUpper |> String.startsWith "UNIQUE" then
                parseAlterTableAddConstraintUnique constraint |> Result.map (ParsedUnique name)

            else if constraint |> String.toUpper |> String.startsWith "CHECK" then
                parseAlterTableAddConstraintCheck constraint |> Result.map (ParsedCheck name)

            else
                Err [ "Constraint not handled: '" ++ constraint ++ "'" ]

        _ ->
            Err [ "Can't parse add constraint: '" ++ command ++ "'" ]


parseAlterTableAddConstraintPrimaryKey : RawSql -> Result (List ParseError) PrimaryKeyInner
parseAlterTableAddConstraintPrimaryKey constraint =
    case regexMatches "^PRIMARY KEY[ \t]+\\((?<columns>[^)]+)\\)$" constraint of
        (Just columns) :: [] ->
            Ok (columns |> String.split "," |> List.map String.trim)

        _ ->
            Err [ "Can't parse primary key: '" ++ constraint ++ "'" ]


parseAlterTableAddConstraintForeignKey : RawSql -> Result (List ParseError) ForeignKeyInner
parseAlterTableAddConstraintForeignKey constraint =
    case regexMatches "^FOREIGN KEY[ \t]+\\((?<column>[^)]+)\\)[ \t]+REFERENCES[ \t]+(?:(?<schema_b>[^ .]+)\\.)?(?<table_b>[^ .(]+)(?:[ \t]*\\((?<column_b>[^)]+)\\))?(?:[ \t]+NOT VALID)?$" constraint of
        (Just column) :: schemaDest :: (Just tableDest) :: columnDest :: [] ->
            Ok { column = column, ref = { schema = schemaDest, table = tableDest, column = columnDest } }

        _ ->
            Err [ "Can't parse foreign key: '" ++ constraint ++ "'" ]


parseAlterTableAddConstraintUnique : RawSql -> Result (List ParseError) UniqueInner
parseAlterTableAddConstraintUnique constraint =
    case regexMatches "^UNIQUE[ \t]+(?<definition>.+)$" constraint of
        (Just definition) :: [] ->
            parseIndexDefinition definition |> Result.map (\columns -> { columns = columns, definition = definition })

        _ ->
            Err [ "Can't parse unique constraint: '" ++ constraint ++ "'" ]


parseAlterTableAddConstraintCheck : RawSql -> Result (List ParseError) CheckInner
parseAlterTableAddConstraintCheck constraint =
    case regexMatches "^CHECK[ \t]+(?<predicate>.*)$" constraint of
        (Just predicate) :: [] ->
            Ok predicate

        _ ->
            Err [ "Can't parse check constraint: '" ++ constraint ++ "'" ]


parseAlterTableAlterColumn : RawSql -> Result (List ParseError) ColumnUpdate
parseAlterTableAlterColumn command =
    case regexMatches "^ALTER COLUMN[ \t]+(?<column>[^ .]+)[ \t]+SET[ \t]+(?<property>.+)$" command of
        (Just column) :: (Just property) :: [] ->
            if property |> String.toUpper |> String.startsWith "DEFAULT" then
                parseAlterTableAlterColumnDefault property |> Result.map (ColumnDefault column)

            else if property |> String.toUpper |> String.startsWith "STATISTICS" then
                parseAlterTableAlterColumnStatistics property |> Result.map (ColumnStatistics column)

            else
                Err [ "Column update not handled: '" ++ property ++ "'" ]

        _ ->
            Err [ "Can't parse alter column: '" ++ command ++ "'" ]


parseAlterTableAlterColumnDefault : RawSql -> Result (List ParseError) ColumnValue
parseAlterTableAlterColumnDefault property =
    case regexMatches "^DEFAULT[ \t]+(?<value>.+)$" property of
        (Just value) :: [] ->
            Ok value

        _ ->
            Err [ "Can't parse default value: '" ++ property ++ "'" ]


parseAlterTableAlterColumnStatistics : RawSql -> Result (List ParseError) Int
parseAlterTableAlterColumnStatistics property =
    case regexMatches "^STATISTICS[ \t]+(?<value>[0-9]+)$" property of
        (Just value) :: [] ->
            String.toInt value |> Result.fromMaybe [ "Statistics value is not a number: '" ++ value ++ "'" ]

        _ ->
            Err [ "Can't parse statistics: '" ++ property ++ "'" ]


parseAlterTableOwnerTo : RawSql -> Result (List ParseError) User
parseAlterTableOwnerTo command =
    case regexMatches "^OWNER TO[ \t]+(?<user>.+)$" command of
        (Just user) :: [] ->
            Ok user

        _ ->
            Err [ "Can't parse alter column: '" ++ command ++ "'" ]


parseTableComment : RawSql -> Result (List ParseError) CommentOnTable
parseTableComment sql =
    case regexMatches "^COMMENT ON TABLE[ \t]+(?:(?<schema>[^ .]+)\\.)?(?<table>[^ .]+)[ \t]+IS[ \t]+'(?<comment>(?:[^']|'')+)';$" sql of
        schema :: (Just table) :: (Just comment) :: [] ->
            Ok { schema = schema, table = table, comment = comment |> String.replace "''" "'" }

        _ ->
            Err [ "Can't parse table comment: '" ++ sql ++ "'" ]


parseColumnComment : RawSql -> Result (List ParseError) CommentOnColumn
parseColumnComment sql =
    case regexMatches "^COMMENT ON COLUMN[ \t]+(?:(?<schema>[^ .]+)\\.)?(?<table>[^ .]+)\\.(?<column>[^ .]+)[ \t]+IS[ \t]+'(?<comment>(?:[^']|'')+)';$" sql of
        schema :: (Just table) :: (Just column) :: (Just comment) :: [] ->
            Ok { schema = schema, table = table, column = column, comment = comment |> String.replace "''" "'" }

        _ ->
            Err [ "Can't parse column comment: '" ++ sql ++ "'" ]
