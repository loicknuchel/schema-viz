module Libs.Nel exposing (Nel, map, toList)


type alias Nel a =
    { head : a, tail : List a }


map : (a -> b) -> Nel a -> Nel b
map f xs =
    { head = f xs.head, tail = xs.tail |> List.map f }


toList : Nel a -> List a
toList xs =
    xs.head :: xs.tail
