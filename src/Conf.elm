module Conf exposing (conf, schemaSamples)

import Dict exposing (Dict)
import Libs.Hotkey exposing (Hotkey, hotkey, target)
import Libs.Models exposing (Color, HtmlId, ZoomLevel)


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
    , hotkeys : Dict String (List Hotkey)
    }
conf =
    { zoom = { min = 0.05, max = 5, speed = 0.001 }
    , colors = [ "red", "orange", "amber", "yellow", "lime", "green", "emerald", "teal", "cyan", "sky", "blue", "indigo", "violet", "purple", "fuchsia", "pink", "rose" ]
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
            [ ( "focus-search", [ { hotkey | key = Just "/" } ] )
            , ( "autocomplete-down", [ { hotkey | key = Just "ArrowDown", target = Just { target | id = Just "search", tag = Just "input" } } ] )
            , ( "autocomplete-up", [ { hotkey | key = Just "ArrowUp", target = Just { target | id = Just "search", tag = Just "input" } } ] )
            , ( "remove", [ { hotkey | key = Just "d" }, { hotkey | key = Just "h" }, { hotkey | key = Just "Backspace" }, { hotkey | key = Just "Delete" } ] )
            , ( "save", [ { hotkey | key = Just "s", ctrl = True, onInput = True, preventDefault = True } ] )
            , ( "undo", [ { hotkey | key = Just "z", ctrl = True } ] )
            , ( "redo", [ { hotkey | key = Just "Z", ctrl = True, shift = True } ] )
            , ( "help", [ { hotkey | key = Just "?" } ] )
            ]
    }


schemaSamples : Dict String ( Int, String )
schemaSamples =
    Dict.fromList
        (List.reverse
            [ ( "basic schema", ( 4, "samples/basic.json" ) )
            , ( "gospeak.io", ( 26, "samples/gospeak.sql" ) )
            ]
        )
