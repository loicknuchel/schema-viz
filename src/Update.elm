module Update exposing (dragConfig, dragItem, updateSizes, zoomCanvas)

import AssocList as Dict
import Commands.InitializeTable exposing (initializeTable)
import Conf exposing (conf)
import Draggable
import Draggable.Events exposing (onDragBy, onDragEnd, onDragStart)
import Libs.Html.Events exposing (WheelEvent)
import Libs.Maybe as M
import Models exposing (Canvas, DragId, Model, Msg(..))
import Models.Schema exposing (SchemaState, Table, TableId, TableStatus(..), Tables, parseTableId)
import Models.Utils exposing (Area, Position, SizeChange, ZoomLevel)
import Ports exposing (toastError)
import Updates.Helpers exposing (setPosition, setSchema, setSize, setState, updateTable)



-- deps = { to = { except = [ "Main", "View", "Views.*" ] } }
-- utility methods to get the update case down to one line


updateSizes : List SizeChange -> Model -> ( Model, Cmd Msg )
updateSizes sizeChanges model =
    ( sizeChanges |> List.foldr updateSize model, Cmd.batch (sizeChanges |> List.filterMap (maybeChangeCmd model)) )


updateSize : SizeChange -> Model -> Model
updateSize change model =
    if change.id == conf.ids.erd then
        { model | canvas = model.canvas |> setSize (\_ -> change.size) }

    else
        model |> setSchema (updateTable (parseTableId change.id) (setState (\s -> { s | size = change.size })))


maybeChangeCmd : Model -> SizeChange -> Maybe (Cmd Msg)
maybeChangeCmd model { id, size } =
    model.schema |> Maybe.andThen (\s -> s.tables |> getInitializingTable (parseTableId id) |> Maybe.map (\t -> t.id |> initializeTable size (getArea model.canvas s.state)))


getInitializingTable : TableId -> Tables -> Maybe Table
getInitializingTable id tables =
    Dict.get id tables |> M.filter (\t -> t.state.status == Initializing)


getArea : Canvas -> SchemaState -> Area
getArea canvas state =
    { left = (0 - state.position.left) / state.zoom
    , right = (canvas.size.width - state.position.left) / state.zoom
    , top = (0 - state.position.top) / state.zoom
    , bottom = (canvas.size.height - state.position.top) / state.zoom
    }


zoomCanvas : WheelEvent -> SchemaState -> SchemaState
zoomCanvas wheel state =
    let
        newZoom : ZoomLevel
        newZoom =
            (state.zoom + (wheel.delta.y * conf.zoom.speed)) |> clamp conf.zoom.min conf.zoom.max

        zoomFactor : Float
        zoomFactor =
            newZoom / state.zoom

        -- to zoom on cursor, works only if origin is top left (CSS property: "transform-origin: top left;")
        newLeft : Float
        newLeft =
            state.position.left - ((wheel.mouse.x - state.position.left) * (zoomFactor - 1))

        newTop : Float
        newTop =
            state.position.top - ((wheel.mouse.y - state.position.top) * (zoomFactor - 1))
    in
    { state | zoom = newZoom, position = Position newLeft newTop }


dragConfig : Draggable.Config DragId Msg
dragConfig =
    Draggable.customConfig
        [ onDragStart StartDragging
        , onDragEnd StopDragging
        , onDragBy OnDragBy
        ]


dragItem : Model -> Draggable.Delta -> ( Model, Cmd Msg )
dragItem model delta =
    case model.state.dragId of
        Just id ->
            if id == conf.ids.erd then
                ( model |> setSchema (setState (setPosition delta 1)), Cmd.none )

            else
                ( model |> setSchema (\s -> s |> updateTable (parseTableId id) (setState (setPosition delta s.state.zoom))), Cmd.none )

        Nothing ->
            ( model, toastError "Can't dragItem when no drag id" )
