module Updates.Helpers exposing (decodeErrorToHtml, map, setColumns, setLayouts, setPosition, setSchema, setSchemaWithCmd, setSize, setState, setSwitch, setTables, setTime, updateTable, updateTables)

import AssocList as Dict
import Draggable
import Json.Decode as Decode
import Models exposing (Msg)
import Models.Schema exposing (Schema, Table, TableId)
import Models.Utils exposing (Position, ZoomLevel)


map : (a -> b) -> a -> b
map transform item =
    transform item


setState : (s -> s) -> { item | state : s } -> { item | state : s }
setState transform item =
    { item | state = item.state |> transform }


setTime : (t -> t) -> { item | time : t } -> { item | time : t }
setTime transform item =
    { item | time = item.time |> transform }


setSwitch : (s -> s) -> { item | switch : s } -> { item | switch : s }
setSwitch transform item =
    { item | switch = item.switch |> transform }


setSchema : (s -> s) -> { item | schema : Maybe s } -> { item | schema : Maybe s }
setSchema transform item =
    { item | schema = item.schema |> Maybe.map transform }


setSchemaWithCmd : (s -> ( s, Cmd Msg )) -> { item | schema : Maybe s } -> ( { item | schema : Maybe s }, Cmd Msg )
setSchemaWithCmd transform item =
    item.schema |> Maybe.map (\s -> s |> transform |> Tuple.mapFirst (\schema -> { item | schema = Just schema })) |> Maybe.withDefault ( item, Cmd.none )


setTables : (t -> t) -> { item | tables : t } -> { item | tables : t }
setTables transform item =
    { item | tables = item.tables |> transform }


setColumns : (c -> c) -> { item | columns : c } -> { item | columns : c }
setColumns transform item =
    { item | columns = item.columns |> transform }


setLayouts : (l -> l) -> { item | layouts : l } -> { item | layouts : l }
setLayouts transform item =
    { item | layouts = item.layouts |> transform }


setSize : (s -> s) -> { item | size : s } -> { item | size : s }
setSize transform item =
    { item | size = item.size |> transform }


setPosition : Draggable.Delta -> ZoomLevel -> { item | position : Position } -> { item | position : Position }
setPosition ( dx, dy ) zoom item =
    { item | position = Position (item.position.left + (dx / zoom)) (item.position.top + (dy / zoom)) }


updateTable : TableId -> (Table -> Table) -> Schema -> Schema
updateTable id transform schema =
    { schema | tables = schema.tables |> Dict.update id (Maybe.map transform) }


updateTables : (Table -> Table) -> Schema -> Schema
updateTables transform schema =
    { schema | tables = schema.tables |> Dict.map (\_ table -> transform table) }


decodeErrorToHtml : Decode.Error -> String
decodeErrorToHtml error =
    "<pre>" ++ Decode.errorToString error ++ "</pre>"
