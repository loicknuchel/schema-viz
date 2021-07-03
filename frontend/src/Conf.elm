module Conf exposing (conf)

import Models.Utils exposing (Color, HtmlId, ZoomLevel)


conf :
    { zoom : { min : ZoomLevel, max : ZoomLevel, speed : Float }
    , colors : List Color
    , default : { schema : String, color : Color }
    , ids : { menu : HtmlId, erd : HtmlId, schemaSwitchModal : HtmlId, newLayoutModal : HtmlId, helpModal : HtmlId }
    , loading : { showTablesThreshold : Int }
    }
conf =
    { zoom = { min = 0.1, max = 5, speed = 0.001 }
    , colors = [ "red", "yellow", "green", "blue", "indigo", "purple", "pink" ]
    , default = { schema = "public", color = "gray" }
    , ids = { menu = "menu", erd = "erd", schemaSwitchModal = "schema-switch-modal", newLayoutModal = "new-layout-modal", helpModal = "help-modal" }
    , loading = { showTablesThreshold = 20 }
    }
