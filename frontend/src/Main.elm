module Main exposing (..)

import Browser
import Browser.Dom as Dom
import Commands.FetchData exposing (loadData)
import Commands.GetSizes exposing (getSizes)
import Commands.RenderLayout exposing (buildTable, renderLayout)
import Decoders.SchemaDecoder exposing (JsonTable)
import Draggable
import FontAwesome.Styles as Icon
import Html exposing (text)
import Libs.Std exposing (dictFromList)
import Models exposing (Menu, Model(..), Msg(..), UiState, conf)
import Models.Schema exposing (Schema, Table, TableId)
import Models.Utils exposing (Position, Size)
import Update exposing (dragConfig, dragItem, hideAllTables, hideTable, showAllTables, showTable, zoomCanvas)
import View exposing (viewApp)
import Views.Helpers exposing (formatHttpError)



-- MAIN: program entry point \o/


main : Program () Model Msg
main =
    Browser.document { init = init, update = update, subscriptions = subscriptions, view = view }


init : () -> ( Model, Cmd Msg )
init _ =
    ( Loading, loadData "/tests/resources/schema.json" )



-- UPDATE: each case should be one line or call a function in Update file


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model ) of
        ( GotData (Ok tables), Loading ) ->
            ( HasData tables, getSizes tables )

        ( GotData (Ok _), _ ) ->
            ( Failure "can't GotData when not Loading", Cmd.none )

        ( GotData (Err e), _ ) ->
            ( Failure (formatHttpError e), Cmd.none )

        ( GotSizes (Ok ( tableSizes, windowSize )), HasData _ ) ->
            ( HasSizes tableSizes windowSize, renderLayout tableSizes windowSize )

        ( GotSizes (Ok _), _ ) ->
            ( Failure "can't GotSizes when not HasData", Cmd.none )

        ( GotSizes (Err (Dom.NotFound e)), _ ) ->
            ( Failure ("Size not found for '" ++ e ++ "' id"), Cmd.none )

        ( GotLayout schema zoom pan, HasSizes _ _ ) ->
            ( Success schema (Menu (Position 0 0)) (UiState zoom pan Nothing Draggable.init), Cmd.none )

        ( GotLayout _ _ _, _ ) ->
            ( Failure "can't GotLayout when not HasSizes", Cmd.none )

        ( StartDragging id, Success schema menu appState ) ->
            ( Success schema menu { appState | id = Just id }, Cmd.none )

        ( StartDragging _, _ ) ->
            ( Failure "can't StartDragging when not Success", Cmd.none )

        ( StopDragging, Success schema menu appState ) ->
            ( Success schema menu { appState | id = Nothing }, Cmd.none )

        ( StopDragging, _ ) ->
            ( Failure "can't StopDragging when not Success", Cmd.none )

        ( OnDragBy delta, Success schema menu appState ) ->
            ( dragItem schema menu appState delta, Cmd.none )

        ( OnDragBy _, _ ) ->
            ( Failure "can't OnDragBy when not Success", Cmd.none )

        ( DragMsg dragMsg, Success schema menu appState ) ->
            Tuple.mapFirst (\newDrag -> Success schema menu newDrag) (Draggable.update dragConfig dragMsg appState)

        ( DragMsg _, _ ) ->
            ( Failure "can't DragMsg when not Success", Cmd.none )

        ( Zoom zoom, Success schema menu appState ) ->
            ( zoomCanvas schema menu appState zoom, Cmd.none )

        ( Zoom _, _ ) ->
            ( Failure "can't Zoom when not Success", Cmd.none )

        ( HideTable id, Success schema menu appState ) ->
            ( hideTable schema menu appState id, Cmd.none )

        ( HideTable _, _ ) ->
            ( Failure "can't HideTable when not Success", Cmd.none )

        ( ShowTable id, Success schema menu appState ) ->
            ( showTable schema menu appState id, Cmd.none )

        ( ShowTable _, _ ) ->
            ( Failure "can't ShowTable when not Success", Cmd.none )

        ( HideAllTables, Success schema menu appState ) ->
            ( hideAllTables schema menu appState, Cmd.none )

        ( HideAllTables, _ ) ->
            ( Failure "can't HideAllTables when not Success", Cmd.none )

        ( ShowAllTables, Success schema menu appState ) ->
            ( showAllTables schema menu appState, Cmd.none )

        ( ShowAllTables, _ ) ->
            ( Failure "can't ShowAllTables when not Success", Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    case model of
        Success _ _ { drag } ->
            Draggable.subscriptions DragMsg drag

        _ ->
            Sub.none



-- VIEW: each case should be one line


view : Model -> Browser.Document Msg
view model =
    { title = "Schema Viz"
    , body =
        [ Icon.css
        , case model of
            Failure e ->
                text ("Oooups an error happened, " ++ e)

            Loading ->
                viewApp fakeMenu (fakeSchema []) (Just "Loading...") 1 (Position 0 0)

            HasData tables ->
                viewApp fakeMenu (fakeSchema tables) (Just ("Rendering " ++ String.fromInt (List.length tables) ++ " tables...")) 1 (Position 0 0)

            HasSizes tables _ ->
                viewApp fakeMenu (fakeSchema (List.map (\( t, i, _ ) -> ( t, i )) tables)) (Just ("Positioning " ++ String.fromInt (List.length tables) ++ " tables...")) 1 (Position 0 0)

            Success schema menu drag ->
                viewApp menu schema Nothing drag.zoom drag.position
        ]
    }


fakeMenu : Menu
fakeMenu =
    { position = Position 0 0 }


fakeSchema : List ( JsonTable, TableId ) -> Schema
fakeSchema tables =
    { tables = dictFromList .id (List.map fakeTable tables)
    , relations = []
    }


fakeTable : ( JsonTable, TableId ) -> Table
fakeTable ( table, id ) =
    buildTable 0 table id (Size 0 0) (Position 0 0) conf.colors.grey
