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
import Update exposing (dragConfig, dragItem, hideTable, zoomCanvas)
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

        ( StartDragging id, Success schema menu drag ) ->
            ( Success schema menu { drag | id = Just id }, Cmd.none )

        ( StartDragging _, _ ) ->
            ( Failure "can't StartDragging when not Success", Cmd.none )

        ( StopDragging, Success schema menu drag ) ->
            ( Success schema menu { drag | id = Nothing }, Cmd.none )

        ( StopDragging, _ ) ->
            ( Failure "can't StopDragging when not Success", Cmd.none )

        ( OnDragBy delta, Success schema menu drag ) ->
            ( dragItem schema menu drag delta, Cmd.none )

        ( OnDragBy _, _ ) ->
            ( Failure "can't OnDragBy when not Success", Cmd.none )

        ( DragMsg dragMsg, Success schema menu drag ) ->
            Tuple.mapFirst (\newDrag -> Success schema menu newDrag) (Draggable.update dragConfig dragMsg drag)

        ( DragMsg _, _ ) ->
            ( Failure "can't DragMsg when not Success", Cmd.none )

        ( Zoom zoom, Success schema menu drag ) ->
            ( zoomCanvas schema menu drag zoom, Cmd.none )

        ( Zoom _, _ ) ->
            ( Failure "can't Zoom when not Success", Cmd.none )

        ( HideTable id, Success schema menu drag ) ->
            ( hideTable schema menu drag id, Cmd.none )

        ( HideTable _, _ ) ->
            ( Failure "can't HideTable when not Success", Cmd.none )



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
                text "Loading..."

            HasData tables ->
                viewApp 1 (Position 0 0) Nothing (fakeSchema tables)

            HasSizes _ _ ->
                text "Rendering..."

            Success schema menu drag ->
                viewApp drag.zoom drag.position (Just menu) schema
        ]
    }


fakeSchema : List ( JsonTable, TableId ) -> Schema
fakeSchema tables =
    { tables = dictFromList .id (List.map fakeTable tables)
    , relations = []
    }


fakeTable : ( JsonTable, TableId ) -> Table
fakeTable ( table, id ) =
    buildTable table id (Size 0 0) (Position 0 0) conf.colors.grey
