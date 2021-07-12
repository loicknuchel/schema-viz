module Libs.Std exposing (set, setSchema, setState)

-- deps = { to = { only = [ "Libs.*" ] } }


set : (a -> a) -> a -> a
set transform item =
    transform item


setState : (s -> s) -> { item | state : s } -> { item | state : s }
setState transform item =
    { item | state = item.state |> transform }


setSchema : (s -> s) -> { item | schema : s } -> { item | schema : s }
setSchema transform item =
    { item | schema = item.schema |> transform }
