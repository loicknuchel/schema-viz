module Libs.Std exposing (..)

import AssocList as Dict exposing (Dict)
import Html exposing (Attribute)
import Html.Events
import Json.Decode as Decode exposing (Decoder)
import Random


genSequence : List (Random.Generator a) -> Random.Generator (List a)
genSequence generators =
    List.foldr (Random.map2 (::)) (Random.constant []) generators


genChoose : ( a, List a ) -> Random.Generator a
genChoose ( item, list ) =
    Random.map (\num -> Maybe.withDefault item (List.head (List.drop num list))) (Random.int 0 (List.length list))


maybeFilter : (a -> Bool) -> Maybe a -> Maybe a
maybeFilter predicate maybe =
    Maybe.andThen
        (\a ->
            if predicate a then
                maybe

            else
                Nothing
        )
        maybe


maybeFold : b -> (a -> b) -> Maybe a -> b
maybeFold empty transform maybe =
    case maybe of
        Just a ->
            transform a

        Nothing ->
            empty


dictFromList : (a -> k) -> List a -> Dict k a
dictFromList getKey list =
    Dict.fromList (List.map (\item -> ( getKey item, item )) list)


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
                    (Decode.field "layerX" Decode.float)
                    (Decode.field "layerY" Decode.float)
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
