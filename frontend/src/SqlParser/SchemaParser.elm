module SqlParser.SchemaParser exposing (Line, SchemaError, SqlCheck, SqlColumn, SqlForeignKey, SqlPrimaryKey, SqlSchema, SqlTable, SqlTableId, SqlUnique, Statement, buildRawSql, buildStatements, parseLines, parseSchema, updateColumn, updateTable)

import AssocList as Dict exposing (Dict)
import Libs.Std exposing (listFind)
import Models.Utils exposing (FileContent, FileName)
import SqlParser.SqlParser exposing (ColumnName, ColumnType, ColumnUpdate(..), ColumnValue, Command(..), Comment, ConstraintName, ParsedColumn, ParsedTable, Predicate, RawSql, SchemaName, TableConstraint(..), TableName, TableUpdate(..), parseCommand)


type alias SchemaError =
    String


type alias Line =
    { file : String, line : Int, text : String }


type alias Statement =
    { first : Line, others : List Line }


type alias SqlSchema =
    Dict SqlTableId SqlTable


type alias SqlTableId =
    String


type alias SqlTable =
    { schema : SchemaName, table : TableName, columns : List SqlColumn, primaryKey : Maybe SqlPrimaryKey, uniques : List SqlUnique, checks : List SqlCheck, comment : Maybe Comment }


type alias SqlColumn =
    { name : ColumnName, kind : ColumnType, nullable : Bool, default : Maybe ColumnValue, foreignKey : Maybe SqlForeignKey, comment : Maybe Comment }


type alias SqlPrimaryKey =
    { name : ConstraintName, columns : List ColumnName }


type alias SqlForeignKey =
    { name : ConstraintName, schema : SchemaName, table : TableName, column : ColumnName }


type alias SqlUnique =
    { name : ConstraintName, columns : List ColumnName }


type alias SqlCheck =
    { name : ConstraintName, predicate : Predicate }


parseSchema : FileName -> FileContent -> Result (List SchemaError) SqlSchema
parseSchema fileName fileContent =
    parseLines fileName fileContent
        |> buildStatements
        |> List.foldl
            (\statement ( errs, schema ) ->
                case statement |> buildRawSql |> parseCommand |> Result.andThen (\command -> schema |> evolve command) of
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


evolve : Command -> SqlSchema -> Result (List SchemaError) SqlSchema
evolve command tables =
    case command of
        CreateTable table ->
            let
                id : SqlTableId
                id =
                    buildId table.schema table.table
            in
            tables
                |> Dict.get id
                |> Maybe.map (\_ -> Err [ "Table " ++ id ++ " already exists" ])
                |> Maybe.withDefault (Ok (tables |> Dict.insert id (buildTable table)))

        AlterTable (AddTableConstraint schema table (ParsedPrimaryKey constraint pk)) ->
            updateTable (buildId schema table) (\t -> Ok { t | primaryKey = Just { name = constraint, columns = pk } }) tables

        AlterTable (AddTableConstraint schema table (ParsedForeignKey constraint fk)) ->
            updateColumn (buildId schema table) fk.column (\c -> Ok { c | foreignKey = Just { name = constraint, schema = fk.schemaDest, table = fk.tableDest, column = fk.columnDest } }) tables

        AlterTable (AddTableConstraint schema table (ParsedUnique constraint unique)) ->
            updateTable (buildId schema table) (\t -> Ok { t | uniques = t.uniques ++ [ { name = constraint, columns = unique } ] }) tables

        AlterTable (AddTableConstraint schema table (ParsedCheck constraint check)) ->
            updateTable (buildId schema table) (\t -> Ok { t | checks = t.checks ++ [ { name = constraint, predicate = check } ] }) tables

        AlterTable (AlterColumn schema table (ColumnDefault column default)) ->
            updateColumn (buildId schema table) column (\c -> Ok { c | default = Just default }) tables

        AlterTable (AlterColumn _ _ (ColumnStatistics _ _)) ->
            Ok tables

        TableComment comment ->
            updateTable (buildId comment.schema comment.table) (\table -> Ok { table | comment = Just comment.comment }) tables

        ColumnComment comment ->
            updateColumn (buildId comment.schema comment.table) comment.column (\column -> Ok { column | comment = Just comment.comment }) tables

        Ignored _ ->
            Ok tables


updateTable : SqlTableId -> (SqlTable -> Result (List SchemaError) SqlTable) -> SqlSchema -> Result (List SchemaError) SqlSchema
updateTable id transform tables =
    tables
        |> Dict.get id
        |> Maybe.map (\table -> transform table |> Result.map (\newTable -> tables |> Dict.update id (Maybe.map (\_ -> newTable))))
        |> Maybe.withDefault (Err [ "Table " ++ id ++ " does not exist" ])


updateColumn : SqlTableId -> ColumnName -> (SqlColumn -> Result (List SchemaError) SqlColumn) -> SqlSchema -> Result (List SchemaError) SqlSchema
updateColumn id name transform tables =
    updateTable id
        (\table ->
            table.columns
                |> listFind (\column -> column.name == name)
                |> Maybe.map (\column -> transform column |> Result.map (\newColumn -> updateTableColumn name (\_ -> newColumn) table))
                |> Maybe.withDefault (Err [ "Column " ++ name ++ " does not exist in table " ++ id ])
        )
        tables


updateTableColumn : ColumnName -> (SqlColumn -> SqlColumn) -> SqlTable -> SqlTable
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


buildTable : ParsedTable -> SqlTable
buildTable table =
    { schema = table.schema, table = table.table, columns = table.columns |> List.map buildColumn, primaryKey = Nothing, uniques = [], checks = [], comment = Nothing }


buildColumn : ParsedColumn -> SqlColumn
buildColumn column =
    { name = column.name, kind = column.kind, nullable = column.nullable, default = column.default, foreignKey = Nothing, comment = Nothing }


buildId : SchemaName -> TableName -> SqlTableId
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
            (\line ( currentStatementLines, statements, nestedBlock ) ->
                if (line.text |> String.endsWith ";") && nestedBlock == 0 then
                    ( line :: [], addStatement currentStatementLines statements, nestedBlock )

                else if String.trim line.text == "BEGIN" then
                    ( line :: currentStatementLines, statements, nestedBlock + 1 )

                else if String.trim line.text == "END" then
                    ( line :: currentStatementLines, statements, nestedBlock - 1 )

                else
                    ( line :: currentStatementLines, statements, nestedBlock )
            )
            ( [], [], 0 )
        |> (\( cur, res, _ ) -> addStatement cur res)


addStatement : List Line -> List Statement -> List Statement
addStatement lines statements =
    case lines of
        [] ->
            statements

        head :: tail ->
            { first = head, others = tail } :: statements


parseLines : FileName -> FileContent -> List Line
parseLines fileName fileContent =
    fileContent
        |> String.split "\n"
        |> List.indexedMap (\i line -> { file = fileName, line = i + 1, text = line })
