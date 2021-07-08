module MainTest exposing (..)

import Expect
import Test exposing (..)


suite : Test
suite =
    test "two plus two equals four"
        (\_ -> (2 + 2) |> Expect.equal 4)
