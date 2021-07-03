module Conf exposing (conf)

import Models.Utils exposing (Color, HtmlId, ZoomLevel)


conf :
    { zoom : { min : ZoomLevel, max : ZoomLevel, speed : Float }
    , colors : List Color
    , default : { schema : String, color : Color }
    , ids : { erd : HtmlId }
    , loading : { showTablesThreshold : Int }
    }
conf =
    { zoom = { min = 0.1, max = 5, speed = 0.001 }
    , colors = [ "red", "yellow", "green", "blue", "indigo", "purple", "pink" ]
    , default = { schema = "public", color = "gray" }
    , ids = { erd = "erd" }
    , loading = { showTablesThreshold = 20 }
    }
