module PagesComponents.App.Updates.FindPathTest exposing (..)

import Dict exposing (Dict)
import Expect
import Libs.Dict as D
import Libs.Ned as Ned
import Libs.Nel as Nel exposing (Nel)
import Models.FindPath as FindPath
import Models.Project exposing (Column, ColumnName, ColumnRef, Relation, Table, TableId, TableName)
import PagesComponents.App.Updates.FindPath exposing (computeFindPath)
import Test exposing (Test, describe, test)


suite : Test
suite =
    describe "PagesComponents.App.Updates.FindPath"
        [ describe "computeFindPath"
            [ test "empty" (\_ -> computeFindPath basicTables [] (tableId "users") (tableId "roles") |> .paths |> Expect.equal [])
            , test "same from & to" (\_ -> computeFindPath basicTables [] (tableId "users") (tableId "users") |> .paths |> Expect.equal [])
            , test "basic"
                (\_ ->
                    computeFindPath basicTables basicRelations (tableId "users") (tableId "roles")
                        |> .paths
                        |> Expect.equal [ Nel (FindPath.Step roleUserToUsers FindPath.Left) [ FindPath.Step roleUserToRoles FindPath.Right ] ]
                )
            , test "with cycle"
                (\_ ->
                    computeFindPath basicTables (rolesToUsers :: basicRelations) (tableId "users") (tableId "roles")
                        |> .paths
                        |> Expect.equal
                            [ Nel (FindPath.Step rolesToUsers FindPath.Left) []
                            , Nel (FindPath.Step roleUserToUsers FindPath.Left) [ FindPath.Step roleUserToRoles FindPath.Right ]
                            ]
                )
            ]
        ]


basicTables : Dict TableId Table
basicTables =
    [ usersTable, rolesTable, roleUserTable, credentialsTable ] |> D.fromListMap .id


basicRelations : List Relation
basicRelations =
    [ roleUserToUsers, roleUserToRoles, credentialsToUsers ]


usersTable : Table
usersTable =
    buildTable "users" [ "id" ]


rolesTable : Table
rolesTable =
    buildTable "roles" [ "id", "by" ]


roleUserTable : Table
roleUserTable =
    buildTable "role_user" [ "id", "role_id", "user_id" ]


credentialsTable : Table
credentialsTable =
    buildTable "credentials" [ "user_id" ]


roleUserToUsers : Relation
roleUserToUsers =
    buildRelation ( "role_user", "user_id" ) ( "users", "id" )


roleUserToRoles : Relation
roleUserToRoles =
    buildRelation ( "role_user", "role_id" ) ( "roles", "id" )


credentialsToUsers : Relation
credentialsToUsers =
    buildRelation ( "credentials", "user_id" ) ( "users", "id" )


rolesToUsers : Relation
rolesToUsers =
    buildRelation ( "roles", "by" ) ( "users", "id" )


tableId : TableName -> TableId
tableId name =
    ( "public", name )


buildTable : TableName -> List String -> Table
buildTable name columnNames =
    Table (tableId name) "public" name (columnNames |> Nel.fromList |> Maybe.withDefault (Nel "id" []) |> Nel.map buildColumn |> Ned.fromNelMap .name) Nothing [] [] [] Nothing []


buildColumn : ColumnName -> Column
buildColumn name =
    Column 0 name "int" False Nothing Nothing []


buildRelation : ( TableName, ColumnName ) -> ( TableName, ColumnName ) -> Relation
buildRelation ( fromTable, fromCol ) ( toTable, toCol ) =
    Relation "" (ColumnRef (tableId fromTable) fromCol) (ColumnRef (tableId toTable) toCol) []
