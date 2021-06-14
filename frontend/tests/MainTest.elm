module MainTest exposing (..)

import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, list, string)
import Test exposing (..)


suite : Test
suite =
    test "two plus two equals four"
        (\_ -> (2 + 2) |> Expect.equal 4)
