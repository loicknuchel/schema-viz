module Libs.Nel exposing (Nel, any, filter, filterMap, find, fromList, indexedMap, map, toList)

import Libs.List as L



-- deps = { to = { only = [ "Libs.*" ] } }
-- Nel: NonEmptyList


type alias Nel a =
    { head : a, tail : List a }


map : (a -> b) -> Nel a -> Nel b
map f xs =
    { head = f xs.head, tail = xs.tail |> List.map f }


filterMap : (a -> Maybe b) -> Nel a -> List b
filterMap f xs =
    xs |> toList |> List.filterMap f


indexedMap : (Int -> a -> b) -> Nel a -> Nel b
indexedMap f xs =
    { head = f 0 xs.head, tail = xs.tail |> List.indexedMap (\i a -> f (i + 1) a) }


find : (a -> Bool) -> Nel a -> Maybe a
find predicate nel =
    nel |> toList |> L.find predicate


filter : (a -> Bool) -> Nel a -> List a
filter predicate nel =
    nel |> toList |> List.filter predicate


any : (a -> Bool) -> Nel a -> Bool
any predicate nel =
    nel |> toList |> List.any predicate


toList : Nel a -> List a
toList xs =
    xs.head :: xs.tail


fromList : List a -> Maybe (Nel a)
fromList list =
    case list of
        head :: tail ->
            Just (Nel head tail)

        _ ->
            Nothing
