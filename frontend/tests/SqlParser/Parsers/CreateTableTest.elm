module SqlParser.Parsers.CreateTableTest exposing (..)

import Expect
import SqlParser.Parsers.CreateTable exposing (parseCreateTable, parseCreateTableColumn)
import Test exposing (Test, describe, test)


suite : Test
suite =
    describe "CreateTable"
        [ describe "parseCreateTable"
            [ test "basic" (\_ -> parseCreateTable "CREATE TABLE aaa.bbb (ccc int);" |> Expect.equal (Ok { schema = Just "aaa", table = "bbb", columns = [ { name = "ccc", kind = "int", nullable = True, default = Nothing, primaryKey = Nothing, foreignKey = Nothing } ] }))
            , test "complex"
                (\_ ->
                    parseCreateTable
                        "CREATE TABLE public.users (id bigint NOT NULL, name character varying(255), price numeric(8,2)) WITH (autovacuum_enabled='false');"
                        |> Expect.equal
                            (Ok
                                { schema = Just "public"
                                , table = "users"
                                , columns =
                                    [ { name = "id", kind = "bigint", nullable = False, default = Nothing, primaryKey = Nothing, foreignKey = Nothing }
                                    , { name = "name", kind = "character varying(255)", nullable = True, default = Nothing, primaryKey = Nothing, foreignKey = Nothing }
                                    , { name = "price", kind = "numeric(8,2)", nullable = True, default = Nothing, primaryKey = Nothing, foreignKey = Nothing }
                                    ]
                                }
                            )
                )
            , test "with options"
                (\_ ->
                    parseCreateTable "CREATE TABLE p.table (id bigint NOT NULL)    WITH (autovacuum_analyze_threshold='100000');"
                        |> Expect.equal
                            (Ok { schema = Just "p", table = "table", columns = [ { name = "id", kind = "bigint", nullable = False, default = Nothing, primaryKey = Nothing, foreignKey = Nothing } ] })
                )
            , test "without schema, lowercase and no space before body"
                (\_ ->
                    parseCreateTable "create table migrations(version varchar not null);"
                        |> Expect.equal (Ok { schema = Nothing, table = "migrations", columns = [ { name = "version", kind = "varchar", nullable = False, default = Nothing, primaryKey = Nothing, foreignKey = Nothing } ] })
                )
            , test "bad" (\_ -> parseCreateTable "bad" |> Expect.equal (Err [ "Can't parse table: 'bad'" ]))
            ]
        , describe "parseCreateTableColumn"
            [ test "basic"
                (\_ ->
                    parseCreateTableColumn "id bigint NOT NULL"
                        |> Expect.equal (Ok { name = "id", kind = "bigint", nullable = False, default = Nothing, primaryKey = Nothing, foreignKey = Nothing })
                )
            , test "nullable"
                (\_ ->
                    parseCreateTableColumn "id bigint"
                        |> Expect.equal (Ok { name = "id", kind = "bigint", nullable = True, default = Nothing, primaryKey = Nothing, foreignKey = Nothing })
                )
            , test "with default"
                (\_ ->
                    parseCreateTableColumn "status character varying(255) DEFAULT 'done'::character varying"
                        |> Expect.equal (Ok { name = "status", kind = "character varying(255)", nullable = True, default = Just "'done'::character varying", primaryKey = Nothing, foreignKey = Nothing })
                )
            , test "with comma in type"
                (\_ ->
                    parseCreateTableColumn "price numeric(8,2)"
                        |> Expect.equal (Ok { name = "price", kind = "numeric(8,2)", nullable = True, default = Nothing, primaryKey = Nothing, foreignKey = Nothing })
                )
            , test "with enclosing quotes"
                (\_ ->
                    parseCreateTableColumn "\"id\" bigint"
                        |> Expect.equal (Ok { name = "id", kind = "bigint", nullable = True, default = Nothing, primaryKey = Nothing, foreignKey = Nothing })
                )
            , test "with primary key"
                (\_ ->
                    parseCreateTableColumn "id bigint NOT NULL CONSTRAINT users_pk PRIMARY KEY"
                        |> Expect.equal (Ok { name = "id", kind = "bigint", nullable = False, default = Nothing, primaryKey = Just "users_pk", foreignKey = Nothing })
                )
            , test "with foreign key having schema, table & column"
                (\_ ->
                    parseCreateTableColumn "user_id bigint CONSTRAINT users_fk REFERENCES public.users.id"
                        |> Expect.equal (Ok { name = "user_id", kind = "bigint", nullable = True, default = Nothing, primaryKey = Nothing, foreignKey = Just ( "users_fk", { schema = Just "public", table = "users", column = Just "id" } ) })
                )
            , test "with foreign key having table & column"
                (\_ ->
                    parseCreateTableColumn "user_id bigint CONSTRAINT users_fk REFERENCES users.id"
                        |> Expect.equal (Ok { name = "user_id", kind = "bigint", nullable = True, default = Nothing, primaryKey = Nothing, foreignKey = Just ( "users_fk", { schema = Nothing, table = "users", column = Just "id" } ) })
                )
            , test "with foreign key having only table"
                (\_ ->
                    parseCreateTableColumn "user_id bigint CONSTRAINT users_fk REFERENCES users"
                        |> Expect.equal (Ok { name = "user_id", kind = "bigint", nullable = True, default = Nothing, primaryKey = Nothing, foreignKey = Just ( "users_fk", { schema = Nothing, table = "users", column = Nothing } ) })
                )
            , test "bad" (\_ -> parseCreateTableColumn "bad" |> Expect.equal (Err "Can't parse column: 'bad'"))
            ]
        ]
