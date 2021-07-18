module Conf exposing (conf, schemaSamples)

import Dict exposing (Dict)
import Libs.Hotkey exposing (Hotkey, hotkey, target)
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
    , hotkeys : Dict String Hotkey
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
    , hotkeys =
        Dict.fromList
            [ ( "save", { hotkey | key = Just "s", ctrl = True, onInput = True, preventDefault = True } )
            , ( "undo", { hotkey | key = Just "z", ctrl = True } )
            , ( "redo", { hotkey | key = Just "Z", ctrl = True, shift = True } )
            , ( "focus-search", { hotkey | key = Just "/" } )
            , ( "autocomplete-down", { hotkey | key = Just "ArrowDown", target = Just { target | id = Just "search", tag = Just "input" } } )
            , ( "autocomplete-up", { hotkey | key = Just "ArrowUp", target = Just { target | id = Just "search", tag = Just "input" } } )
            , ( "help", { hotkey | key = Just "?" } )
            ]
    }


schemaSamples : Dict String String
schemaSamples =
    Dict.fromList
        (List.reverse
            [ ( "Basic example", "/tests/resources/schema.json" )
            ]
        )
