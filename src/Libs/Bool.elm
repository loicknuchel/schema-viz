module Libs.Bool exposing (cond, lazyCond, toString)

-- deps = { to = { only = [ "Libs.*" ] } }


cond : Bool -> a -> a -> a
cond predicate true false =
    if predicate then
        true

    else
        false


lazyCond : Bool -> (() -> a) -> (() -> a) -> a
lazyCond predicate true false =
    if predicate then
        true ()

    else
        false ()


toString : Bool -> String
toString bool =
    case bool of
        True ->
            "true"

        False ->
            "false"
