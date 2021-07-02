module SqlParser.SqlParser exposing (ColumnUpdate(..), Statement(..), TableConstraint(..), TableUpdate(..), commaSplit, parseAlterTable, parseColumnComment, parseCreateTable, parseCreateTableColumn, parseStatement, parseTableComment)

import Libs.Std exposing (listResultSeq)
import Regex


type alias RawSql =
    String


type alias ParseError =
    String


type Statement
    = CreateTable Table
    | AlterTable TableUpdate
    | TableComment CommentOnTable
    | ColumnComment CommentOnColumn


type alias SchemaName =
    String


type alias TableName =
    String


type alias ColumnName =
    String


type alias ColumnType =
    String


type alias ColumnValue =
    String


type alias Table =
    { schema : SchemaName, table : TableName, columns : List Column }


type alias Column =
    { name : ColumnName, kind : ColumnType, nullable : Bool, default : Maybe ColumnValue }


type TableUpdate
    = AddTableConstraint SchemaName TableName TableConstraint
    | AlterColumn SchemaName TableName ColumnUpdate


type alias ConstraintName =
    String


type TableConstraint
    = PrimaryKey ConstraintName PrimaryKeyInner
    | ForeignKey ConstraintName ForeignKeyInner
    | Unique ConstraintName UniqueInner
    | Check ConstraintName CheckInner


type alias PrimaryKeyInner =
    List ColumnName


type alias ForeignKeyInner =
    { column : ColumnName, schemaDest : SchemaName, tableDest : TableName, columnDest : ColumnName }


type alias UniqueInner =
    List ColumnName


type alias Predicate =
    String


type alias CheckInner =
    Predicate


type ColumnUpdate
    = ColumnDefault ColumnName ColumnValue
    | ColumnStatistics ColumnName Int


type alias Comment =
    String


type alias CommentOnTable =
    { schema : SchemaName, table : TableName, comment : Comment }


type alias CommentOnColumn =
    { schema : SchemaName, table : TableName, column : ColumnName, comment : Comment }


parseStatement : RawSql -> Result (List ParseError) Statement
parseStatement sql =
    if String.startsWith "CREATE TABLE " sql then
        parseCreateTable sql |> Result.map CreateTable

    else if String.startsWith "ALTER TABLE " sql then
        parseAlterTable sql |> Result.map AlterTable

    else if String.startsWith "COMMENT ON TABLE " sql then
        parseTableComment sql |> Result.map TableComment

    else if String.startsWith "COMMENT ON COLUMN " sql then
        parseColumnComment sql |> Result.map ColumnComment

    else
        Err [ "Statement not handled: '" ++ sql ++ "'" ]


parseCreateTable : RawSql -> Result (List ParseError) Table
parseCreateTable sql =
    case regexMatches "^CREATE TABLE (?<schema>[^ .]+)\\.(?<table>[^ .]+) \\((?<body>[^;]+?)\\)(?: WITH \\((?<options>.*?)\\))?;$" sql of
        (Just schema) :: (Just table) :: (Just columns) :: _ :: [] ->
            commaSplit columns
                |> List.map String.trim
                |> List.filter (\c -> not (String.startsWith "CONSTRAINT" c))
                |> List.map parseCreateTableColumn
                |> listResultSeq
                |> Result.map (\c -> { schema = schema, table = table, columns = c })

        _ ->
            Err [ "Can't parse table: '" ++ sql ++ "'" ]


parseCreateTableColumn : RawSql -> Result ParseError Column
parseCreateTableColumn sql =
    case regexMatches "^(?<name>[^ ]+) (?<type>.*?)(?: DEFAULT (?<default>.*?))?(?<nullable> NOT NULL)?$" sql of
        (Just name) :: (Just kind) :: default :: nullable :: [] ->
            Ok { name = name |> noEnclosingQuotes, kind = kind, nullable = nullable == Nothing, default = default }

        _ ->
            Err ("Can't parse column: '" ++ sql ++ "'")


parseAlterTable : RawSql -> Result (List ParseError) TableUpdate
parseAlterTable sql =
    case regexMatches "^ALTER TABLE (?:ONLY )?(?<schema>[^ .]+)\\.(?<table>[^ .]+) (?<command>.*);$" sql of
        (Just schema) :: (Just table) :: (Just command) :: [] ->
            if String.startsWith "ADD CONSTRAINT" command then
                parseAlterTableAddConstraint command |> Result.map (AddTableConstraint schema table)

            else if String.startsWith "ALTER COLUMN" command then
                parseAlterTableAlterColumn command |> Result.map (AlterColumn schema table)

            else
                Err [ "Command not handled in: '" ++ command ++ "'" ]

        _ ->
            Err [ "Can't parse alter table: '" ++ sql ++ "'" ]


parseAlterTableAddConstraint : RawSql -> Result (List ParseError) TableConstraint
parseAlterTableAddConstraint command =
    case regexMatches "^ADD CONSTRAINT (?<name>[^ .]+) (?<constraint>.*)$" command of
        (Just name) :: (Just constraint) :: [] ->
            if String.startsWith "PRIMARY KEY" constraint then
                parseAlterTableAddConstraintPrimaryKey constraint |> Result.map (PrimaryKey name)

            else if String.startsWith "FOREIGN KEY" constraint then
                parseAlterTableAddConstraintForeignKey constraint |> Result.map (ForeignKey name)

            else if String.startsWith "UNIQUE" constraint then
                parseAlterTableAddConstraintUnique constraint |> Result.map (Unique name)

            else if String.startsWith "CHECK" constraint then
                parseAlterTableAddConstraintCheck constraint |> Result.map (Check name)

            else
                Err [ "Constraint not handled in: '" ++ constraint ++ "'" ]

        _ ->
            Err [ "Can't parse add constraint: '" ++ command ++ "'" ]


