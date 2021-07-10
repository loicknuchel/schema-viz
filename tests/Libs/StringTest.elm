module Libs.StringTest exposing (..)

import Expect
import Libs.String exposing (hashCode, uniqueId, wordSplit)
import Test exposing (Test, describe, test)


suite : Test
suite =
    describe "String"
        [ describe "uniqueId"
            [ test "no conflict" (\_ -> uniqueId [] "aaa" |> Expect.equal "aaa")
            , test "conflict" (\_ -> uniqueId [ "bbb" ] "bbb" |> Expect.equal "bbb2")
            , test "conflict with number" (\_ -> uniqueId [ "ccc2" ] "ccc2" |> Expect.equal "ccc3")
            , test "conflict with extension" (\_ -> uniqueId [ "ddd.txt" ] "ddd.txt" |> Expect.equal "ddd2.txt")
            , test "conflict with extension and number" (\_ -> uniqueId [ "eee2.txt" ] "eee2.txt" |> Expect.equal "eee3.txt")
            , test "multi conflicts" (\_ -> uniqueId [ "fff.txt", "fff2.txt", "fff3.txt" ] "fff.txt" |> Expect.equal "fff4.txt")
            ]
        , describe "stringWordSplit"
            [ test "words are not split" (\_ -> wordSplit "test" |> Expect.equal [ "test" ])
            , test "split works on _" (\_ -> wordSplit "table_test" |> Expect.equal [ "table", "test" ])
            , test "split works on -" (\_ -> wordSplit "table-test" |> Expect.equal [ "table", "test" ])
            , test "split works on space" (\_ -> wordSplit "table test" |> Expect.equal [ "table", "test" ])
            ]
        , describe "stringHashCode"
            [ test "compute hello hashcode" (\_ -> hashCode "hello" |> Expect.equal -641073152)
            , test "compute demo hashcode" (\_ -> hashCode "demo" |> Expect.equal 179990644)
            ]
        ]
