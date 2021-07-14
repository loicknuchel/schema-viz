module Main exposing (main)

import AssocList as Dict
import Browser
import Commands.FetchSample exposing (loadSample)
import Conf exposing (conf)
import Draggable
import Libs.Bool as B
import Models exposing (Flags, JsMsg(..), Model, Msg(..), initConfirm, initModel)
import Ports exposing (activateTooltipsAndPopovers, dropSchema, hideOffcanvas, loadSchemas, observeSize, onJsMessage, readFile, showModal, toastError)
import Task
import Time
import Update exposing (dragConfig, dragItem, updateSizes, zoomCanvas)
import Updates.Helpers exposing (decodeErrorToHtml, setCanvas, setDictTable, setLayout, setSchema, setSchemaWithCmd, setSwitch, setTables, setTime)
import Updates.Layout exposing (createLayout, deleteLayout, loadLayout, updateLayout)
import Updates.Schema exposing (createSampleSchema, createSchema, useSchema)
import Updates.Table exposing (hideAllTables, hideColumn, hideTable, showAllTables, showColumn, showTable)
import View exposing (viewApp)



-- deps = { to = {} } => can depend on anything, nothing should depend in it
-- MAIN: program entry point \o/


main : Program Flags Model Msg
main =
    Browser.document { init = init, update = update, view = view, subscriptions = subscriptions }


init : Flags -> ( Model, Cmd Msg )
init _ =
    ( initModel
    , Cmd.batch
        [ observeSize conf.ids.erd
        , showModal conf.ids.schemaSwitchModal
        , loadSchemas
        , getZone
        , getTime
        ]
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        -- each case should be one line or call a function in Update file
        JsMessage (SizesChanged sizes) ->
            updateSizes sizes model

        TimeChanged time ->
            ( model |> setTime (\t -> { t | now = time }), Cmd.none )

        ZoneChanged zone ->
            ( model |> setTime (\t -> { t | zone = zone }), Cmd.none )

        ChangeSchema ->
            ( model, Cmd.batch [ hideOffcanvas conf.ids.menu, showModal conf.ids.schemaSwitchModal, loadSchemas ] )

        JsMessage (SchemasLoaded ( errors, schemas )) ->
            ( { model | storedSchemas = schemas }, Cmd.batch (errors |> List.map (\( name, err ) -> toastError ("Unable to read schema <b>" ++ name ++ "</b>:<br>" ++ decodeErrorToHtml err))) )

        FileDragOver _ _ ->
            ( model, Cmd.none )

        FileDragLeave ->
            ( model, Cmd.none )

        FileDropped file _ ->
            ( model |> setSwitch (\s -> { s | loading = True }), readFile file )

        FileSelected file ->
            ( model |> setSwitch (\s -> { s | loading = True }), readFile file )

        JsMessage (FileRead now file content) ->
            model |> createSchema now file content

        LoadSampleData sampleName ->
            ( model, loadSample sampleName )

        GotSampleData now name path response ->
            model |> createSampleSchema now name path response

        DeleteSchema schema ->
            ( { model | storedSchemas = model.storedSchemas |> List.filter (\s -> not (s.id == schema.id)) }, dropSchema schema )

        UseSchema schema ->
            model |> useSchema schema

        ChangedSearch search ->
            ( { model | search = search }, Cmd.none )

        SelectTable id ->
            ( model |> setSchema (setLayout (setTables (Dict.map (\i t -> { t | selected = B.cond (i == id) (not t.selected) False })))), Cmd.none )

        HideTable id ->
            ( model |> setSchema (setLayout (hideTable id)), Cmd.none )

        ShowTable id ->
            model |> setSchemaWithCmd (showTable id)

        InitializedTable id position ->
            ( model |> setSchema (setLayout (setDictTable id (\t -> { t | position = position }))), Cmd.none )

        HideAllTables ->
            ( model |> setSchema (setLayout hideAllTables), Cmd.none )

        ShowAllTables ->
            model |> setSchemaWithCmd showAllTables

        HideColumn { table, column } ->
            ( model |> setSchema (setLayout (hideColumn table column)), Cmd.none )

        ShowColumn { table, column } index ->
            ( model |> setSchema (setLayout (showColumn table column index)), activateTooltipsAndPopovers )

        Zoom zoom ->
            ( model |> setSchema (setLayout (setCanvas (zoomCanvas zoom))), Cmd.none )

        DragMsg dragMsg ->
            model |> Draggable.update dragConfig dragMsg

        StartDragging id ->
            ( { model | dragId = Just id }, Cmd.none )

        StopDragging ->
            ( { model | dragId = Nothing }, Cmd.none )

        OnDragBy delta ->
            dragItem model delta

        NewLayout name ->
            ( { model | newLayout = B.cond (String.length name == 0) Nothing (Just name) }, Cmd.none )

        CreateLayout name ->
            { model | newLayout = Nothing } |> setSchemaWithCmd (createLayout name)

        LoadLayout name ->
            model |> setSchemaWithCmd (loadLayout name)

        UpdateLayout name ->
            model |> setSchemaWithCmd (updateLayout name)

        DeleteLayout name ->
            model |> setSchemaWithCmd (deleteLayout name)

        OpenConfirm confirm ->
            ( { model | confirm = confirm }, showModal conf.ids.confirm )

        OnConfirm answer cmd ->
            ( { model | confirm = initConfirm }, B.cond answer cmd Cmd.none )

        JsMessage (Error err) ->
            ( model, toastError ("Unable to decode JavaScript message:<br>" ++ decodeErrorToHtml err) )

        Noop ->
            ( model, Cmd.none )


view : Model -> Browser.Document Msg
view model =
    { title = "Schema Viz", body = viewApp model }


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Draggable.subscriptions DragMsg model.drag
        , Time.every (10 * 1000) TimeChanged
        , onJsMessage JsMessage
        ]



-- other


getZone : Cmd Msg
getZone =
    Task.perform ZoneChanged Time.here


getTime : Cmd Msg
getTime =
    Task.perform TimeChanged Time.now
