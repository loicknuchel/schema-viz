module SqlParser.SqlParserTest exposing (..)

import Expect
import SqlParser.SqlParser exposing (ColumnUpdate(..), Command(..), TableConstraint(..), TableUpdate(..), commaSplit, parseAlterTable, parseColumnComment, parseCommand, parseCreateTable, parseCreateTableColumn, parseTableComment)
import Test exposing (Test, describe, test)


suite : Test
suite =
    describe "SqlParser"
        [ describe "parseCommand"
            [ test "parse create table" (\_ -> parseCommand "CREATE TABLE aaa.bbb (ccc int);" |> Expect.equal (Ok (CreateTable { schema = Just "aaa", table = "bbb", columns = [ { name = "ccc", kind = "int", nullable = True, default = Nothing, primaryKey = Nothing, foreignKey = Nothing } ] })))
            , test "parse alter table" (\_ -> parseCommand "ALTER TABLE ONLY public.t2 ADD CONSTRAINT t2_id_pkey PRIMARY KEY (id);" |> Expect.equal (Ok (AlterTable (AddTableConstraint (Just "public") "t2" (ParsedPrimaryKey "t2_id_pkey" [ "id" ])))))
            , test "parse table comment" (\_ -> parseCommand "COMMENT ON TABLE public.table1 IS 'A comment';" |> Expect.equal (Ok (TableComment { schema = Just "public", table = "table1", comment = "A comment" })))
            , test "parse column comment" (\_ -> parseCommand "COMMENT ON COLUMN public.table1.col IS 'A comment';" |> Expect.equal (Ok (ColumnComment { schema = Just "public", table = "table1", column = "col", comment = "A comment" })))
            , test "parse lowercase" (\_ -> parseCommand "comment on column public.table1.col is 'A comment';" |> Expect.equal (Ok (ColumnComment { schema = Just "public", table = "table1", column = "col", comment = "A comment" })))
            ]
        , describe "parseCreateTable"
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
        , describe "parseAlterTable"
            [ test "primary key" (\_ -> parseAlterTable "ALTER TABLE public.t2 ADD CONSTRAINT t2_id_pkey PRIMARY KEY (id);" |> Expect.equal (Ok (AddTableConstraint (Just "public") "t2" (ParsedPrimaryKey "t2_id_pkey" [ "id" ]))))
            , test "foreign key" (\_ -> parseAlterTable "ALTER TABLE p.t2 ADD CONSTRAINT t2_t1_id_fk FOREIGN KEY (t1_id) REFERENCES p.t1 (id);" |> Expect.equal (Ok (AddTableConstraint (Just "p") "t2" (ParsedForeignKey "t2_t1_id_fk" { column = "t1_id", ref = { schema = Just "p", table = "t1", column = Just "id" } }))))
            , test "foreign key without schema" (\_ -> parseAlterTable "ALTER TABLE p.t2 ADD CONSTRAINT t2_t1_id_fk FOREIGN KEY (t1_id) REFERENCES t1 (id);" |> Expect.equal (Ok (AddTableConstraint (Just "p") "t2" (ParsedForeignKey "t2_t1_id_fk" { column = "t1_id", ref = { schema = Nothing, table = "t1", column = Just "id" } }))))
            , test "foreign key without column" (\_ -> parseAlterTable "ALTER TABLE p.t2 ADD CONSTRAINT t2_t1_id_fk FOREIGN KEY (t1_id) REFERENCES p.t1;" |> Expect.equal (Ok (AddTableConstraint (Just "p") "t2" (ParsedForeignKey "t2_t1_id_fk" { column = "t1_id", ref = { schema = Just "p", table = "t1", column = Nothing } }))))
            , test "foreign key without schema & column" (\_ -> parseAlterTable "ALTER TABLE p.t2 ADD CONSTRAINT t2_t1_id_fk FOREIGN KEY (t1_id) REFERENCES t1;" |> Expect.equal (Ok (AddTableConstraint (Just "p") "t2" (ParsedForeignKey "t2_t1_id_fk" { column = "t1_id", ref = { schema = Nothing, table = "t1", column = Nothing } }))))
            , test "foreign key not valid" (\_ -> parseAlterTable "ALTER TABLE p.t2 ADD CONSTRAINT t2_t1_id_fk FOREIGN KEY (t1_id) REFERENCES p.t1 (id) NOT VALID;" |> Expect.equal (Ok (AddTableConstraint (Just "p") "t2" (ParsedForeignKey "t2_t1_id_fk" { column = "t1_id", ref = { schema = Just "p", table = "t1", column = Just "id" } }))))
            , test "unique" (\_ -> parseAlterTable "ALTER TABLE p.t1 ADD CONSTRAINT name_unique UNIQUE (first_name, last_name);" |> Expect.equal (Ok (AddTableConstraint (Just "p") "t1" (ParsedUnique "name_unique" { columns = [ "first_name", "last_name" ], definition = "(first_name, last_name)" }))))
            , test "check" (\_ -> parseAlterTable "ALTER TABLE p.t1 ADD CONSTRAINT t1_kind_not_null CHECK ((kind IS NOT NULL)) NOT VALID;" |> Expect.equal (Ok (AddTableConstraint (Just "p") "t1" (ParsedCheck "t1_kind_not_null" "((kind IS NOT NULL)) NOT VALID"))))
            , test "column default" (\_ -> parseAlterTable "ALTER TABLE public.table1 ALTER COLUMN id SET DEFAULT 1;" |> Expect.equal (Ok (AlterColumn (Just "public") "table1" (ColumnDefault "id" "1"))))
            , test "column statistics" (\_ -> parseAlterTable "ALTER TABLE public.table1 ALTER COLUMN table1_id SET STATISTICS 5000;" |> Expect.equal (Ok (AlterColumn (Just "public") "table1" (ColumnStatistics "table1_id" 5000))))
            , test "owner" (\_ -> parseAlterTable "ALTER TABLE public.table1 OWNER TO admin;" |> Expect.equal (Ok (AddTableOwner (Just "public") "table1" "admin")))
            , test "without schema" (\_ -> parseAlterTable "ALTER TABLE t2 ADD CONSTRAINT t2_id_pkey PRIMARY KEY (id);" |> Expect.equal (Ok (AddTableConstraint Nothing "t2" (ParsedPrimaryKey "t2_id_pkey" [ "id" ]))))
            , test "with only" (\_ -> parseAlterTable "ALTER TABLE ONLY public.t2 ADD CONSTRAINT t2_id_pkey PRIMARY KEY (id);" |> Expect.equal (Ok (AddTableConstraint (Just "public") "t2" (ParsedPrimaryKey "t2_id_pkey" [ "id" ]))))
            , test "bad" (\_ -> parseAlterTable "bad" |> Expect.equal (Err [ "Can't parse alter table: 'bad'" ]))
            ]
        , describe "parseTableComment"
            [ test "basic" (\_ -> parseTableComment "COMMENT ON TABLE public.table1 IS 'A comment';" |> Expect.equal (Ok { schema = Just "public", table = "table1", comment = "A comment" }))
            , test "with quotes" (\_ -> parseTableComment "COMMENT ON TABLE public.table1 IS 'A ''good'' comment';" |> Expect.equal (Ok { schema = Just "public", table = "table1", comment = "A 'good' comment" }))
            , test "with semicolon" (\_ -> parseTableComment "COMMENT ON TABLE public.table1 IS 'A ; comment';" |> Expect.equal (Ok { schema = Just "public", table = "table1", comment = "A ; comment" }))
            , test "bad" (\_ -> parseTableComment "bad" |> Expect.equal (Err [ "Can't parse table comment: 'bad'" ]))
            ]
        , describe "parseColumnComment"
            [ test "basic" (\_ -> parseColumnComment "COMMENT ON COLUMN public.table1.col IS 'A comment';" |> Expect.equal (Ok { schema = Just "public", table = "table1", column = "col", comment = "A comment" }))
            , test "with quotes" (\_ -> parseColumnComment "COMMENT ON COLUMN public.table1.col IS 'A ''good'' comment';" |> Expect.equal (Ok { schema = Just "public", table = "table1", column = "col", comment = "A 'good' comment" }))
            , test "with semicolon" (\_ -> parseColumnComment "COMMENT ON COLUMN public.table1.col IS 'A ; comment';" |> Expect.equal (Ok { schema = Just "public", table = "table1", column = "col", comment = "A ; comment" }))
            , test "bad" (\_ -> parseColumnComment "bad" |> Expect.equal (Err [ "Can't parse column comment: 'bad'" ]))
            ]
        , describe "commaSplit"
            [ test "split on comma" (\_ -> commaSplit "aaa,bbb,ccc" |> Expect.equal [ "aaa", "bbb", "ccc" ])
            , test "ignore comma inside parenthesis" (\_ -> commaSplit "aaa,bbb(1,2),ccc" |> Expect.equal [ "aaa", "bbb(1,2)", "ccc" ])
            ]
        ]
