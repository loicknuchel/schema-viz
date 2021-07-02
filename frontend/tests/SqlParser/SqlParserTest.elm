module SqlParser.SqlParserTest exposing (..)

import Expect
import SqlParser.SqlParser exposing (ColumnUpdate(..), Statement(..), TableConstraint(..), TableUpdate(..), commaSplit, parseAlterTable, parseColumnComment, parseCreateTable, parseCreateTableColumn, parseStatement, parseTableComment)
import Test exposing (Test, describe, test)


suite : Test
suite =
    describe "SqlParser"
        [ describe "parseStatement"
            [ test "parse create table" (\_ -> parseStatement "CREATE TABLE aaa.bbb (ccc int);" |> Expect.equal (Ok (CreateTable { schema = "aaa", table = "bbb", columns = [ { name = "ccc", kind = "int", nullable = True, default = Nothing } ] })))
            , test "parse alter table" (\_ -> parseStatement "ALTER TABLE ONLY public.t2 ADD CONSTRAINT t2_id_pkey PRIMARY KEY (id);" |> Expect.equal (Ok (AlterTable (AddTableConstraint "public" "t2" (PrimaryKey "t2_id_pkey" [ "id" ])))))
            , test "parse table comment" (\_ -> parseStatement "COMMENT ON TABLE public.table1 IS 'A comment';" |> Expect.equal (Ok (TableComment { schema = "public", table = "table1", comment = "A comment" })))
            , test "parse column comment" (\_ -> parseStatement "COMMENT ON COLUMN public.table1.col IS 'A comment';" |> Expect.equal (Ok (ColumnComment { schema = "public", table = "table1", column = "col", comment = "A comment" })))
            ]
        , describe "parseCreateTable"
            [ test "basic" (\_ -> parseCreateTable "CREATE TABLE aaa.bbb (ccc int);" |> Expect.equal (Ok { schema = "aaa", table = "bbb", columns = [ { name = "ccc", kind = "int", nullable = True, default = Nothing } ] }))
            , test "complex"
                (\_ ->
                    parseCreateTable
                        "CREATE TABLE public.users (id bigint NOT NULL, name character varying(255), price numeric(8,2)) WITH (autovacuum_enabled='false');"
                        |> Expect.equal
                            (Ok
                                { schema = "public"
                                , table = "users"
                                , columns =
                                    [ { name = "id", kind = "bigint", nullable = False, default = Nothing }
                                    , { name = "name", kind = "character varying(255)", nullable = True, default = Nothing }
                                    , { name = "price", kind = "numeric(8,2)", nullable = True, default = Nothing }
                                    ]
                                }
                            )
                )
            , test "bad" (\_ -> parseCreateTable "bad" |> Expect.equal (Err [ "Can't parse table: 'bad'" ]))
            ]
        , describe "parseCreateTableColumn"
            [ test "basic" (\_ -> parseCreateTableColumn "id bigint NOT NULL" |> Expect.equal (Ok { name = "id", kind = "bigint", nullable = False, default = Nothing }))
            , test "nullable" (\_ -> parseCreateTableColumn "id bigint" |> Expect.equal (Ok { name = "id", kind = "bigint", nullable = True, default = Nothing }))
            , test "with default" (\_ -> parseCreateTableColumn "status character varying(255) DEFAULT 'done'::character varying" |> Expect.equal (Ok { name = "status", kind = "character varying(255)", nullable = True, default = Just "'done'::character varying" }))
            , test "with comma in type" (\_ -> parseCreateTableColumn "price numeric(8,2)" |> Expect.equal (Ok { name = "price", kind = "numeric(8,2)", nullable = True, default = Nothing }))
            , test "with enclosing quotes" (\_ -> parseCreateTableColumn "\"id\" bigint" |> Expect.equal (Ok { name = "id", kind = "bigint", nullable = True, default = Nothing }))
            , test "bad" (\_ -> parseCreateTableColumn "bad" |> Expect.equal (Err "Can't parse column: 'bad'"))
            ]
        , describe "parseAlterTable"
            [ test "primary key" (\_ -> parseAlterTable "ALTER TABLE ONLY public.t2 ADD CONSTRAINT t2_id_pkey PRIMARY KEY (id);" |> Expect.equal (Ok (AddTableConstraint "public" "t2" (PrimaryKey "t2_id_pkey" [ "id" ]))))
            , test "foreign key" (\_ -> parseAlterTable "ALTER TABLE ONLY p.t2 ADD CONSTRAINT t2_t1_id_fk FOREIGN KEY (t1_id) REFERENCES p.t1 (id);" |> Expect.equal (Ok (AddTableConstraint "p" "t2" (ForeignKey "t2_t1_id_fk" { column = "t1_id", schemaDest = "p", tableDest = "t1", columnDest = "id" }))))
            , test "unique" (\_ -> parseAlterTable "ALTER TABLE ONLY p.t1 ADD CONSTRAINT name_unique UNIQUE (first_name, last_name);" |> Expect.equal (Ok (AddTableConstraint "p" "t1" (Unique "name_unique" [ "first_name", "last_name" ]))))
            , test "check" (\_ -> parseAlterTable "ALTER TABLE p.t1 ADD CONSTRAINT t1_kind_not_null CHECK ((kind IS NOT NULL)) NOT VALID;" |> Expect.equal (Ok (AddTableConstraint "p" "t1" (Check "t1_kind_not_null" "((kind IS NOT NULL)) NOT VALID"))))
            , test "column default" (\_ -> parseAlterTable "ALTER TABLE ONLY public.table1 ALTER COLUMN id SET DEFAULT 1;" |> Expect.equal (Ok (AlterColumn "public" "table1" (ColumnDefault "id" "1"))))
            , test "column statistics" (\_ -> parseAlterTable "ALTER TABLE ONLY public.table1 ALTER COLUMN table1_id SET STATISTICS 5000;" |> Expect.equal (Ok (AlterColumn "public" "table1" (ColumnStatistics "table1_id" 5000))))
            , test "bad" (\_ -> parseAlterTable "bad" |> Expect.equal (Err [ "Can't parse alter table: 'bad'" ]))
            ]
        , describe "parseTableComment"
            [ test "basic" (\_ -> parseTableComment "COMMENT ON TABLE public.table1 IS 'A comment';" |> Expect.equal (Ok { schema = "public", table = "table1", comment = "A comment" }))
            , test "with quotes" (\_ -> parseTableComment "COMMENT ON TABLE public.table1 IS 'A ''good'' comment';" |> Expect.equal (Ok { schema = "public", table = "table1", comment = "A 'good' comment" }))
            , test "with semicolon" (\_ -> parseTableComment "COMMENT ON TABLE public.table1 IS 'A ; comment';" |> Expect.equal (Ok { schema = "public", table = "table1", comment = "A ; comment" }))
            , test "bad" (\_ -> parseTableComment "bad" |> Expect.equal (Err [ "Can't parse table comment: 'bad'" ]))
            ]
        , describe "parseColumnComment"
            [ test "basic" (\_ -> parseColumnComment "COMMENT ON COLUMN public.table1.col IS 'A comment';" |> Expect.equal (Ok { schema = "public", table = "table1", column = "col", comment = "A comment" }))
            , test "with quotes" (\_ -> parseColumnComment "COMMENT ON COLUMN public.table1.col IS 'A ''good'' comment';" |> Expect.equal (Ok { schema = "public", table = "table1", column = "col", comment = "A 'good' comment" }))
            , test "with semicolon" (\_ -> parseColumnComment "COMMENT ON COLUMN public.table1.col IS 'A ; comment';" |> Expect.equal (Ok { schema = "public", table = "table1", column = "col", comment = "A ; comment" }))
            , test "bad" (\_ -> parseColumnComment "bad" |> Expect.equal (Err [ "Can't parse column comment: 'bad'" ]))
            ]
        , describe "commaSplit"
            [ test "split on comma" (\_ -> commaSplit "aaa,bbb,ccc" |> Expect.equal [ "aaa", "bbb", "ccc" ])
            , test "ignore comma inside parenthesis" (\_ -> commaSplit "aaa,bbb(1,2),ccc" |> Expect.equal [ "aaa", "bbb(1,2)", "ccc" ])
            ]
        ]
