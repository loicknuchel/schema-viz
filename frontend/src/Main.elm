module Main exposing (main)

import Browser
import Commands.FetchSample exposing (loadSample)
import Conf exposing (conf)
import Draggable
import Libs.Std exposing (cond, set, setState)
import Models exposing (Flags, Model, Msg(..), initModel)
import Models.Schema exposing (TableStatus(..))
import Ports exposing (activateTooltipsAndPopovers, fileRead, hideOffcanvas, observeSize, readFile, showModal, sizesReceiver)
import Update exposing (createLayout, deleteLayout, dragConfig, dragItem, hideAllTables, hideColumn, hideTable, loadLayout, showAllTables, showColumn, showTable, updateLayout, updateSizes, useSampleSchema, useSchema, visitTable, visitTables, zoomCanvas)
import View exposing (viewApp)



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
        ]
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        -- each case should be one line or call a function in Update file
        ChangeSchema ->
            ( model, Cmd.batch [ showModal conf.ids.schemaSwitchModal, hideOffcanvas conf.ids.menu ] )

        FileDragOver _ _ ->
            ( model, Cmd.none )

        FileDragLeave ->
            ( model, Cmd.none )

        FileDropped file _ ->
            ( { model | switch = model.switch |> set (\s -> { s | loading = True }) }, readFile file )

        FileSelected file ->
            ( { model | switch = model.switch |> set (\s -> { s | loading = True }) }, readFile file )

        FileRead ( file, content ) ->
            useSchema file content model

        LoadSampleData sampleName ->
            ( model, loadSample sampleName )

        GotSampleData name path response ->
            useSampleSchema name path response model

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

        SizesChanged sizes ->
            updateSizes sizes model

        HideAllTables ->
            ( { model | schema = hideAllTables model.schema }, Cmd.none )

        ShowAllTables ->
            showAllTables model

        HideColumn ref ->
            ( { model | schema = model.schema |> visitTable ref.table (\table -> { table | columns = table.columns |> hideColumn ref.column }) }, activateTooltipsAndPopovers () )

        ShowColumn ref index ->
            ( { model | schema = model.schema |> visitTable ref.table (\table -> { table | columns = table.columns |> showColumn ref.column index }) }, activateTooltipsAndPopovers () )

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
            ( createLayout name model, activateTooltipsAndPopovers () )

        LoadLayout name ->
            loadLayout name model

        UpdateLayout name ->
            ( updateLayout name model, Cmd.none )

        DeleteLayout name ->
            ( deleteLayout name model, Cmd.none )

        Noop ->
            ( model, Cmd.none )


view : Model -> Browser.Document Msg
view model =
    { title = "Schema Viz", body = viewApp model }


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Draggable.subscriptions DragMsg model.state.drag
        , sizesReceiver SizesChanged
        , fileRead FileRead
        ]
