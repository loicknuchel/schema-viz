module Main exposing (main)

import AssocList as Dict
import Basics
import Browser
import Browser.Dom as Dom
import Browser.Events
import Commands.FetchData exposing (loadData)
import Commands.GetSize exposing (getWindowSize)
import Commands.InitializeTable exposing (initializeTable)
import Draggable
import FontAwesome.Styles as Icon
import Html exposing (text)
import Mappers.SchemaMapper exposing (buildSchema)
import Models exposing (Flags, Menu, Model, Msg(..), State, Status(..), WindowSize)
import Models.Schema exposing (Schema)
import Models.Utils exposing (Position, Size)
import Update exposing (dragConfig, dragItem, hideAllTables, hideTable, setState, showAllTables, showTable, updateTable, zoomCanvas)
import View exposing (viewApp)
import Views.Helpers exposing (formatHttpError)


dataUrl =
    "/tests/resources/schema.json"



-- MAIN: program entry point \o/


main : Program Flags Model Msg
main =
    Browser.document { init = init, update = update, view = view, subscriptions = subscriptions }


init : Flags -> ( Model, Cmd Msg )
init _ =
    ( { state = { status = Loading, windowSize = Size 0 0, zoom = 1, position = Position 0 0, dragId = Nothing, drag = Draggable.init }
      , menu = { position = Position 0 0 }
      , schema = { tables = Dict.empty, relations = [] }
      }
    , Cmd.batch
        [ getWindowSize
        , loadData dataUrl
        ]
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        -- each case should be one line or call a function in Update file
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


view : Model -> Browser.Document Msg
view model =
    { title = "Schema Viz"
    , body =
        [ Icon.css
        , case model.state.status of
            -- each case should be one line
            Failure e ->
                text ("Oooups an error happened, " ++ e)

            Loading ->
                viewApp model (Just "Loading...")

            Success ->
                viewApp model Nothing
        ]
    }


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Draggable.subscriptions DragMsg model.state.drag
        , Browser.Events.onResize (\w h -> GotWindowSize (Ok (Size (toFloat w) (toFloat h))))
        ]
