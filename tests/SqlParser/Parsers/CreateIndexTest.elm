module SqlParser.Parsers.CreateIndexTest exposing (..)

import SqlParser.Parsers.CreateIndex exposing (parseCreateIndex)
import SqlParser.Utils.HelpersTest exposing (stmCheck)
import Test exposing (Test, describe)


suite : Test
suite =
    describe "CreateIndex"
        [ describe "parseCreateIndex"
            [ stmCheck "basic" "CREATE INDEX unique_email on p.users(email);" parseCreateIndex (\_ -> Ok { name = "unique_email", table = { schema = Just "p", table = "users" }, columns = [ "email" ], definition = "(email)" })
            , stmCheck "lowercase, no schema, multiple columns, many spaces" "create index  unique_kind  on  users  (kind_type, kind_id);" parseCreateIndex (\_ -> Ok { name = "unique_kind", table = { schema = Nothing, table = "users" }, columns = [ "kind_type", "kind_id" ], definition = "(kind_type, kind_id)" })
            , stmCheck "complex" "CREATE INDEX phone_idx ON public.accounts USING btree (phone_number) WHERE (phone_number IS NOT NULL);" parseCreateIndex (\_ -> Ok { name = "phone_idx", table = { schema = Just "public", table = "accounts" }, columns = [ "phone_number" ], definition = "USING btree (phone_number) WHERE (phone_number IS NOT NULL)" })
            ]
        ]
