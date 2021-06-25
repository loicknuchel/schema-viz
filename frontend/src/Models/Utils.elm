module Models.Utils exposing (Area, Color, Position, Size)

-- generic types to use everywhere, should not include any project value, only libs if really needed


type alias Size =
    { width : Float, height : Float }


type alias Position =
    { left : Float, top : Float }


type alias Area =
    { left : Float, right : Float, top : Float, bottom : Float }


type alias Color =
    String
