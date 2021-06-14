module Models.Utils exposing (..)

-- generic types to use everywhere, should not include any project value, only libs if really needed


type alias Size =
    { width : Float, height : Float }


type alias Position =
    { left : Float, top : Float }


type alias Color =
    String