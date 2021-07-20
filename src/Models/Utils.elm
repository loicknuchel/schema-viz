module Models.Utils exposing (Color, SizeChange, ZoomDelta, ZoomLevel)

-- deps = { to = { only = [ "Libs.*", "Models.*" ] } }
-- generic types to use everywhere, should not include any project value, only libs if really needed

import Libs.Models exposing (HtmlId)
import Libs.Size exposing (Size)


type alias ZoomLevel =
    Float


type alias ZoomDelta =
    Float


type alias SizeChange =
    { id : HtmlId, size : Size }


type alias Color =
    String
