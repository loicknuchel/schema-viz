module Main exposing (main)

import AssocList as Dict
import Browser
import Commands.FetchData exposing (loadData)
import Draggable
import FontAwesome.Styles as Icon
import Html exposing (text)
import Mappers.SchemaMapper exposing (buildSchema)
import Models exposing (Flags, Model, Msg(..), Status(..), conf)
import Models.Schema exposing (TableStatus(..))
import Models.Utils exposing (Position, Size)
import Ports exposing (observeSize, sizesReceiver)
import Update exposing (dragConfig, dragItem, hideAllTables, hideTable, setState, showAllTables, showTable, updateSizes, updateTable, zoomCanvas)
import View exposing (viewApp)
import Views.Helpers exposing (formatHttpError)


dataUrl : String
dataUrl =
    "/tests/resources/schema.json"



-- MAIN: program entry point \o/


main : Program Flags Model Msg
main =
    Browser.document { init = init, update = update, view = view, subscriptions = subscriptions }


init : Flags -> ( Model, Cmd Msg )
init _ =
    ( { state = { status = Loading, dragId = Nothing, drag = Draggable.init }
      , menu = { position = Position 0 0 }
      , canvas = { size = Size 0 0, zoom = 1, position = Position 0 0 }
      , schema = { tables = Dict.empty, relations = [] }
      }
    , Cmd.batch
        [ observeSize conf.ids.erd
        , loadData dataUrl
        ]
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        -- each case should be one line or call a function in Update file
        GotData (Ok tables) ->
            ( setState (\state -> { state | status = Success }) { model | schema = buildSchema tables }, Cmd.none )

        GotData (Err e) ->
            ( setState (\state -> { state | status = Failure (formatHttpError e) }) model, Cmd.none )

        HideTable id ->
            ( { model | schema = hideTable model.schema id }, Cmd.none )

        ShowTable id ->
            showTable model id

        InitializedTable id size position color ->
            ( { model | schema = updateTable (\state -> { state | status = Shown, size = size, position = position, color = color }) id model.schema }, Cmd.none )

        SizesChanged sizes ->
            updateSizes sizes model

        HideAllTables ->
            ( { model | schema = hideAllTables model.schema }, Cmd.none )

        ShowAllTables ->
            showAllTables model

        Zoom zoom ->
            ( { model | canvas = zoomCanvas zoom model.canvas }, Cmd.none )

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
        , sizesReceiver SizesChanged
        ]
