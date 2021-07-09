module Main exposing (main)

import Browser
import Commands.FetchSample exposing (loadSample)
import Conf exposing (conf)
import Draggable
import Libs.Std exposing (cond, set, setState)
import Models exposing (Flags, Model, Msg(..), initConfirm, initModel)
import Models.Schema exposing (TableStatus(..))
import Ports exposing (JsMsg(..), activateTooltipsAndPopovers, dropSchema, hideOffcanvas, loadSchemas, observeSize, onJsMessage, readFile, showModal, toastError)
import Update exposing (createLayout, createSampleSchema, createSchema, deleteLayout, dragConfig, dragItem, hideAllTables, hideColumn, hideTable, loadLayout, showAllTables, showColumn, showTable, updateLayout, updateSizes, useSchema, visitTable, visitTables, zoomCanvas)
import View exposing (viewApp)
import Views.Helpers exposing (decodeErrorToHtml)



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
        ]
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        -- each case should be one line or call a function in Update file
        ChangeSchema ->
            ( model, Cmd.batch [ hideOffcanvas conf.ids.menu, showModal conf.ids.schemaSwitchModal, loadSchemas ] )

        FileDragOver _ _ ->
            ( model, Cmd.none )

        FileDragLeave ->
            ( model, Cmd.none )

        FileDropped file _ ->
            ( { model | switch = model.switch |> set (\s -> { s | loading = True }) }, readFile file )

        FileSelected file ->
            ( { model | switch = model.switch |> set (\s -> { s | loading = True }) }, readFile file )

        LoadSampleData sampleName ->
            ( model, loadSample sampleName )

        GotSampleData name path response ->
            createSampleSchema name path response model

        DeleteSchema schema ->
            ( { model | storedSchemas = model.storedSchemas |> List.filter (\s -> not (s.name == schema.name)) }, dropSchema schema )

        UseSchema schema ->
            useSchema schema model

        ChangedSearch search ->
            ( { model | state = model.state |> set (\state -> { state | search = search }) }, Cmd.none )

        SelectTable id ->
            ( { model | schema = model.schema |> visitTables (\table -> table |> setState (\state -> { state | selected = cond (table.id == id) (\_ -> not state.selected) (\_ -> False) })) }, Cmd.none )

        HideTable id ->
            ( { model | schema = model.schema |> hideTable id }, Cmd.none )

        ShowTable id ->
            showTable model id

        InitializedTable id size position ->
            ( { model | schema = model.schema |> visitTable id (setState (\state -> { state | status = Shown, size = size, position = position })) }, Cmd.none )

        HideAllTables ->
            ( { model | schema = hideAllTables model.schema }, Cmd.none )

        ShowAllTables ->
            showAllTables model

        HideColumn ref ->
            ( { model | schema = model.schema |> visitTable ref.table (\table -> { table | columns = table.columns |> hideColumn ref.column }) }, activateTooltipsAndPopovers )

        ShowColumn ref index ->
            ( { model | schema = model.schema |> visitTable ref.table (\table -> { table | columns = table.columns |> showColumn ref.column index }) }, activateTooltipsAndPopovers )

        Zoom zoom ->
            ( { model | canvas = zoomCanvas zoom model.canvas }, Cmd.none )

        DragMsg dragMsg ->
            Tuple.mapFirst (\newState -> { model | state = newState }) (Draggable.update dragConfig dragMsg model.state)

        StartDragging id ->
            ( { model | state = model.state |> set (\state -> { state | dragId = Just id }) }, Cmd.none )

        StopDragging ->
            ( { model | state = model.state |> set (\state -> { state | dragId = Nothing }) }, Cmd.none )

        OnDragBy delta ->
            dragItem model delta

        NewLayout name ->
            ( model |> setState (\s -> { s | newLayout = cond (String.length name == 0) (\_ -> Nothing) (\_ -> Just name) }), Cmd.none )

        CreateLayout name ->
            createLayout name model

        LoadLayout name ->
            loadLayout name model

        UpdateLayout name ->
            updateLayout name model

        DeleteLayout name ->
            deleteLayout name model

        OpenConfirm confirm ->
            ( { model | confirm = confirm }, showModal conf.ids.confirm )

        OnConfirm answer cmd ->
            if answer then
                ( { model | confirm = initConfirm }, cmd )

            else
                ( { model | confirm = initConfirm }, Cmd.none )

        JsMessage (SchemasLoaded ( errors, schemas )) ->
            ( { model | storedSchemas = schemas }, Cmd.batch (errors |> List.map (\( name, err ) -> toastError ("Unable to read schema <b>" ++ name ++ "</b>:<br>" ++ decodeErrorToHtml err))) )

        JsMessage (FileRead file content) ->
            createSchema file content model

        JsMessage (SizesChanged sizes) ->
            updateSizes sizes model

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
        [ Draggable.subscriptions DragMsg model.state.drag
        , onJsMessage JsMessage
        ]
