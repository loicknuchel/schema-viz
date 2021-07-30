module Pages.App exposing (Model, Msg, page)

import Conf exposing (conf)
import Dict
import Draggable
import Gen.Params.App exposing (Params)
import Libs.Bool as B
import Page
import PagesComponents.App.Commands.GetTime exposing (getTime)
import PagesComponents.App.Commands.GetZone exposing (getZone)
import PagesComponents.App.Commands.LoadSample exposing (loadSample)
import PagesComponents.App.Models as Models exposing (Model, Msg(..), initConfirm, initHover, initSwitch, initTimeInfo)
import PagesComponents.App.Updates exposing (dragConfig, dragItem, removeElement, updateSizes)
import PagesComponents.App.Updates.Canvas exposing (fitCanvas, handleWheel, zoomCanvas)
import PagesComponents.App.Updates.Helpers exposing (decodeErrorToHtml, setCanvas, setDictTable, setLayout, setSchema, setSchemaWithCmd, setSwitch, setTables, setTime)
import PagesComponents.App.Updates.Layout exposing (createLayout, deleteLayout, loadLayout, updateLayout)
import PagesComponents.App.Updates.Schema exposing (createSampleSchema, createSchema, useSchema)
import PagesComponents.App.Updates.Table exposing (hideAllTables, hideColumn, hideColumns, hideTable, showAllTables, showColumn, showColumns, showTable, showTables, sortColumns)
import PagesComponents.App.View exposing (viewApp)
import PagesComponents.Containers as Containers
import Ports exposing (JsMsg(..), activateTooltipsAndPopovers, click, dropSchema, hideOffcanvas, listenHotkeys, loadSchemas, observeSize, onJsMessage, readFile, saveSchema, showModal, toastError, toastInfo, toastWarning)
import Request
import Shared
import Time
import View exposing (View)


page : Shared.Model -> Request.With Params -> Page.With Model Msg
page _ _ =
    Page.element
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }


type alias Model =
    Models.Model


type alias Msg =
    Models.Msg



-- INIT


init : ( Model, Cmd Msg )
init =
    ( { time = initTimeInfo
      , switch = initSwitch
      , storedSchemas = []
      , schema = Nothing
      , search = ""
      , newLayout = Nothing
      , confirm = initConfirm
      , sizes = Dict.empty
      , dragId = Nothing
      , drag = Draggable.init
      , hover = initHover
      }
    , Cmd.batch
        [ observeSize conf.ids.erd
        , showModal conf.ids.schemaSwitchModal
        , loadSchemas
        , getZone
        , getTime
        , listenHotkeys conf.hotkeys
        ]
    )



-- UPDATE


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

        ShowTables ids ->
            model |> setSchemaWithCmd (showTables ids)

        InitializedTable id position ->
            ( model |> setSchema (setLayout (setDictTable id (\t -> { t | position = position }))), Cmd.none )

        HideAllTables ->
            ( model |> setSchema (setLayout hideAllTables), Cmd.none )

        ShowAllTables ->
            model |> setSchemaWithCmd showAllTables

        HideColumn { table, column } ->
            ( model |> setSchema (setLayout (hideColumn table column)), Cmd.none )

        ShowColumn { table, column } ->
            ( model |> setSchema (setLayout (showColumn table column)), activateTooltipsAndPopovers )

        SortColumns id kind ->
            ( model |> setSchema (sortColumns id kind), activateTooltipsAndPopovers )

        HideColumns id kind ->
            ( model |> setSchema (hideColumns id kind), Cmd.none )

        ShowColumns id kind ->
            ( model |> setSchema (showColumns id kind), activateTooltipsAndPopovers )

        HoverTable t ->
            ( { model | hover = model.hover |> (\h -> { h | table = t }) }, Cmd.none )

        HoverColumn c ->
            ( { model | hover = model.hover |> (\h -> { h | column = c }) }, Cmd.none )

        OnWheel event ->
            ( model |> setSchema (setLayout (setCanvas (handleWheel event))), Cmd.none )

        Zoom delta ->
            ( model |> setSchema (setLayout (setCanvas (zoomCanvas model.sizes delta))), Cmd.none )

        FitContent ->
            ( model |> setSchema (setLayout (fitCanvas model.sizes)), Cmd.none )

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

        JsMessage (HotkeyUsed "focus-search") ->
            ( model, click conf.ids.searchInput )

        JsMessage (HotkeyUsed "remove") ->
            ( model, removeElement model )

        JsMessage (HotkeyUsed "save") ->
            ( model, model.schema |> Maybe.map (\s -> Cmd.batch [ saveSchema s, toastInfo "Schema saved" ]) |> Maybe.withDefault (toastWarning "No schema to save") )

        JsMessage (HotkeyUsed "help") ->
            ( model, showModal conf.ids.helpModal )

        JsMessage (HotkeyUsed hotkey) ->
            ( model, toastInfo ("Shortcut <b>" ++ hotkey ++ "</b> is not implemented yet :(") )

        JsMessage (Error err) ->
            ( model, toastError ("Unable to decode JavaScript message:<br>" ++ decodeErrorToHtml err) )

        Noop ->
            ( model, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Draggable.subscriptions DragMsg model.drag
        , Time.every (10 * 1000) TimeChanged
        , onJsMessage JsMessage
        ]



-- VIEW


view : Model -> View Msg
view model =
    { title = "Schema Viz"
    , body = Containers.root (viewApp model)
    }
