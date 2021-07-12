module Libs.Json.Encode exposing (dict, nel, object)

import AssocList as Dict exposing (Dict)
import Dict as ElmDict
import Json.Encode as Encode exposing (Value)
import Libs.Nel exposing (Nel)



-- deps = { to = { only = [ "Libs.*" ] } }


object : List ( String, Encode.Value ) -> Encode.Value
object attrs =
    Encode.object (attrs |> List.filter (\( _, value ) -> not (value == Encode.null)))


dict : (k -> String) -> (a -> Value) -> Dict k a -> Value
dict encodeKey encodeValue d =
    Encode.dict identity identity (d |> Dict.toList |> List.map (\( k, a ) -> ( encodeKey k, encodeValue a )) |> ElmDict.fromList)


nel : (a -> Value) -> Nel a -> Encode.Value
nel encoder value =
    object
        [ ( "head", value.head |> encoder )
        , ( "tail", value.tail |> Encode.list encoder )
        ]
