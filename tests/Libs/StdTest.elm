module Libs.StdTest exposing (..)

import Expect
import Libs.Std exposing (stringHashCode, stringWordSplit)
import Test exposing (Test, describe, test)


suite : Test
suite =
    describe "Std"
        [ describe "string"
            [ describe "stringWordSplit"
                [ test "words are not split" (\_ -> stringWordSplit "test" |> Expect.equal [ "test" ])
                , test "split works on _" (\_ -> stringWordSplit "table_test" |> Expect.equal [ "table", "test" ])
                , test "split works on -" (\_ -> stringWordSplit "table-test" |> Expect.equal [ "table", "test" ])
                , test "split works on space" (\_ -> stringWordSplit "table test" |> Expect.equal [ "table", "test" ])
                ]
            , describe "stringHashCode"
                [ test "compute hello hashcode" (\_ -> stringHashCode "hello" |> Expect.equal -641073152)
                , test "compute demo hashcode" (\_ -> stringHashCode "demo" |> Expect.equal 179990644)
                ]
            ]
        ]
