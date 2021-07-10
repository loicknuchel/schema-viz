module SqlParser.Parsers.AlterTable exposing (CheckInner, ColumnUpdate(..), ForeignKeyInner, Predicate, PrimaryKeyInner, SqlUser, TableConstraint(..), TableUpdate(..), UniqueInner, parseAlterTable)

import Libs.Regex as R
import SqlParser.Utils.Helpers exposing (parseIndexDefinition)
import SqlParser.Utils.Types exposing (ConstraintName, ForeignKeyRef, ParseError, RawSql, SqlColumnName, SqlColumnValue, SqlSchemaName, SqlTableName)


type TableUpdate
    = AddTableConstraint (Maybe SqlSchemaName) SqlTableName TableConstraint
    | AlterColumn (Maybe SqlSchemaName) SqlTableName ColumnUpdate
    | AddTableOwner (Maybe SqlSchemaName) SqlTableName SqlUser


type TableConstraint
    = ParsedPrimaryKey ConstraintName PrimaryKeyInner
    | ParsedForeignKey ConstraintName ForeignKeyInner
    | ParsedUnique ConstraintName UniqueInner
    | ParsedCheck ConstraintName CheckInner


type alias PrimaryKeyInner =
    List SqlColumnName


type alias ForeignKeyInner =
    { column : SqlColumnName, ref : ForeignKeyRef }


type alias UniqueInner =
    { columns : List SqlColumnName, definition : String }


type alias CheckInner =
    Predicate


type alias Predicate =
    String


type ColumnUpdate
    = ColumnDefault SqlColumnName SqlColumnValue
    | ColumnStatistics SqlColumnName Int


type alias SqlUser =
    String


parseAlterTable : RawSql -> Result (List ParseError) TableUpdate
parseAlterTable sql =
    case sql |> R.matches "^ALTER TABLE(?:[ \t]+ONLY)?[ \t]+(?:(?<schema>[^ .]+)\\.)?(?<table>[^ .]+)[ \t]+(?<command>.*);$" of
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
    case command |> R.matches "^ADD CONSTRAINT[ \t]+(?<name>[^ .]+)[ \t]+(?<constraint>.*)$" of
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
    case constraint |> R.matches "^PRIMARY KEY[ \t]+\\((?<columns>[^)]+)\\)$" of
        (Just columns) :: [] ->
            Ok (columns |> String.split "," |> List.map String.trim)

        _ ->
            Err [ "Can't parse primary key: '" ++ constraint ++ "'" ]


parseAlterTableAddConstraintForeignKey : RawSql -> Result (List ParseError) ForeignKeyInner
parseAlterTableAddConstraintForeignKey constraint =
    case constraint |> R.matches "^FOREIGN KEY[ \t]+\\((?<column>[^)]+)\\)[ \t]+REFERENCES[ \t]+(?:(?<schema_b>[^ .]+)\\.)?(?<table_b>[^ .(]+)(?:[ \t]*\\((?<column_b>[^)]+)\\))?(?:[ \t]+NOT VALID)?$" of
        (Just column) :: schemaDest :: (Just tableDest) :: columnDest :: [] ->
            Ok { column = column, ref = { schema = schemaDest, table = tableDest, column = columnDest } }

        _ ->
            Err [ "Can't parse foreign key: '" ++ constraint ++ "'" ]


parseAlterTableAddConstraintUnique : RawSql -> Result (List ParseError) UniqueInner
parseAlterTableAddConstraintUnique constraint =
    case constraint |> R.matches "^UNIQUE[ \t]+(?<definition>.+)$" of
        (Just definition) :: [] ->
            parseIndexDefinition definition |> Result.map (\columns -> { columns = columns, definition = definition })

        _ ->
            Err [ "Can't parse unique constraint: '" ++ constraint ++ "'" ]


parseAlterTableAddConstraintCheck : RawSql -> Result (List ParseError) CheckInner
parseAlterTableAddConstraintCheck constraint =
    case constraint |> R.matches "^CHECK[ \t]+(?<predicate>.*)$" of
        (Just predicate) :: [] ->
            Ok predicate

        _ ->
            Err [ "Can't parse check constraint: '" ++ constraint ++ "'" ]


parseAlterTableAlterColumn : RawSql -> Result (List ParseError) ColumnUpdate
parseAlterTableAlterColumn command =
    case command |> R.matches "^ALTER COLUMN[ \t]+(?<column>[^ .]+)[ \t]+SET[ \t]+(?<property>.+)$" of
        (Just column) :: (Just property) :: [] ->
            if property |> String.toUpper |> String.startsWith "DEFAULT" then
                parseAlterTableAlterColumnDefault property |> Result.map (ColumnDefault column)

            else if property |> String.toUpper |> String.startsWith "STATISTICS" then
                parseAlterTableAlterColumnStatistics property |> Result.map (ColumnStatistics column)

            else
                Err [ "Column update not handled: '" ++ property ++ "'" ]

        _ ->
            Err [ "Can't parse alter column: '" ++ command ++ "'" ]


parseAlterTableAlterColumnDefault : RawSql -> Result (List ParseError) SqlColumnValue
parseAlterTableAlterColumnDefault property =
    case property |> R.matches "^DEFAULT[ \t]+(?<value>.+)$" of
        (Just value) :: [] ->
            Ok value

        _ ->
            Err [ "Can't parse default value: '" ++ property ++ "'" ]


parseAlterTableAlterColumnStatistics : RawSql -> Result (List ParseError) Int
parseAlterTableAlterColumnStatistics property =
    case property |> R.matches "^STATISTICS[ \t]+(?<value>[0-9]+)$" of
        (Just value) :: [] ->
            String.toInt value |> Result.fromMaybe [ "Statistics value is not a number: '" ++ value ++ "'" ]

        _ ->
            Err [ "Can't parse statistics: '" ++ property ++ "'" ]


parseAlterTableOwnerTo : RawSql -> Result (List ParseError) SqlUser
parseAlterTableOwnerTo command =
    case command |> R.matches "^OWNER TO[ \t]+(?<user>.+)$" of
        (Just user) :: [] ->
            Ok user

        _ ->
            Err [ "Can't parse alter column: '" ++ command ++ "'" ]
