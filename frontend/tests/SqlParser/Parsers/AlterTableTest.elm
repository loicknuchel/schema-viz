module SqlParser.Parsers.AlterTableTest exposing (..)

import Expect
import SqlParser.Parsers.AlterTable exposing (ColumnUpdate(..), TableConstraint(..), TableUpdate(..), parseAlterTable)
import Test exposing (Test, describe, test)


suite : Test
suite =
    describe "AlterTable"
        [ describe "parseAlterTable"
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
        ]
