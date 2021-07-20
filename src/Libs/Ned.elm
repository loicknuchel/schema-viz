module Libs.Ned exposing (Ned, build, buildMap, fromNel, fromNelMap, get, singleton, singletonMap, size, values)

import Dict exposing (Dict)
import Libs.Nel as Nel exposing (Nel)



-- deps = { to = { only = [ "Libs.*" ] } }
-- Ned: NonEmptyDict


type alias Ned k a =
    { head : ( k, a ), tail : Dict k a }


get : comparable -> Ned comparable a -> Maybe a
get key ned =
    if Tuple.first ned.head == key then
        Just (ned.head |> Tuple.second)

    else
        ned.tail |> Dict.get key


values : Ned k a -> Nel a
values ned =
    Nel (ned.head |> Tuple.second) (ned.tail |> Dict.values)


size : Ned k a -> Int
size ned =
    1 + Dict.size ned.tail


singleton : ( comparable, a ) -> Ned comparable a
singleton head =
    Ned head Dict.empty


build : ( comparable, a ) -> List ( comparable, a ) -> Ned comparable a
build head tail =
    Ned head (tail |> Dict.fromList)


fromNel : Nel ( comparable, a ) -> Ned comparable a
fromNel nel =
    Ned nel.head (nel.tail |> Dict.fromList)


toNel : Ned k a -> Nel ( k, a )
toNel ned =
    Nel ned.head (ned.tail |> Dict.toList)


fromList : List ( comparable, a ) -> Maybe (Ned comparable a)
fromList list =
    case list of
        head :: tail ->
            Just (Ned head (tail |> Dict.fromList))

        _ ->
            Nothing


toList : Ned k a -> List ( k, a )
toList ned =
    ned.head :: (ned.tail |> Dict.toList)


fromDict : Dict comparable a -> Maybe (Ned comparable a)
fromDict dict =
    case dict |> Dict.toList of
        head :: tail ->
            Just (Ned head (tail |> Dict.fromList))

        _ ->
            Nothing


toDict : Ned comparable a -> Dict comparable a
toDict ned =
    ned.tail |> Dict.insert (Tuple.first ned.head) (Tuple.second ned.head)


singletonMap : (a -> comparable) -> a -> Ned comparable a
singletonMap getKey item =
    Ned ( getKey item, item ) Dict.empty


buildMap : (a -> comparable) -> a -> List a -> Ned comparable a
buildMap getKey head tail =
    Ned ( getKey head, head ) (tail |> List.map (\item -> ( getKey item, item )) |> Dict.fromList)


fromNelMap : (a -> comparable) -> Nel a -> Ned comparable a
fromNelMap getKey nel =
    nel |> Nel.map (\item -> ( getKey item, item )) |> fromNel
