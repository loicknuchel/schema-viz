module Models.Utils exposing (Area, Color, FileContent, FileName, HtmlId, Position, Size, SizeChange, Text, ZoomLevel)

-- generic types to use everywhere, should not include any project value, only libs if really needed


type alias ZoomLevel =
    Float


type alias Size =
    { width : Float, height : Float }


type alias SizeChange =
    { id : HtmlId, size : Size }


type alias Position =
    { left : Float, top : Float }


type alias Area =
    { left : Float, right : Float, top : Float, bottom : Float }


type alias HtmlId =
    String


type alias Text =
    String


type alias FileName =
    String


type alias FileContent =
    String


type alias Color =
    String
