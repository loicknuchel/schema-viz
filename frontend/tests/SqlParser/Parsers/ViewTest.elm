module SqlParser.Parsers.ViewTest exposing (..)

import Expect
import SqlParser.Parsers.View exposing (parseView)
import Test exposing (Test, describe, test)


view : String
view =
    """
CREATE MATERIALIZED VIEW public.autocomplete AS
SELECT accounts.id AS account_id,
       accounts.first_name,
       accounts.last_name,
       accounts.email
FROM public.accounts
WHERE accounts.deleted_at IS NULL
WITH NO DATA;
""" |> String.trim |> String.replace "\n" " "


suite : Test
suite =
    describe "View"
        [ describe "parseView"
            [ test "basic" (\_ -> parseView view |> Result.map .table |> Expect.equal (Ok "autocomplete"))
            ]
        ]
