module Libs.Json.Decode exposing (tuple)

import Json.Decode as Decode exposing (Decoder)


tuple : Decoder a -> Decoder b -> Decoder ( a, b )
tuple aDecoder bDecoder =
    Decode.map2 Tuple.pair
        (Decode.index 0 aDecoder)
        (Decode.index 1 bDecoder)
