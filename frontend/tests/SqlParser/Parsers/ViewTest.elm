module SqlParser.Parsers.ViewTest exposing (..)

import Expect
import SqlParser.Parsers.Select exposing (SelectColumn(..), SelectInfo, SelectTable(..))
import SqlParser.Parsers.View exposing (parseView)
import Test exposing (Test, describe, test)


view : String
view =
    """
CREATE MATERIALIZED VIEW public.autocomplete AS
SELECT accounts.id AS account_id,
       accounts.email
FROM public.accounts
WHERE accounts.deleted_at IS NULL
WITH NO DATA;
""" |> String.trim |> String.replace "\n" " "


select : SelectInfo
select =
    { columns =
        [ BasicColumn { table = Just "accounts", column = "id", alias = Just "account_id" }
        , BasicColumn { table = Just "accounts", column = "email", alias = Nothing }
        ]
    , tables =
        [ BasicTable { schema = Just "public", table = "accounts", alias = Nothing }
        ]
    , whereClause = Just "accounts.deleted_at IS NULL"
    }


suite : Test
suite =
    describe "View"
        [ describe "parseView"
            [ test "basic" (\_ -> parseView view |> Expect.equal (Ok { schema = Just "public", table = "autocomplete", select = select, materialized = True, extra = Just "WITH NO DATA" }))
            ]
        ]
