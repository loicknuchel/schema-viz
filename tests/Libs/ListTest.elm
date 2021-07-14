module Libs.ListTest exposing (..)

import Expect
import Libs.List as L
import Test exposing (Test, describe, test)


suite : Test
suite =
    describe "List"
        [ describe "addAt"
            [ test "first" (\_ -> [ "b", "c" ] |> L.addAt "a" 0 |> Expect.equal [ "a", "b", "c" ])
            , test "middle" (\_ -> [ "a", "c" ] |> L.addAt "b" 1 |> Expect.equal [ "a", "b", "c" ])
            , test "last" (\_ -> [ "a", "b" ] |> L.addAt "c" 2 |> Expect.equal [ "a", "b", "c" ])
            , test "after" (\_ -> [ "a", "b" ] |> L.addAt "c" 5 |> Expect.equal [ "a", "b", "c" ])
            ]
        ]
