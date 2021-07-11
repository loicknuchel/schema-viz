module Libs.Maybe exposing (filter, resultSeq, toList)

import Libs.Bool as B


orElse : Maybe a -> Maybe a -> Maybe a
orElse other item =
    case ( item, other ) of
        ( Just a1, _ ) ->
            Just a1

        ( Nothing, res ) ->
            res


filter : (a -> Bool) -> Maybe a -> Maybe a
filter predicate maybe =
    maybe |> Maybe.andThen (\a -> B.cond (predicate a) maybe Nothing)


fold : b -> (a -> b) -> Maybe a -> b
fold empty transform maybe =
    case maybe of
        Just a ->
            transform a

        Nothing ->
            empty


add : (a -> Maybe b) -> Maybe a -> Maybe ( a, b )
add get maybe =
    maybe |> Maybe.andThen (\a -> get a |> Maybe.map (\b -> ( a, b )))


resultSeq : Maybe (Result x a) -> Result x (Maybe a)
resultSeq maybe =
    case maybe of
        Just r ->
            r |> Result.map (\a -> Just a)

        Nothing ->
            Ok Nothing


toList : Maybe a -> List a
toList maybe =
    case maybe of
        Just a ->
            [ a ]

        Nothing ->
            []
