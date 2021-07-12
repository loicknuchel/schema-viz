module Libs.String exposing (hashCode, plural, uniqueId, wordSplit)

import Bitwise
import Libs.Regex as R



-- deps = { to = { only = [ "Libs.*" ] } }


wordSplit : String -> List String
wordSplit input =
    List.foldl (\sep words -> words |> List.concatMap (\word -> String.split sep word)) [ input ] [ "_", "-", " " ]


hashCode : String -> Int
hashCode input =
    String.foldl updateHash 5381 input


updateHash : Char -> Int -> Int
updateHash char code =
    Bitwise.shiftLeftBy code (5 + code + Char.toCode char)


uniqueId : List String -> String -> String
uniqueId takenIds id =
    if takenIds |> List.any (\taken -> taken == id) then
        case id |> R.matches "^(.*?)([0-9]+)?(\\.[a-z]+)?$" of
            (Just prefix) :: num :: extension :: [] ->
                uniqueId
                    takenIds
                    (prefix
                        ++ (num |> Maybe.andThen String.toInt |> Maybe.map (\n -> n + 1) |> Maybe.withDefault 2 |> String.fromInt)
                        ++ (extension |> Maybe.withDefault "")
                    )

            _ ->
                id ++ "-err"

    else
        id


plural : Int -> String -> String -> String -> String
plural count none one many =
    if count == 0 then
        none

    else if count == 1 then
        one

    else
        String.fromInt count ++ " " ++ many
