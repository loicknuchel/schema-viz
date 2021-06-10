module Lib exposing (..)

import Random


genSequence : List (Random.Generator a) -> Random.Generator (List a)
genSequence generators =
    List.foldr (Random.map2 (::)) (Random.constant []) generators


genChoose : ( a, List a ) -> Random.Generator a
genChoose ( item, list ) =
    Random.map (\num -> Maybe.withDefault item (List.head (List.drop num list))) (Random.int 0 (List.length list))


maybeFold : b -> (a -> b) -> Maybe a -> b
maybeFold empty transform maybe =
    case maybe of
        Just a ->
            transform a

        Nothing ->
            empty
