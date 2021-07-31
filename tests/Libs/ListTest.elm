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
        , describe "dropWhile"
            [ test "drop items while its true" (\_ -> [ 1, 2, 3, 4, 5 ] |> L.dropWhile (\i -> i < 3) |> Expect.equal [ 3, 4, 5 ])
            ]
        , describe "dropUntil"
            [ test "drop items while its false" (\_ -> [ 1, 2, 3, 4, 5 ] |> L.dropUntil (\i -> i == 3) |> Expect.equal [ 3, 4, 5 ])
            ]
        ]
