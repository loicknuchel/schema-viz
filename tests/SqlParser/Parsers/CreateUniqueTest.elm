module SqlParser.Parsers.CreateUniqueTest exposing (..)

import Expect
import SqlParser.Parsers.CreateUnique exposing (parseCreateUniqueIndex)
import Test exposing (Test, describe, test)


suite : Test
suite =
    describe "CreateUnique"
        [ describe "parseCreateUniqueIndex"
            [ test "basic" (\_ -> parseCreateUniqueIndex "CREATE UNIQUE INDEX unique_email on p.users(email);" |> Expect.equal (Ok { name = "unique_email", table = { schema = Just "p", table = "users" }, columns = [ "email" ], definition = "(email)" }))
            , test "lowercase, no schema, multiple columns, many spaces" (\_ -> parseCreateUniqueIndex "create unique index  unique_kind  on  users  (kind_type, kind_id);" |> Expect.equal (Ok { name = "unique_kind", table = { schema = Nothing, table = "users" }, columns = [ "kind_type", "kind_id" ], definition = "(kind_type, kind_id)" }))
            , test "complex" (\_ -> parseCreateUniqueIndex "CREATE UNIQUE INDEX kpi_index ON public.statistics USING btree (kpi_id, source_type, source_id);" |> Expect.equal (Ok { name = "kpi_index", table = { schema = Just "public", table = "statistics" }, columns = [ "kpi_id", "source_type", "source_id" ], definition = "USING btree (kpi_id, source_type, source_id)" }))
            ]
        ]
