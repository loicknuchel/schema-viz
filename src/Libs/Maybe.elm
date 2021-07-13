module Libs.Maybe exposing (filter, resultSeq, toList)

import Libs.Bool as B



-- deps = { to = { only = [ "Libs.*" ] } }


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


tupleFirstSeq : b -> Maybe ( a, b ) -> ( Maybe a, b )
tupleFirstSeq default maybe =
    case maybe of
        Just ( a, b ) ->
            ( Just a, b )

        Nothing ->
            ( Nothing, default )


tupleSecondSeq : a -> Maybe ( a, b ) -> ( a, Maybe b )
tupleSecondSeq default maybe =
    case maybe of
        Just ( a, b ) ->
            ( a, Just b )

        Nothing ->
            ( default, Nothing )


toList : Maybe a -> List a
toList maybe =
    case maybe of
        Just a ->
            [ a ]

        Nothing ->
            []
