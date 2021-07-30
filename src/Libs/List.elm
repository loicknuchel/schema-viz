module Libs.List exposing (addAt, addIf, appendOn, filterMap, filterZip, find, get, groupBy, has, hasNot, indexOf, nonEmpty, prependOn, resultCollect, resultSeq, zipWith)

import Dict exposing (Dict)
import Libs.Bool as B
import Libs.Nel as Nel exposing (Nel)
import Random


get : Int -> List a -> Maybe a
get index list =
    list |> List.drop index |> List.head


nonEmpty : List a -> Bool
nonEmpty list =
    not (List.isEmpty list)


find : (a -> Bool) -> List a -> Maybe a
find predicate list =
    case list of
        [] ->
            Nothing

        first :: rest ->
            if predicate first then
                Just first

            else
                find predicate rest


indexOf : a -> List a -> Maybe Int
indexOf item xs =
    xs |> List.indexedMap (\i a -> ( i, a )) |> find (\( _, a ) -> a == item) |> Maybe.map Tuple.first


has : a -> List a -> Bool
has item xs =
    xs |> List.any (\a -> a == item)


hasNot : a -> List a -> Bool
hasNot item xs =
    not (has item xs)


filterZip : (a -> Maybe b) -> List a -> List ( a, b )
filterZip f xs =
    List.filterMap (\a -> f a |> Maybe.map (\b -> ( a, b ))) xs


filterMap : (a -> Bool) -> (a -> b) -> List a -> List b
filterMap predicate transform list =
    list |> List.foldr (\a res -> B.lazyCond (predicate a) (\_ -> transform a :: res) (\_ -> res)) []


addAt : a -> Int -> List a -> List a
addAt item index list =
    if index >= List.length list then
        List.concat [ list, [ item ] ]

    else
        -- list |> List.indexedMap (\i a -> ( i, a )) |> List.concatMap (\( i, a ) -> B.cond (i == index) [ item, a ] [ a ])
        -- list |> List.foldl (\a ( res, i ) -> ( List.concat [ res, B.cond (i == index) [ item, a ] [ a ] ], i + 1 )) ( [], 0 ) |> Tuple.first
        list |> List.foldr (\a ( res, i ) -> ( B.cond (i == index) (item :: a :: res) (a :: res), i - 1 )) ( [], List.length list - 1 ) |> Tuple.first


addIf : Bool -> a -> List a -> List a
addIf predicate item list =
    if predicate then
        item :: list

    else
        list


prependOn : Maybe b -> (b -> a) -> List a -> List a
prependOn maybe transform list =
    case maybe of
        Just b ->
            transform b :: list

        Nothing ->
            list


appendOn : Maybe b -> (b -> a) -> List a -> List a
appendOn maybe transform list =
    case maybe of
        Just b ->
            list ++ [ transform b ]

        Nothing ->
            list


zipWith : (a -> b) -> List a -> List ( a, b )
zipWith transform list =
    list |> List.map (\a -> ( a, transform a ))


groupBy : (a -> comparable) -> List a -> Dict comparable (Nel a)
groupBy key list =
    List.foldr (\a dict -> dict |> Dict.update (key a) (\v -> v |> Maybe.map (Nel.prepend a) |> Maybe.withDefault (Nel a []) |> Just)) Dict.empty list


resultCollect : List (Result e a) -> ( List e, List a )
resultCollect list =
    List.foldr
        (\r ( errs, res ) ->
            case r of
                Ok a ->
                    ( errs, a :: res )

                Err e ->
                    ( e :: errs, res )
        )
        ( [], [] )
        list


resultSeq : List (Result e a) -> Result (List e) (List a)
resultSeq list =
    case resultCollect list of
        ( [], res ) ->
            Ok res

        ( errs, _ ) ->
            Err errs


genSeq : List (Random.Generator a) -> Random.Generator (List a)
genSeq generators =
    generators |> List.foldr (Random.map2 (::)) (Random.constant [])
