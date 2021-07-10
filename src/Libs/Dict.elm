module Libs.Dict exposing (fromList)

import AssocList as Dict exposing (Dict)


fromList : (a -> k) -> List a -> Dict k a
fromList getKey list =
    list |> List.reverse |> List.map (\item -> ( getKey item, item )) |> Dict.fromList
