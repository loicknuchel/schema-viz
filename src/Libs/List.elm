module Libs.List exposing (addIf, appendOn, filterMap, find, get, resultCollect, resultSeq)

import Libs.Bool as B
import Random


get : Int -> List a -> Maybe a
get index list =
    list |> List.drop index |> List.head


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


filterMap : (a -> Bool) -> (a -> b) -> List a -> List b
filterMap predicate transform list =
    list |> List.foldr (\a res -> B.cond (predicate a) (\_ -> transform a :: res) (\_ -> res)) []


addIf : Bool -> a -> List a -> List a
addIf predicate item list =
    if predicate then
        item :: list

    else
        list


addOn : Maybe b -> (b -> a) -> List a -> List a
addOn maybe transform list =
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
