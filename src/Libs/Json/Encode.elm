module Libs.Json.Encode exposing (nel, object)

import Json.Encode as Encode exposing (Value)
import Libs.Nel as Nel exposing (Nel)



-- deps = { to = { only = [ "Libs.*" ] } }


object : List ( String, Encode.Value ) -> Encode.Value
object attrs =
    Encode.object (attrs |> List.filter (\( _, value ) -> not (value == Encode.null)))


nel : (a -> Value) -> Nel a -> Encode.Value
nel encoder value =
    value |> Nel.toList |> Encode.list encoder
