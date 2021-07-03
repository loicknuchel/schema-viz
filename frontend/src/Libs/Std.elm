module Libs.Std exposing (..)

import AssocList as Dict exposing (Dict)
import Bitwise
import Html exposing (Attribute, Html, b, code, div, text)
import Html.Attributes exposing (attribute)
import Html.Events exposing (stopPropagationOn)
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


setSchema : (s -> s) -> { item | schema : s } -> { item | schema : s }
setSchema transform item =
    { item | schema = item.schema |> transform }


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


listFind : (a -> Bool) -> List a -> Maybe a
listFind predicate list =
    case list of
        [] ->
            Nothing

        first :: rest ->
            if predicate first then
                Just first

            else
                listFind predicate rest


listGet : Int -> List a -> Maybe a
listGet index list =
    list |> List.drop index |> List.head


listResultSeq : List (Result e a) -> Result (List e) (List a)
listResultSeq list =
    case
        List.foldr
            (\r ( errs, res ) ->
                case r of
                    Ok a ->
                        ( errs, a :: res )

                    Err e ->
                        ( e :: errs, res )
            )
            ( [], [] )
            list
    of
        ( [], res ) ->
            Ok res

        ( errs, _ ) ->
            Err errs


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


stringWordSplit : String -> List String
stringWordSplit input =
    List.foldl (\sep words -> words |> List.concatMap (\word -> String.split sep word)) [ input ] [ "_", "-", " " ]


stringHashCode : String -> Int
stringHashCode input =
    String.foldl updateHash 5381 input


updateHash : Char -> Int -> Int
updateHash char hashCode =
    Bitwise.shiftLeftBy hashCode (5 + hashCode + Char.toCode char)


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


stopClick : msg -> Attribute msg
stopClick m =
    stopPropagationOn "click" (Decode.succeed ( m, True ))


type alias FileEvent =
    { inputId : String, file : List FileInfo }


type alias FileInfo =
    { name : String, kind : String, size : Int, lastModified : Int }


onFileChange : (FileEvent -> msg) -> Attribute msg
onFileChange callback =
    -- Elm: no error message when decoder fail, hard to get it correct :(
    let
        fileDecoder : Decoder FileInfo
        fileDecoder =
            Decode.map4 FileInfo
                (Decode.field "name" Decode.string)
                (Decode.field "type" Decode.string)
                (Decode.field "size" Decode.int)
                (Decode.field "lastModified" Decode.int)

        decoder : Decoder msg
        decoder =
            Decode.field "target"
                (Decode.map2 FileEvent
                    (Decode.field "id" Decode.string)
                    (Decode.field "files" (Decode.list fileDecoder))
                )
                |> Decode.map callback

        preventDefaultAndStopPropagation : msg -> { message : msg, stopPropagation : Bool, preventDefault : Bool }
        preventDefaultAndStopPropagation msg =
            { message = msg, stopPropagation = True, preventDefault = True }
    in
    Html.Events.custom "change" (Decode.map preventDefaultAndStopPropagation decoder)


type alias WheelEvent =
    { delta : { x : Float, y : Float, z : Float }
    , mouse : { x : Float, y : Float }
    , keys : { ctrl : Bool, alt : Bool, shift : Bool, meta : Bool }
    }


onWheel : (WheelEvent -> msg) -> Attribute msg
onWheel callback =
    let
        decoder : Decoder msg
        decoder =
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
                |> Decode.map callback

        preventDefaultAndStopPropagation : msg -> { message : msg, stopPropagation : Bool, preventDefault : Bool }
        preventDefaultAndStopPropagation msg =
            { message = msg, stopPropagation = True, preventDefault = True }
    in
    Html.Events.custom "wheel" (Decode.map preventDefaultAndStopPropagation decoder)
