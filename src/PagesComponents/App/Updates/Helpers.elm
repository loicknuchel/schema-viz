module PagesComponents.App.Updates.Helpers exposing (decodeErrorToHtml, setCanvas, setLayout, setLayouts, setListTable, setPosition, setSchema, setSchemaWithCmd, setSwitch, setTables, setTime)

import Draggable
import Json.Decode as Decode
import Libs.Bool as B
import Libs.Models exposing (ZoomLevel)
import Libs.Position exposing (Position)


setTime : (t -> t) -> { item | time : t } -> { item | time : t }
setTime transform item =
    { item | time = item.time |> transform }


setSwitch : (s -> s) -> { item | switch : s } -> { item | switch : s }
setSwitch transform item =
    { item | switch = item.switch |> transform }


setSchema : (s -> s) -> { item | schema : Maybe s } -> { item | schema : Maybe s }
setSchema transform item =
    { item | schema = item.schema |> Maybe.map transform }


setSchemaWithCmd : (s -> ( s, Cmd msg )) -> { item | schema : Maybe s } -> ( { item | schema : Maybe s }, Cmd msg )
setSchemaWithCmd transform item =
    item.schema |> Maybe.map (\s -> s |> transform |> Tuple.mapFirst (\schema -> { item | schema = Just schema })) |> Maybe.withDefault ( item, Cmd.none )


setLayout : (l -> l) -> { item | layout : l } -> { item | layout : l }
setLayout transform item =
    { item | layout = item.layout |> transform }


setCanvas : (l -> l) -> { item | canvas : l } -> { item | canvas : l }
setCanvas transform item =
    { item | canvas = item.canvas |> transform }


setTables : (t -> t) -> { item | tables : t } -> { item | tables : t }
setTables transform item =
    { item | tables = item.tables |> transform }


setLayouts : (l -> l) -> { item | layouts : l } -> { item | layouts : l }
setLayouts transform item =
    { item | layouts = item.layouts |> transform }


setPosition : Draggable.Delta -> ZoomLevel -> { item | position : Position } -> { item | position : Position }
setPosition ( dx, dy ) zoom item =
    { item | position = Position (item.position.left + (dx / zoom)) (item.position.top + (dy / zoom)) }


setListTable : (table -> comparable) -> comparable -> (table -> table) -> { item | tables : List table } -> { item | tables : List table }
setListTable get id transform item =
    { item | tables = item.tables |> List.map (\t -> B.cond (get t == id) (transform t) t) }


decodeErrorToHtml : Decode.Error -> String
decodeErrorToHtml error =
    "<pre>" ++ Decode.errorToString error ++ "</pre>"
