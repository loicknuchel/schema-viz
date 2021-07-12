module Libs.Random exposing (genChoose)

import Random



-- deps = { to = { only = [ "Libs.*" ] } }


genChoose : ( a, List a ) -> Random.Generator a
genChoose ( item, list ) =
    Random.int 0 (list |> List.length) |> Random.map (\num -> list |> List.drop num |> List.head |> Maybe.withDefault item)
