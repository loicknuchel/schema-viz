module Main exposing (main)

import AssocList as Dict
import Browser
import Commands.FetchData exposing (loadData)
import Conf exposing (conf)
import Draggable
import FontAwesome.Styles as Icon
import Html exposing (text)
import Libs.Std exposing (set)
import Mappers.SchemaMapper exposing (buildSchema)
import Models exposing (Flags, Model, Msg(..), Status(..))
import Models.Schema exposing (TableStatus(..))
import Models.Utils exposing (Position, Size)
import Ports exposing (observeSize, sizesReceiver)
import Update exposing (dragConfig, dragItem, hideAllTables, hideTable, showAllTables, showTable, updateSizes, updateTable, zoomCanvas)
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
    ( { state = { status = Loading, search = "", dragId = Nothing, drag = Draggable.init }
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
            ( { model | state = model.state |> set (\state -> { state | status = Success }), schema = buildSchema tables }, Cmd.none )

        GotData (Err e) ->
            ( { model | state = model.state |> set (\state -> { state | status = Failure (formatHttpError e) }) }, Cmd.none )

        ChangedSearch search ->
            ( { model | state = model.state |> set (\state -> { state | search = search }) }, Cmd.none )

        HideTable id ->
            ( { model | schema = model.schema |> hideTable id }, Cmd.none )

        ShowTable id ->
            showTable model id

        InitializedTable id size position color ->
            ( { model | schema = model.schema |> updateTable id (\state -> { state | status = Shown, size = size, position = position, color = color }) }, Cmd.none )

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
            ( { model | state = model.state |> set (\state -> { state | dragId = Just id }) }, Cmd.none )

        StopDragging ->
            ( { model | state = model.state |> set (\state -> { state | dragId = Nothing }) }, Cmd.none )

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
