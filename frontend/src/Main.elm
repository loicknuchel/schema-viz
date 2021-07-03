module Main exposing (main)

import AssocList as Dict
import Browser
import Commands.FetchData exposing (loadData)
import Conf exposing (conf)
import Draggable
import Libs.Std exposing (cond, set, setState)
import Mappers.SchemaMapper exposing (buildSchemaFromJson)
import Models exposing (Flags, Model, Msg(..))
import Models.Schema exposing (TableStatus(..))
import Models.Utils exposing (Position, Size)
import Ports exposing (activateTooltipsAndPopovers, fileRead, hideModal, hideOffcanvas, observeSize, readFile, showModal, sizesReceiver, toastError, toastInfo)
import Update exposing (createLayout, deleteLayout, dragConfig, dragItem, hideAllTables, hideColumn, hideTable, loadLayout, showAllTables, showColumn, showTable, updateLayout, updateSchema, updateSizes, visitTable, visitTables, zoomCanvas)
import View exposing (viewApp)
import Views.Helpers exposing (formatHttpError)


sampleDataUrl : String
sampleDataUrl =
    "/tests/resources/schema.json"



-- MAIN: program entry point \o/


main : Program Flags Model Msg
main =
    Browser.document { init = init, update = update, view = view, subscriptions = subscriptions }


init : Flags -> ( Model, Cmd Msg )
init _ =
    ( { state = { search = "", newLayout = Nothing, currentLayout = Nothing, dragId = Nothing, drag = Draggable.init }
      , canvas = { size = Size 0 0, zoom = 1, position = Position 0 0 }
      , schema = { tables = Dict.empty, relations = [], layouts = [] }
      }
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

        FileSelected file ->
            -- TODO: add loading animation
            ( model, readFile file )

        FileDragOver _ _ ->
            -- TODO: add drop zone hover + warn if multiple files
            ( model, Cmd.none )

        FileDragLeave ->
            -- TODO: remove drop zone hover
            ( model, Cmd.none )

        FileDropped file _ ->
            -- TODO display error on multiple files, add loading animation
            ( model, readFile file )

        FileRead ( file, content ) ->
            ( updateSchema file content model, Cmd.batch [ hideModal conf.ids.schemaSwitchModal, toastInfo ("<b>" ++ file.name ++ "</b> is loaded.<br>Use the search bar to discover it") ] )

        LoadSampleData ->
            ( model, loadData sampleDataUrl )

        GotData (Ok tables) ->
            ( { model | schema = buildSchemaFromJson tables }, Cmd.batch [ hideModal conf.ids.schemaSwitchModal, toastInfo "<b>Sample schema</b> loaded.<br>Use the search bar to explore it" ] )

        GotData (Err e) ->
            ( model, toastError ("Can't load schema: " ++ formatHttpError e) )

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
