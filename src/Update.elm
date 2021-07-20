module Update exposing (dragConfig, dragItem, updateSizes)

import Commands.InitializeTable exposing (initializeTable)
import Conf exposing (conf)
import Dict
import Draggable
import Draggable.Events exposing (onDragBy, onDragEnd, onDragStart)
import Libs.Area exposing (Area)
import Libs.Bool as B
import Libs.Maybe as M
import Libs.Position exposing (Position)
import Libs.Size exposing (Size)
import Models exposing (DragId, Model, Msg(..))
import Models.Schema exposing (CanvasProps, htmlIdAsTableId)
import Models.Utils exposing (SizeChange)
import Ports exposing (toastError)
import Updates.Helpers exposing (setCanvas, setDictTable, setLayout, setPosition, setSchema)



-- deps = { to = { except = [ "Main", "View", "Views.*" ] } }
-- utility methods to get the update case down to one line


updateSizes : List SizeChange -> Model -> ( Model, Cmd Msg )
updateSizes sizeChanges model =
    ( sizeChanges |> List.foldr updateSize model, Cmd.batch (sizeChanges |> List.filterMap (initializeTableOnFirstSize model)) )


updateSize : SizeChange -> Model -> Model
updateSize change model =
    { model | sizes = model.sizes |> Dict.update change.id (\_ -> B.cond (change.size == Size 0 0) Nothing (Just change.size)) }


initializeTableOnFirstSize : Model -> SizeChange -> Maybe (Cmd Msg)
initializeTableOnFirstSize model change =
    model.schema
        |> Maybe.andThen
            (\s ->
                Maybe.map3 (\t props canvasSize -> ( t, props, canvasSize ))
                    (s.tables |> Dict.get (htmlIdAsTableId change.id))
                    (s.layout.tables |> Dict.get (htmlIdAsTableId change.id))
                    (model.sizes |> Dict.get conf.ids.erd)
                    |> M.filter (\( _, props, _ ) -> props.position == Position 0 0 && not (model.sizes |> Dict.member change.id))
                    |> Maybe.map (\( t, _, canvasSize ) -> t.id |> initializeTable change.size (getArea canvasSize s.layout.canvas))
            )


getArea : Size -> CanvasProps -> Area
getArea canvasSize canvas =
    { left = (0 - canvas.position.left) / canvas.zoom
    , right = (canvasSize.width - canvas.position.left) / canvas.zoom
    , top = (0 - canvas.position.top) / canvas.zoom
    , bottom = (canvasSize.height - canvas.position.top) / canvas.zoom
    }


dragConfig : Draggable.Config DragId Msg
dragConfig =
    Draggable.customConfig
        [ onDragStart StartDragging
        , onDragEnd StopDragging
        , onDragBy OnDragBy
        ]


dragItem : Model -> Draggable.Delta -> ( Model, Cmd Msg )
dragItem model delta =
    case model.dragId of
        Just id ->
            if id == conf.ids.erd then
                ( model |> setSchema (setLayout (setCanvas (setPosition delta 1))), Cmd.none )

            else
                ( model |> setSchema (setLayout (\l -> l |> setDictTable (htmlIdAsTableId id) (setPosition delta l.canvas.zoom))), Cmd.none )

        Nothing ->
            ( model, toastError "Can't dragItem when no drag id" )
