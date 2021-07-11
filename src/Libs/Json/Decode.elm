module Libs.Json.Decode exposing (dict, map10, nel, tuple)

import AssocList as Dict exposing (Dict)
import Dict as ElmDict
import Json.Decode as Decode exposing (Decoder)
import Libs.Nel exposing (Nel)


tuple : Decoder a -> Decoder b -> Decoder ( a, b )
tuple aDecoder bDecoder =
    Decode.map2 Tuple.pair
        (Decode.index 0 aDecoder)
        (Decode.index 1 bDecoder)


dict : (String -> k) -> Decode.Decoder a -> Decode.Decoder (Dict k a)
dict buildKey decoder =
    Decode.dict decoder |> Decode.map (\d -> d |> ElmDict.toList |> List.map (\( k, a ) -> ( buildKey k, a )) |> Dict.fromList)


nel : Decode.Decoder a -> Decode.Decoder (Nel a)
nel decoder =
    Decode.map2 Nel
        (Decode.field "head" decoder)
        (Decode.field "tail" (Decode.list decoder))


map9 : (a -> b -> c -> d -> e -> f -> g -> h -> i -> value) -> Decode.Decoder a -> Decode.Decoder b -> Decode.Decoder c -> Decode.Decoder d -> Decode.Decoder e -> Decode.Decoder f -> Decode.Decoder g -> Decode.Decoder h -> Decode.Decoder i -> Decode.Decoder value
map9 callback da db dc dd de df dg dh di =
    Decode.map2 (\( ( a, b, c ), ( d, e, f ) ) ( g, h, i ) -> callback a b c d e f g h i)
        (Decode.map6 (\a b c d e f -> ( ( a, b, c ), ( d, e, f ) )) da db dc dd de df)
        (Decode.map3 (\g h i -> ( g, h, i )) dg dh di)


map10 : (a -> b -> c -> d -> e -> f -> g -> h -> i -> j -> value) -> Decode.Decoder a -> Decode.Decoder b -> Decode.Decoder c -> Decode.Decoder d -> Decode.Decoder e -> Decode.Decoder f -> Decode.Decoder g -> Decode.Decoder h -> Decode.Decoder i -> Decode.Decoder j -> Decode.Decoder value
map10 callback da db dc dd de df dg dh di dj =
    Decode.map2 (\( ( a, b, c ), ( d, e, f ) ) ( ( g, h ), ( i, j ) ) -> callback a b c d e f g h i j)
        (Decode.map6 (\a b c d e f -> ( ( a, b, c ), ( d, e, f ) )) da db dc dd de df)
        (Decode.map4 (\g h i j -> ( ( g, h ), ( i, j ) )) dg dh di dj)


map11 : (a -> b -> c -> d -> e -> f -> g -> h -> i -> j -> k -> value) -> Decode.Decoder a -> Decode.Decoder b -> Decode.Decoder c -> Decode.Decoder d -> Decode.Decoder e -> Decode.Decoder f -> Decode.Decoder g -> Decode.Decoder h -> Decode.Decoder i -> Decode.Decoder j -> Decode.Decoder k -> Decode.Decoder value
map11 callback da db dc dd de df dg dh di dj dk =
    Decode.map2 (\( ( a, b, c ), ( d, e, f ) ) ( ( g, h, i ), ( j, k ) ) -> callback a b c d e f g h i j k)
        (Decode.map6 (\a b c d e f -> ( ( a, b, c ), ( d, e, f ) )) da db dc dd de df)
        (Decode.map5 (\g h i j k -> ( ( g, h, i ), ( j, k ) )) dg dh di dj dk)


map12 : (a -> b -> c -> d -> e -> f -> g -> h -> i -> j -> k -> l -> value) -> Decode.Decoder a -> Decode.Decoder b -> Decode.Decoder c -> Decode.Decoder d -> Decode.Decoder e -> Decode.Decoder f -> Decode.Decoder g -> Decode.Decoder h -> Decode.Decoder i -> Decode.Decoder j -> Decode.Decoder k -> Decode.Decoder l -> Decode.Decoder value
map12 callback da db dc dd de df dg dh di dj dk dl =
    Decode.map2 (\( ( a, b, c ), ( d, e, f ) ) ( ( g, h, i ), ( j, k, l ) ) -> callback a b c d e f g h i j k l)
        (Decode.map6 (\a b c d e f -> ( ( a, b, c ), ( d, e, f ) )) da db dc dd de df)
        (Decode.map6 (\g h i j k l -> ( ( g, h, i ), ( j, k, l ) )) dg dh di dj dk dl)
