module SqlParser.SqlParserTest exposing (..)

import Expect
import SqlParser.Parsers.AlterTable exposing (TableConstraint(..), TableUpdate(..))
import SqlParser.SqlParser exposing (Command(..), parseCommand)
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
        ]
