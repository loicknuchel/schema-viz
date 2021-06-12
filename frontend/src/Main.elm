module Main exposing (..)

import Browser
import Browser.Dom as Dom
import Draggable
import Html exposing (Html, text)
import Http
import Libs.SchemaDecoders exposing (Schema, Table, schemaDecoder)
import Libs.Std exposing (genChoose, genSequence)
import Models exposing (Color, DragState, Menu, Model(..), Msg(..), Position, Size, SizedSchema, SizedTable, UiSchema, UiTable, WindowSize, conf)
import Random
import Task exposing (Task)
import Update exposing (dragConfig, dragItem, zoomCanvas)
import View exposing (formatHttpError, formatTableId, sizedTableToUiTable, tableToUiTable, viewApp)



-- MAIN


main : Program () Model Msg
main =
    Browser.element { init = init, update = update, subscriptions = subscriptions, view = view }


init : () -> ( Model, Cmd Msg )
init _ =
    ( Loading, loadSchema "/tests/resources/schema.json" )



-- UPDATE: each case should be one line or call a function in Update file


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model ) of
        ( GotSchema (Ok schema), _ ) ->
            ( HasData schema, getSizes schema )

        ( GotSizes (Ok ( sizedSchema, size )), _ ) ->
            ( HasSizes sizedSchema, renderLayout sizedSchema size )

        ( GotLayout schema zoom pan, _ ) ->
            ( Success schema (Menu "menu" (Position 0 0)) (DragState zoom pan Nothing Draggable.init), Cmd.none )

        ( StartDragging id, Success schema menu drag ) ->
            ( Success schema menu { drag | id = Just id }, Cmd.none )

        ( StopDragging, Success schema menu drag ) ->
            ( Success schema menu { drag | id = Nothing }, Cmd.none )

        ( OnDragBy delta, Success schema menu drag ) ->
            ( dragItem schema menu drag delta, Cmd.none )

        ( DragMsg dragMsg, Success schema menu drag ) ->
            Tuple.mapFirst (\newDrag -> Success schema menu newDrag) (Draggable.update dragConfig dragMsg drag)

        ( Zoom zoom, Success schema menu drag ) ->
            ( zoomCanvas schema menu drag zoom, Cmd.none )

        ( GotSchema (Err e), _ ) ->
            ( Failure (formatHttpError e), Cmd.none )

        ( GotSizes (Err (Dom.NotFound e)), _ ) ->
            ( Failure ("Size not found for '" ++ e ++ "' id"), Cmd.none )

        ( StartDragging _, _ ) ->
            ( Failure "Can't StartDragging when not Success", Cmd.none )

        ( StopDragging, _ ) ->
            ( Failure "Can't StopDragging when not Success", Cmd.none )

        ( OnDragBy _, _ ) ->
            ( Failure "Can't OnDragBy when not Success", Cmd.none )

        ( DragMsg _, _ ) ->
            ( Failure "Can't DragMsg when not Success", Cmd.none )

        ( Zoom _, _ ) ->
            ( Failure "Can't Zoom when not Success", Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    case model of
        Success _ _ { drag } ->
            Draggable.subscriptions DragMsg drag

        _ ->
            Sub.none



-- VIEW: each case should be one line


view : Model -> Html Msg
view model =
    case model of
        Failure e ->
            text ("Unable to load your schema: " ++ e)

        Loading ->
            text "Loading..."

        HasData schema ->
            viewApp 1 (Position 0 0) Nothing (List.map tableToUiTable schema.tables)

        HasSizes schema ->
            viewApp 1 (Position 0 0) Nothing (List.map sizedTableToUiTable schema.tables)

        Success schema menu drag ->
            viewApp drag.zoom drag.position (Just menu) schema.tables



-- MESSAGE BUILDERS


loadSchema : String -> Cmd Msg
loadSchema url =
    Http.get { url = url, expect = Http.expectJson GotSchema schemaDecoder }


getSizes : Schema -> Cmd Msg
getSizes schema =
    Task.attempt GotSizes (allSizes schema)


renderLayout : SizedSchema -> Size -> Cmd Msg
renderLayout schema size =
    Random.generate (\uiSchema -> GotLayout uiSchema 1 (Position 0 0)) (uiSchemaGen schema size)



-- GET SIZES


allSizes : Schema -> Task Dom.Error ( SizedSchema, WindowSize )
allSizes schema =
    Task.map2 (\sizedSchema size -> ( sizedSchema, size )) (schemaSize schema) windowSize


schemaSize : Schema -> Task Dom.Error SizedSchema
schemaSize schema =
    Task.map (\tables -> SizedSchema tables) (tablesSize schema.tables)


tablesSize : List Table -> Task Dom.Error (List SizedTable)
tablesSize tables =
    Task.sequence (List.map (\table -> tableSize table) tables)


tableSize : Table -> Task Dom.Error SizedTable
tableSize table =
    Task.map (\e -> SizedTable (formatTableId table) table (Size e.element.width e.element.height)) (Dom.getElement (formatTableId table))


windowSize : Task x WindowSize
windowSize =
    Task.map (\viewport -> Size viewport.viewport.width viewport.viewport.height) Dom.getViewport



-- RANDOM GENERATORS


uiSchemaGen : SizedSchema -> Size -> Random.Generator UiSchema
uiSchemaGen schema size =
    Random.map (\tables -> UiSchema tables) (uiTablesGen schema.tables size)


uiTablesGen : List SizedTable -> Size -> Random.Generator (List UiTable)
uiTablesGen tables size =
    genSequence (List.map (\table -> uiTableGen table size) tables)


uiTableGen : SizedTable -> Size -> Random.Generator UiTable
uiTableGen table size =
    Random.map2 (\color pos -> UiTable table.id table.sql table.size color pos) colorGen (positionGen table size)


positionGen : SizedTable -> Size -> Random.Generator Position
positionGen table size =
    Random.map2 (\w h -> Position w h) (Random.float 0 (size.width - table.size.width)) (Random.float 0 (size.height - table.size.height))


colorGen : Random.Generator Color
colorGen =
    case conf.colors of
        { red, pink, orange, yellow, green, blue, darkBlue, purple, grey } ->
            genChoose ( red, [ pink, orange, yellow, green, blue, darkBlue, purple, grey ] )
