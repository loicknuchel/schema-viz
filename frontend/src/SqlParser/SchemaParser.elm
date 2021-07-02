module SqlParser.SchemaParser exposing (Error, Line, Statement, Tables, buildRawSql, buildStatements, parseLines, parseSchema)

import AssocList as Dict exposing (Dict)
import Libs.Std exposing (listFind)
import SqlParser.SqlParser as SqlParser exposing (ColumnName, ColumnType, ColumnUpdate(..), ColumnValue, Command(..), Comment, ConstraintName, Predicate, RawSql, SchemaName, TableConstraint(..), TableName, TableUpdate(..), parseCommand)


type alias Error =
    String


type alias Line =
    { file : String, line : Int, text : String }


type alias Statement =
    { first : Line, others : List Line }


type alias Tables =
    Dict TableId Table


type alias TableId =
    String


type alias Table =
    { schema : SchemaName, table : TableName, columns : List Column, primaryKey : Maybe PrimaryKey, uniques : List Unique, checks : List Check, comment : Maybe Comment }


type alias Column =
    { name : ColumnName, kind : ColumnType, nullable : Bool, default : Maybe ColumnValue, foreignKey : Maybe ForeignKey, comment : Maybe Comment }


type alias PrimaryKey =
    { name : ConstraintName, columns : List ColumnName }


type alias ForeignKey =
    { name : ConstraintName, schema : SchemaName, table : TableName, column : ColumnName }


type alias Unique =
    { name : ConstraintName, columns : List ColumnName }


type alias Check =
    { name : ConstraintName, predicate : Predicate }


parseSchema : String -> String -> Result (List Error) Tables
parseSchema fileName fileContent =
    parseLines fileName fileContent
        |> buildStatements
        |> List.foldl
            (\statement ( errs, schema ) ->
                case statement |> buildRawSql |> parseCommand |> Result.andThen (evolve schema) of
                    Ok newSchema ->
                        ( errs, newSchema )

                    Err e ->
                        ( errs ++ e, schema )
            )
            ( [], Dict.empty )
        |> (\( errs, schema ) ->
                if List.isEmpty errs then
                    Ok schema

                else
                    Err errs
           )


evolve : Tables -> Command -> Result (List Error) Tables
evolve tables command =
    case command of
        CreateTable table ->
            let
                id : TableId
                id =
                    buildId table.schema table.table
            in
            tables
                |> Dict.get id
                |> Maybe.map (\_ -> Err [ "Table " ++ id ++ " already exists" ])
                |> Maybe.withDefault (Ok (tables |> Dict.insert id (buildTable table)))

        AlterTable (AddTableConstraint schema table (SqlParser.PrimaryKey constraint pk)) ->
            updateTable (buildId schema table) (\t -> Ok { t | primaryKey = Just { name = constraint, columns = pk } }) tables

        AlterTable (AddTableConstraint schema table (SqlParser.ForeignKey constraint fk)) ->
            updateColumn (buildId schema table) fk.column (\c -> Ok { c | foreignKey = Just { name = constraint, schema = fk.schemaDest, table = fk.tableDest, column = fk.columnDest } }) tables

        AlterTable (AddTableConstraint schema table (SqlParser.Unique constraint unique)) ->
            updateTable (buildId schema table) (\t -> Ok { t | uniques = t.uniques ++ [ { name = constraint, columns = unique } ] }) tables

        AlterTable (AddTableConstraint schema table (SqlParser.Check constraint check)) ->
            updateTable (buildId schema table) (\t -> Ok { t | checks = t.checks ++ [ { name = constraint, predicate = check } ] }) tables

        AlterTable (AlterColumn schema table (ColumnDefault column default)) ->
            updateColumn (buildId schema table) column (\c -> Ok { c | default = Just default }) tables

        AlterTable (AlterColumn _ _ (ColumnStatistics _ _)) ->
            Ok tables

        TableComment comment ->
            updateTable (buildId comment.schema comment.table) (\table -> Ok { table | comment = Just comment.comment }) tables

        ColumnComment comment ->
            updateColumn (buildId comment.schema comment.table) comment.column (\column -> Ok { column | comment = Just comment.comment }) tables


updateTable : TableId -> (Table -> Result (List Error) Table) -> Tables -> Result (List Error) Tables
updateTable id transform tables =
    tables
        |> Dict.get id
        |> Maybe.map (\table -> transform table |> Result.map (\newTable -> tables |> Dict.update id (Maybe.map (\_ -> newTable))))
        |> Maybe.withDefault (Err [ "Table " ++ id ++ " does not exist" ])


updateColumn : TableId -> ColumnName -> (Column -> Result (List Error) Column) -> Tables -> Result (List Error) Tables
updateColumn id name transform tables =
    updateTable id
        (\table ->
            table.columns
                |> listFind (\column -> column.name == name)
                |> Maybe.map (\column -> transform column |> Result.map (\newColumn -> updateTableColumn name (\_ -> newColumn) table))
                |> Maybe.withDefault (Err [ "Column " ++ name ++ " does not exist in table " ++ id ])
        )
        tables


updateTableColumn : ColumnName -> (Column -> Column) -> Table -> Table
updateTableColumn column transform table =
    { table
        | columns =
            table.columns
                |> List.map
                    (\c ->
                        if c.name == column then
                            transform c

                        else
                            c
                    )
    }


buildTable : SqlParser.Table -> Table
buildTable table =
    { schema = table.schema, table = table.table, columns = table.columns |> List.map buildColumn, primaryKey = Nothing, uniques = [], checks = [], comment = Nothing }


buildColumn : SqlParser.Column -> Column
buildColumn column =
    { name = column.name, kind = column.kind, nullable = column.nullable, default = column.default, foreignKey = Nothing, comment = Nothing }


buildId : SchemaName -> TableName -> TableId
buildId schema table =
    schema ++ "." ++ table


buildRawSql : Statement -> RawSql
buildRawSql statement =
    statement.first :: statement.others |> List.map .text |> String.join " "


buildStatements : List Line -> List Statement
buildStatements lines =
    lines
        |> List.filter (\line -> not (String.isEmpty (String.trim line.text) || String.startsWith "--" line.text))
        |> List.foldr
            (\line ( currentStatementLines, statements ) ->
                if line.text |> String.endsWith ";" then
                    ( line :: [], addStatement currentStatementLines statements )

                else
                    ( line :: currentStatementLines, statements )
            )
            ( [], [] )
        |> (\( cur, res ) -> addStatement cur res)


addStatement : List Line -> List Statement -> List Statement
addStatement lines statements =
    case lines of
        [] ->
            statements

        head :: tail ->
            { first = head, others = tail } :: statements


parseLines : String -> String -> List Line
parseLines fileName fileContent =
    fileContent
        |> String.split "\n"
        |> List.indexedMap (\i line -> { file = fileName, line = i + 1, text = line })
