module Libs.Nel exposing (Nel, any, filter, filterMap, find, fromList, indexedMap, length, map, prepend, toList)

-- Nel: NonEmptyList


type alias Nel a =
    { head : a, tail : List a }


prepend : a -> Nel a -> Nel a
prepend a nel =
    Nel a (nel.head :: nel.tail)


map : (a -> b) -> Nel a -> Nel b
map f xs =
    { head = f xs.head, tail = xs.tail |> List.map f }


filterMap : (a -> Maybe b) -> Nel a -> List b
filterMap f xs =
    xs |> toList |> List.filterMap f


indexedMap : (Int -> a -> b) -> Nel a -> Nel b
indexedMap f xs =
    { head = f 0 xs.head, tail = xs.tail |> List.indexedMap (\i a -> f (i + 1) a) }


find : (a -> Bool) -> Nel a -> Maybe a
find predicate nel =
    if predicate nel.head then
        Just nel.head

    else
        case nel.tail of
            [] ->
                Nothing

            head :: tail ->
                find predicate (Nel head tail)


filter : (a -> Bool) -> Nel a -> List a
filter predicate nel =
    nel |> toList |> List.filter predicate


any : (a -> Bool) -> Nel a -> Bool
any predicate nel =
    nel |> toList |> List.any predicate


length : Nel a -> Int
length nel =
    1 + List.length nel.tail


toList : Nel a -> List a
toList xs =
    xs.head :: xs.tail


fromList : List a -> Maybe (Nel a)
fromList list =
    case list of
        head :: tail ->
            Just (Nel head tail)

        _ ->
            Nothing
