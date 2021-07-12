module Models.Utils exposing (Area, Color, Position, Size, SizeChange, ZoomLevel)

-- deps = { to = { only = [ "Libs.*", "Models.*" ] } }
-- generic types to use everywhere, should not include any project value, only libs if really needed

import Libs.Models exposing (HtmlId)


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


type alias Color =
    String
