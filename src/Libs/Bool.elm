module Libs.Bool exposing (cond, toString)


cond : Bool -> (() -> a) -> (() -> a) -> a
cond predicate true false =
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
