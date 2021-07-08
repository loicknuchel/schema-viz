module SqlParser.Utils.HelpersTest exposing (..)

import Expect
import SqlParser.Utils.Helpers exposing (commaSplit)
import Test exposing (Test, describe, test)


suite : Test
suite =
    describe "Helpers"
        [ describe "commaSplit"
            [ test "split on comma" (\_ -> commaSplit "aaa,bbb,ccc" |> Expect.equal [ "aaa", "bbb", "ccc" ])
            , test "ignore comma inside parenthesis" (\_ -> commaSplit "aaa,bbb(1,2),ccc" |> Expect.equal [ "aaa", "bbb(1,2)", "ccc" ])
            ]
        ]
