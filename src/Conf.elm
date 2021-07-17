module Conf exposing (conf, schemaSamples)

import Dict exposing (Dict)
import Libs.Models exposing (HtmlId)
import Models.Utils exposing (Color, ZoomLevel)



-- deps = { to = { only = [ "Libs.*", "Models.*" ] } }


conf :
    { zoom : { min : ZoomLevel, max : ZoomLevel, speed : Float }
    , colors : List Color
    , default : { schema : String, color : Color }
    , ids :
        { searchInput : HtmlId
        , menu : HtmlId
        , erd : HtmlId
        , schemaSwitchModal : HtmlId
        , newLayoutModal : HtmlId
        , helpModal : HtmlId
        , confirm : HtmlId
        }
    , loading : { showTablesThreshold : Int }
    }
conf =
    { zoom = { min = 0.05, max = 5, speed = 0.001 }
    , colors = [ "red", "yellow", "green", "blue", "indigo", "purple", "pink" ]
    , default = { schema = "public", color = "gray" }
    , ids =
        { searchInput = "search"
        , menu = "menu"
        , erd = "erd"
        , schemaSwitchModal = "schema-switch-modal"
        , newLayoutModal = "new-layout-modal"
        , helpModal = "help-modal"
        , confirm = "confirm-modal"
        }
    , loading = { showTablesThreshold = 20 }
    }


schemaSamples : Dict String String
schemaSamples =
    Dict.fromList
        (List.reverse
            [ ( "Basic example", "/tests/resources/schema.json" )
            ]
        )
