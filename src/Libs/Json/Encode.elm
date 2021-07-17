module Libs.Json.Encode exposing (nel, object)

import Json.Encode as Encode exposing (Value)
import Libs.Nel exposing (Nel)



-- deps = { to = { only = [ "Libs.*" ] } }


object : List ( String, Encode.Value ) -> Encode.Value
object attrs =
    Encode.object (attrs |> List.filter (\( _, value ) -> not (value == Encode.null)))


nel : (a -> Value) -> Nel a -> Encode.Value
nel encoder value =
    object
        [ ( "head", value.head |> encoder )
        , ( "tail", value.tail |> Encode.list encoder )
        ]
