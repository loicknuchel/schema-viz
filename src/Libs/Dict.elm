module Libs.Dict exposing (filterZip, fromList, getOrElse, groupBy)

import AssocList as Dict exposing (Dict)



-- deps = { to = { only = [ "Libs.*" ] } }


fromList : (a -> k) -> List a -> Dict k a
fromList getKey list =
    list |> List.reverse |> List.map (\item -> ( getKey item, item )) |> Dict.fromList


getOrElse : k -> a -> Dict k a -> a
getOrElse key default dict =
    dict |> Dict.get key |> Maybe.withDefault default


groupBy : (a -> k) -> List a -> Dict k (List a)
groupBy key list =
    List.foldr (\a dict -> dict |> Dict.update (key a) (\v -> v |> Maybe.map ((::) a) |> Maybe.withDefault [ a ] |> Just)) Dict.empty list


filterMap : (k -> a -> Maybe b) -> Dict k a -> Dict k b
filterMap f dict =
    dict |> Dict.toList |> List.filterMap (\( k, a ) -> f k a |> Maybe.map (\b -> ( k, b ))) |> Dict.fromList


filterZip : (k -> a -> Maybe b) -> Dict k a -> Dict k ( a, b )
filterZip f dict =
    dict |> Dict.toList |> List.filterMap (\( k, a ) -> f k a |> Maybe.map (\b -> ( k, ( a, b ) ))) |> Dict.fromList
