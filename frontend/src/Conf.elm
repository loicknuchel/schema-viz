module Conf exposing (colorList, conf)

import Models.Utils exposing (Color, ZoomLevel)


conf :
    { zoom : { min : ZoomLevel, max : ZoomLevel, speed : Float }
    , colors : { pink : Color, purple : Color, darkBlue : Color, blue : Color, turquoise : Color, lightBlue : Color, lightGreen : Color, green : Color, yellow : Color, orange : Color, red : Color, grey : Color }
    , defaultSchema : String
    , ids : { erd : String }
    , loading : { showTablesThreshold : Int }
    }
conf =
    { zoom = { min = 0.1, max = 5, speed = 0.001 }
    , colors = { pink = "#F66D9B", purple = "#9561E2", darkBlue = "#6574CD", blue = "#3490DC", turquoise = "#4DC0B5", lightBlue = "#22D3EE", lightGreen = "#84CC16", green = "#38C172", yellow = "#FFED4A", orange = "#F6993F", red = "#E3342F", grey = "#B8C2CC" }
    , defaultSchema = "public"
    , ids = { erd = "erd" }
    , loading = { showTablesThreshold = 20 }
    }


colorList : List Color
colorList =
    case conf.colors of
        { pink, purple, darkBlue, blue, turquoise, lightBlue, lightGreen, green, yellow, orange, red, grey } ->
            [ pink, purple, darkBlue, blue, turquoise, lightBlue, lightGreen, green, yellow, orange, red, grey ]
