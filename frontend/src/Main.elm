module Main exposing (main)

import AssocList as Dict
import Browser
import Browser.Dom as Dom
import Commands.FetchData exposing (loadData)
import Commands.GetSize exposing (getWindowSize)
import Commands.InitializeTable exposing (initializeTable)
import Draggable
import FontAwesome.Styles as Icon
import Html exposing (text)
import Mappers.SchemaMapper exposing (buildSchema)
import Models exposing (Menu, Model, Msg(..), State, Status(..))
import Models.Schema exposing (Schema)
import Models.Utils exposing (Position, Size)
import Update exposing (dragConfig, dragItem, hideAllTables, hideTable, setState, showAllTables, showTable, updateTable, zoomCanvas)
import View exposing (viewApp)
import Views.Helpers exposing (formatHttpError)



-- MAIN: program entry point \o/


main : Program () Model Msg
main =
    Browser.document { init = init, update = update, subscriptions = subscriptions, view = view }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { state = initState, menu = initMenu, schema = initSchema }
    , Cmd.batch [ getWindowSize, loadData "/tests/resources/schema.json" ]
    )


initState : State
initState =
    { status = Loading, windowSize = Size 0 0, zoom = 1, position = Position 0 0, dragId = Nothing, drag = Draggable.init }


initMenu : Menu
initMenu =
    { position = Position 0 0 }


initSchema : Schema
initSchema =
    { tables = Dict.empty, relations = [] }



-- UPDATE: each case should be one line or call a function in Update file


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotWindowSize (Ok windowSize) ->
            ( setState (\state -> { state | windowSize = windowSize }) model, Cmd.none )

        GotWindowSize (Err (Dom.NotFound e)) ->
            ( setState (\state -> { state | status = Failure ("Size not found for '" ++ e ++ "'") }) model, Cmd.none )

        GotData (Ok tables) ->
            ( setState (\state -> { state | status = Success }) { model | schema = buildSchema tables }, Cmd.none )

        GotData (Err e) ->
            ( setState (\state -> { state | status = Failure (formatHttpError e) }) model, Cmd.none )

        HideTable id ->
            ( { model | schema = hideTable model.schema id }, Cmd.none )

        ShowTable id ->
            showTable model id

        GotTableSize (Ok ( id, size )) ->
            ( model, initializeTable id size model.state.windowSize )

        GotTableSize (Err (Dom.NotFound e)) ->
            ( setState (\state -> { state | status = Failure ("Size not found for '" ++ e ++ "' id") }) model, Cmd.none )

        InitializedTable id size position color ->
            ( { model | schema = updateTable model.schema id size position color }, Cmd.none )

        HideAllTables ->
            ( { model | schema = hideAllTables model.schema }, Cmd.none )

        ShowAllTables ->
            showAllTables model

        Zoom zoom ->
            ( { model | state = zoomCanvas model.state zoom }, Cmd.none )

        DragMsg dragMsg ->
            Tuple.mapFirst (\newState -> { model | state = newState }) (Draggable.update dragConfig dragMsg model.state)

        StartDragging id ->
            ( setState (\state -> { state | dragId = Just id }) model, Cmd.none )

        StopDragging ->
            ( setState (\state -> { state | dragId = Nothing }) model, Cmd.none )

        OnDragBy delta ->
            ( dragItem model delta, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Draggable.subscriptions DragMsg model.state.drag



-- VIEW: each case should be one line


view : Model -> Browser.Document Msg
view model =
    { title = "Schema Viz"
    , body =
        [ Icon.css
        , case model.state.status of
            Failure e ->
                text ("Oooups an error happened, " ++ e)

            Loading ->
                viewApp model (Just "Loading...")

            Success ->
                viewApp model Nothing
        ]
    }
