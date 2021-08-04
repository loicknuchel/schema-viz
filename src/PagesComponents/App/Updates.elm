module PagesComponents.App.Updates exposing (dragConfig, dragItem, removeElement, updateSizes)

import Conf exposing (conf)
import Dict
import Draggable
import Draggable.Events exposing (onDragBy, onDragEnd, onDragStart)
import Libs.Area exposing (Area)
import Libs.Bool as B
import Libs.List as L
import Libs.Maybe as M
import Libs.Models exposing (SizeChange)
import Libs.Position exposing (Position)
import Libs.Size exposing (Size)
import Libs.Task exposing (send)
import Models.Schema exposing (CanvasProps, TableId, htmlIdAsTableId)
import PagesComponents.App.Commands.InitializeTable exposing (initializeTable)
import PagesComponents.App.Models exposing (DragId, Model, Msg(..))
import PagesComponents.App.Updates.Helpers exposing (setCanvas, setLayout, setListTable, setPosition, setSchema)
import Ports exposing (toastError, toastInfo)


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
                    (s.layout.tables |> L.findBy .id (htmlIdAsTableId change.id))
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
                ( model |> setSchema (setLayout (\l -> l |> setListTable .id (htmlIdAsTableId id) (setPosition delta l.canvas.zoom))), Cmd.none )

        Nothing ->
            ( model, toastError "Can't dragItem when no drag id" )


removeElement : Model -> Cmd Msg
removeElement model =
    model.schema
        |> Maybe.map
            (\s ->
                let
                    selectedTables : List TableId
                    selectedTables =
                        s.layout.tables |> List.filter (\t -> t.selected) |> List.map .id
                in
                if L.nonEmpty selectedTables then
                    Cmd.batch (selectedTables |> List.map (\id -> send (HideTable id)))

                else
                    (model.hover.column |> Maybe.map (\c -> send (HideColumn c)))
                        |> M.orElse (model.hover.table |> Maybe.map (\t -> send (HideTable t)))
                        |> Maybe.withDefault (toastInfo "Can't find an element to remove :(")
            )
        |> Maybe.withDefault Cmd.none