parseAlterTableAddConstraintPrimaryKey : RawSql -> Result (List ParseError) PrimaryKeyInner
parseAlterTableAddConstraintPrimaryKey constraint =
    case regexMatches "^PRIMARY KEY \\((?<columns>[^)]+)\\)$" constraint of
        (Just columns) :: [] ->
            Ok (columns |> String.split "," |> List.map String.trim)

        _ ->
            Err [ "Can't parse primary key: '" ++ constraint ++ "'" ]


parseAlterTableAddConstraintForeignKey : RawSql -> Result (List ParseError) ForeignKeyInner
parseAlterTableAddConstraintForeignKey constraint =
    case regexMatches "^FOREIGN KEY \\((?<column>[^)]+)\\) REFERENCES (?<schema_b>[^ .]+)\\.(?<table_b>[^ .]+) ?\\((?<column_b>[^)]+)\\)$" constraint of
        (Just column) :: (Just schemaDest) :: (Just tableDest) :: (Just columnDest) :: [] ->
            Ok { column = column, schemaDest = schemaDest, tableDest = tableDest, columnDest = columnDest }

        _ ->
            Err [ "Can't parse foreign key: '" ++ constraint ++ "'" ]


parseAlterTableAddConstraintUnique : RawSql -> Result (List ParseError) UniqueInner
parseAlterTableAddConstraintUnique constraint =
    case regexMatches "^UNIQUE \\((?<columns>[^)]+)\\)$" constraint of
        (Just columns) :: [] ->
            Ok (columns |> String.split "," |> List.map String.trim)

        _ ->
            Err [ "Can't parse unique constraint: '" ++ constraint ++ "'" ]


parseAlterTableAddConstraintCheck : RawSql -> Result (List ParseError) CheckInner
parseAlterTableAddConstraintCheck constraint =
    case regexMatches "^CHECK (?<predicate>.*)$" constraint of
        (Just predicate) :: [] ->
            Ok predicate

        _ ->
            Err [ "Can't parse check constraint: '" ++ constraint ++ "'" ]


parseAlterTableAlterColumn : RawSql -> Result (List ParseError) ColumnUpdate
parseAlterTableAlterColumn command =
    case regexMatches "^ALTER COLUMN (?<column>[^ .]+) SET (?<property>.+)$" command of
        (Just column) :: (Just property) :: [] ->
            if String.startsWith "DEFAULT" property then
                parseAlterTableAlterColumnDefault property |> Result.map (ColumnDefault column)

            else if String.startsWith "STATISTICS" property then
                parseAlterTableAlterColumnStatistics property |> Result.map (ColumnStatistics column)

            else
                Err [ "Column update not handled in: '" ++ property ++ "'" ]

        _ ->
            Err [ "Can't parse alter column: '" ++ command ++ "'" ]


parseAlterTableAlterColumnDefault : RawSql -> Result (List ParseError) ColumnValue
parseAlterTableAlterColumnDefault property =
    case regexMatches "^DEFAULT (?<value>.+)$" property of
        (Just value) :: [] ->
            Ok value

        _ ->
            Err [ "Can't parse default value: '" ++ property ++ "'" ]


parseAlterTableAlterColumnStatistics : RawSql -> Result (List ParseError) Int
parseAlterTableAlterColumnStatistics property =
    case regexMatches "^STATISTICS (?<value>[0-9]+)$" property of
        (Just value) :: [] ->
            String.toInt value |> Result.fromMaybe [ "Statistics value is not a number: '" ++ value ++ "'" ]

        _ ->
            Err [ "Can't parse statistics: '" ++ property ++ "'" ]


parseTableComment : RawSql -> Result (List ParseError) CommentOnTable
parseTableComment sql =
    case regexMatches "^COMMENT ON TABLE (?<schema>[^ .]+)\\.(?<table>[^ .]+) IS '(?<comment>(?:[^']|'')+)';$" sql of
        (Just schema) :: (Just table) :: (Just comment) :: [] ->
            Ok { schema = schema, table = table, comment = comment |> String.replace "''" "'" }

        _ ->
            Err [ "Can't parse table comment: '" ++ sql ++ "'" ]


parseColumnComment : RawSql -> Result (List ParseError) CommentOnColumn
parseColumnComment sql =
    case regexMatches "^COMMENT ON COLUMN (?<schema>[^ .]+)\\.(?<table>[^ .]+)\\.(?<column>[^ .]+) IS '(?<comment>(?:[^']|'')+)';$" sql of
        (Just schema) :: (Just table) :: (Just column) :: (Just comment) :: [] ->
            Ok { schema = schema, table = table, column = column, comment = comment |> String.replace "''" "'" }

        _ ->
            Err [ "Can't parse column comment: '" ++ sql ++ "'" ]


commaSplit : String -> List String
commaSplit text =
    String.foldr
        (\char ( res, cur, open ) ->
            if char == ',' && open == 0 then
                ( (cur |> String.fromList) :: res, [], open )

            else if char == '(' then
                ( res, char :: cur, open + 1 )

            else if char == ')' then
                ( res, char :: cur, open - 1 )

            else
                ( res, char :: cur, open )
        )
        ( [], [], 0 )
        text
        |> (\( res, end, _ ) -> (end |> String.fromList) :: res)


noEnclosingQuotes : String -> String
noEnclosingQuotes text =
    case regexMatches "\"(.*)\"" text of
        (Just res) :: [] ->
            res

        _ ->
            text


regexMatches : String -> String -> List (Maybe String)
regexMatches regex text =
    Regex.fromString regex
        |> Maybe.withDefault Regex.never
        |> (\r -> Regex.find r text)
        |> List.concatMap .submatches
