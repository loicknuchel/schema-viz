module Libs.Dict exposing (fromList, getOrElse, groupBy)

-- deps = { to = { only = [ "Libs.*" ] } }

import Dict exposing (Dict)


fromList : (a -> comparable) -> List a -> Dict comparable a
fromList getKey list =
    list |> List.map (\item -> ( getKey item, item )) |> Dict.fromList


getOrElse : comparable -> a -> Dict comparable a -> a
getOrElse key default dict =
    dict |> Dict.get key |> Maybe.withDefault default


groupBy : (a -> comparable) -> List a -> Dict comparable (List a)
groupBy key list =
    List.foldr (\a dict -> dict |> Dict.update (key a) (\v -> v |> Maybe.map ((::) a) |> Maybe.withDefault [ a ] |> Just)) Dict.empty list


filterMap : (comparable -> a -> Maybe b) -> Dict comparable a -> Dict comparable b
filterMap f dict =
    dict |> Dict.toList |> List.filterMap (\( k, a ) -> f k a |> Maybe.map (\b -> ( k, b ))) |> Dict.fromList


filterZip : (comparable -> a -> Maybe b) -> Dict comparable a -> Dict comparable ( a, b )
filterZip f dict =
    dict |> Dict.toList |> List.filterMap (\( k, a ) -> f k a |> Maybe.map (\b -> ( k, ( a, b ) ))) |> Dict.fromList
