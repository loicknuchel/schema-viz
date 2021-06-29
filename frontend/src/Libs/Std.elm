module Libs.Std exposing (..)

import AssocList as Dict exposing (Dict)
import Html exposing (Attribute, Html, b, code, div, text)
import Html.Attributes exposing (attribute)
import Html.Events
import Json.Decode as Decode exposing (Decoder)
import Random



-- generic utils that could be packaged in external lib. Do not use anything project specific!


cond : Bool -> (() -> a) -> (() -> a) -> a
cond predicate true false =
    if predicate then
        true ()

    else
        false ()


set : (a -> a) -> a -> a
set transform item =
    transform item


setState : (s -> s) -> { item | state : s } -> { item | state : s }
setState transform item =
    { item | state = item.state |> transform }


listFilterMap : (a -> Bool) -> (a -> b) -> List a -> List b
listFilterMap predicate transform list =
    list |> List.foldr (\a res -> cond (predicate a) (\_ -> transform a :: res) (\_ -> res)) []


listZipWith : (a -> b) -> List a -> List ( a, b )
listZipWith transform list =
    list |> List.map (\a -> ( a, transform a ))


listAddIf : Bool -> a -> List a -> List a
listAddIf predicate item list =
    if predicate then
        item :: list

    else
        list


listAddOn : Maybe b -> (b -> a) -> List a -> List a
listAddOn maybe transform list =
    case maybe of
        Just b ->
            transform b :: list

        Nothing ->
            list


listAppendOn : Maybe b -> (b -> a) -> List a -> List a
listAppendOn maybe transform list =
    case maybe of
        Just b ->
            list ++ [ transform b ]

        Nothing ->
            list


maybeFilter : (a -> Bool) -> Maybe a -> Maybe a
maybeFilter predicate maybe =
    maybe |> Maybe.andThen (\a -> cond (predicate a) (\_ -> maybe) (\_ -> Nothing))


maybeAdd : (a -> Maybe b) -> Maybe a -> Maybe ( a, b )
maybeAdd get maybe =
    maybe |> Maybe.andThen (\a -> get a |> Maybe.map (\b -> ( a, b )))


maybeFold : b -> (a -> b) -> Maybe a -> b
maybeFold empty transform maybe =
    case maybe of
        Just a ->
            transform a

        Nothing ->
            empty


dictFromList : (a -> k) -> List a -> Dict k a
dictFromList getKey list =
    list |> List.reverse |> List.map (\item -> ( getKey item, item )) |> Dict.fromList


role : String -> Attribute msg
role text =
    attribute "role" text


divIf : Bool -> List (Attribute msg) -> List (Html msg) -> Html msg
divIf predicate attrs children =
    if predicate then
        div attrs children

    else
        div [] []


bText : String -> Html msg
bText content =
    b [] [ text content ]


codeText : String -> Html msg
codeText content =
    code [] [ text content ]


plural : Int -> String -> String -> String -> String
plural count none one many =
    if count == 0 then
        none

    else if count == 1 then
        one

    else
        String.fromInt count ++ many


genSequence : List (Random.Generator a) -> Random.Generator (List a)
genSequence generators =
    generators |> List.foldr (Random.map2 (::)) (Random.constant [])


genChoose : ( a, List a ) -> Random.Generator a
genChoose ( item, list ) =
    Random.int 0 (list |> List.length) |> Random.map (\num -> list |> List.drop num |> List.head |> Maybe.withDefault item)


type alias WheelEvent =
    { delta : { x : Float, y : Float, z : Float }
    , mouse : { x : Float, y : Float }
    , keys : { ctrl : Bool, alt : Bool, shift : Bool, meta : Bool }
    }


handleWheel : (WheelEvent -> msg) -> Attribute msg
handleWheel onWheel =
    let
        wheelDecoder : Decoder msg
        wheelDecoder =
            Decode.map3 WheelEvent
                (Decode.map3 (\x y z -> { x = x, y = y, z = z })
                    (Decode.field "deltaX" Decode.float)
                    (Decode.field "deltaY" Decode.float)
                    (Decode.field "deltaZ" Decode.float)
                )
                (Decode.map2 (\x y -> { x = x, y = y })
                    (Decode.field "pageX" Decode.float)
                    (Decode.field "pageY" Decode.float)
                )
                (Decode.map4 (\ctrl alt shift meta -> { ctrl = ctrl, alt = alt, shift = shift, meta = meta })
                    (Decode.field "ctrlKey" Decode.bool)
                    (Decode.field "altKey" Decode.bool)
                    (Decode.field "shiftKey" Decode.bool)
                    (Decode.field "metaKey" Decode.bool)
                )
                |> Decode.map onWheel

        preventDefaultAndStopPropagation : msg -> { message : msg, stopPropagation : Bool, preventDefault : Bool }
        preventDefaultAndStopPropagation msg =
            { message = msg, stopPropagation = True, preventDefault = True }
    in
    Html.Events.custom "wheel" (Decode.map preventDefaultAndStopPropagation wheelDecoder)
