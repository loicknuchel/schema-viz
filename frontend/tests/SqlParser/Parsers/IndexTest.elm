module SqlParser.Parsers.IndexTest exposing (..)

import Expect
import SqlParser.Parsers.Index exposing (parseCreateIndex)
import Test exposing (Test, describe, test)


suite : Test
suite =
    describe "Index"
        [ describe "parseCreateIndex"
            [ test "basic" (\_ -> parseCreateIndex "CREATE INDEX unique_email on p.users(email);" |> Expect.equal (Ok { name = "unique_email", table = { schema = Just "p", table = "users" }, columns = [ "email" ], definition = "(email)" }))
            , test "lowercase, no schema, multiple columns, many spaces" (\_ -> parseCreateIndex "create index  unique_kind  on  users  (kind_type, kind_id);" |> Expect.equal (Ok { name = "unique_kind", table = { schema = Nothing, table = "users" }, columns = [ "kind_type", "kind_id" ], definition = "(kind_type, kind_id)" }))
            , test "complex" (\_ -> parseCreateIndex "CREATE INDEX phone_idx ON public.accounts USING btree (phone_number) WHERE (phone_number IS NOT NULL);" |> Expect.equal (Ok { name = "phone_idx", table = { schema = Just "public", table = "accounts" }, columns = [ "phone_number" ], definition = "USING btree (phone_number) WHERE (phone_number IS NOT NULL)" }))
            ]
        ]
