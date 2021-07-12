module Update exposing (createLayout, createSampleSchema, createSchema, decodeErrorToHtml, deleteLayout, dragConfig, dragItem, hideAllTables, hideColumn, hideTable, loadLayout, showAllTables, showColumn, showTable, updateLayout, updateSizes, useSchema, visitTable, visitTables, zoomCanvas)

import AssocList as Dict exposing (Dict)
import Commands.InitializeTable exposing (initializeTable)
import Conf exposing (conf)
import Draggable
import Draggable.Events exposing (onDragBy, onDragEnd, onDragStart)
import FileValue exposing (File)
import Http exposing (Error(..))
import Json.Decode as Decode
import JsonFormats.SchemaFormat exposing (decodeSchema)
import Libs.Bool as B
import Libs.Dict as D
import Libs.Html.Events exposing (WheelEvent)
import Libs.List as L
import Libs.Maybe as M
import Libs.Models exposing (FileContent, FileName)
import Libs.Result as R
import Libs.Std exposing (set, setSchema, setState)
import Libs.Task as T
import Mappers.SchemaMapper exposing (buildSchemaFromSql)
import Models exposing (Canvas, DragId, Errors, Model, Msg(..), initSwitch)
import Models.Schema exposing (Column, ColumnName, ColumnProps, FileInfo, Layout, LayoutName, Schema, SchemaId, SchemaState, Table, TableId, TableProps, TableStatus(..), Tables, formatTableId, parseTableId)
import Models.Utils exposing (Area, Position, SizeChange, ZoomLevel)
import Ports exposing (activateTooltipsAndPopovers, click, hideModal, observeTableSize, observeTablesSize, saveSchema, toastError, toastInfo)
import SqlParser.SchemaParser exposing (parseSchema)
import Time



-- deps = { to = { only = [ "Libs.*", "Models.*", "Commands.*", "Conf", "JsonFormats.*", "Mappers.*", "Ports", "SqlParser.*" ] } }
-- utility methods to get the update case down to one line


useSchema : Schema -> Model -> ( Model, Cmd Msg )
useSchema schema model =
    loadSchema model ( [], Just schema )


createSchema : Time.Posix -> File -> FileContent -> Model -> ( Model, Cmd Msg )
createSchema now file content model =
    buildSchema now (model.storedSchemas |> List.map .id) file.name file.name (Just { name = file.name, lastModified = file.lastModified }) content |> loadSchema model


createSampleSchema : Time.Posix -> SchemaId -> FileName -> Result Http.Error FileContent -> Model -> ( Model, Cmd Msg )
createSampleSchema now id path response model =
    response
        |> R.fold
            (\err -> ( [ "Can't load '" ++ id ++ "': " ++ formatHttpError err ], Nothing ))
            (buildSchema now (model.storedSchemas |> List.map .id) id path Nothing)
        |> loadSchema model


loadSchema : Model -> ( Errors, Maybe Schema ) -> ( Model, Cmd Msg )
loadSchema model ( errs, schema ) =
    schema
        |> Maybe.map
            (\s ->
                ( { model | switch = initSwitch, schema = Just s }
                , Cmd.batch
                    ((errs |> List.map toastError)
                        ++ [ toastInfo ("<b>" ++ s.id ++ "</b> loaded.<br>Use the search bar to explore it")
                           , hideModal conf.ids.schemaSwitchModal
                           , saveSchema s
                           ]
                        ++ (if Dict.size s.tables < 10 then
                                [ T.send ShowAllTables ]

                            else
                                [ click conf.ids.searchInput ]
                           )
                    )
                )
            )
        |> Maybe.withDefault ( { model | switch = initSwitch }, Cmd.batch (errs |> List.map toastError) )


buildSchema : Time.Posix -> List SchemaId -> SchemaId -> FileName -> Maybe FileInfo -> FileContent -> ( Errors, Maybe Schema )
buildSchema now takenIds id path file content =
    if path |> String.endsWith ".sql" then
        parseSchema path content |> Tuple.mapSecond (\s -> Just (buildSchemaFromSql takenIds id { created = now, updated = now, file = file } s))

    else if path |> String.endsWith ".json" then
        Decode.decodeString (decodeSchema takenIds) content
            |> R.fold
                (\e -> ( [ "⚠️ Error in <b>" ++ path ++ "</b> ⚠️<br>" ++ decodeErrorToHtml e ], Nothing ))
                (\schema -> ( [], Just schema ))

    else
        ( [ "Invalid file (" ++ path ++ "), expected .sql or .json one" ], Nothing )


hideTable : TableId -> Schema -> Schema
hideTable id schema =
    schema |> visitTable id (setState (\state -> { state | status = Hidden }))


showTable : Schema -> TableId -> ( Schema, Cmd Msg )
showTable schema id =
    case getTable id schema |> Maybe.map (\t -> t.state.status) of
        Just Uninitialized ->
            -- race condition problem when observe is performed before table is shown :(
            ( schema |> visitTable id (setState (\state -> { state | status = Initializing })), Cmd.batch [ observeTableSize id, activateTooltipsAndPopovers ] )

        Just Initializing ->
            ( schema, Cmd.none )

        Just Hidden ->
            ( schema |> visitTable id (setState (\state -> { state | status = Shown, selected = False })), Cmd.batch [ observeTableSize id, activateTooltipsAndPopovers ] )

        Just Shown ->
            ( schema, toastInfo ("Table <b>" ++ formatTableId id ++ "</b> is already shown") )

        Nothing ->
            ( schema, toastError ("Can't show table <b>" ++ formatTableId id ++ "</b>: not found") )


hideColumn : ColumnName -> Dict ColumnName Column -> Dict ColumnName Column
hideColumn columnName columns =
    columns
        |> Dict.update columnName (Maybe.map (setState (\state -> { state | order = Nothing })))
        |> setSequentialOrder


setSequentialOrder : Dict ColumnName Column -> Dict ColumnName Column
setSequentialOrder columns =
    columns
        |> Dict.values
        |> List.sortBy (\c -> c.state.order |> Maybe.withDefault (Dict.size columns))
        |> List.indexedMap
            (\index column ->
                if column.state.order == Nothing then
                    column

                else
                    column |> setState (\state -> { state | order = Just index })
            )
        |> D.fromList .column


showColumn : ColumnName -> Int -> Dict ColumnName Column -> Dict ColumnName Column
showColumn columnName index columns =
    columns
        |> Dict.map
            (\_ column ->
                case column.state.order of
                    Just order ->
                        if order < index then
                            column

                        else
                            column |> setState (\state -> { state | order = Just (order + 1) })

                    Nothing ->
                        if column.column == columnName then
                            column |> setState (\state -> { state | order = Just index })

                        else
                            column
            )


hideAllTables : Schema -> Schema
hideAllTables schema =
    schema
        |> visitTables
            (setState
                (\state ->
                    if state.status == Shown then
                        { state | status = Hidden }

                    else
                        state
                )
            )


showAllTables : Schema -> ( Schema, Cmd Msg )
showAllTables schema =
    let
        ( cmds, tables ) =
            schema.tables |> Dict.values |> List.map showTableByState |> List.unzip
    in
    ( schema |> setTables tables, Cmd.batch [ observeTablesSize (cmds |> List.filterMap identity), activateTooltipsAndPopovers ] )


showTableByState : Table -> ( Maybe TableId, Table )
showTableByState table =
    case table.state.status of
        Uninitialized ->
            ( Just table.id, table |> setState (\state -> { state | status = Initializing }) )

        Initializing ->
            ( Nothing, table )

        Hidden ->
            ( Just table.id, table |> setState (\state -> { state | status = Shown, selected = False }) )

        Shown ->
            ( Nothing, table )


toLayout : LayoutName -> Schema -> Layout
toLayout name schema =
    { name = name
    , canvas = { zoom = schema.state.zoom, position = schema.state.position }
    , tables = schema.tables |> Dict.values |> List.filter (\t -> t.state.status == Shown) |> List.map tableToLayout |> Dict.fromList
    }


tableToLayout : Table -> ( TableId, TableProps )
tableToLayout table =
    ( table.id
    , { position = table.state.position
      , color = table.state.color
      , columns = table.columns |> Dict.values |> List.filterMap columnToLayout |> Dict.fromList
      }
    )


columnToLayout : Column -> Maybe ( ColumnName, ColumnProps )
columnToLayout column =
    Maybe.map (\order -> ( column.column, { position = order } )) column.state.order


createLayout : LayoutName -> Model -> ( Model, Cmd Msg )
createLayout name model =
    let
        newModel : Model
        newModel =
            model
                |> setState (\s -> { s | newLayout = Nothing })
                |> setSchema
                    (\ms ->
                        ms
                            |> Maybe.map
                                (\s ->
                                    { s
                                        | layouts = s.layouts |> L.addOn model.schema (toLayout name)
                                        , state = s.state |> set (\st -> { st | currentLayout = Just name })
                                    }
                                )
                    )
    in
    ( newModel, Cmd.batch ([ activateTooltipsAndPopovers ] |> L.addOn newModel.schema saveSchema) )


loadLayout : LayoutName -> Model -> ( Model, Cmd Msg )
loadLayout name model =
    model.schema
        |> Maybe.map .layouts
        |> Maybe.withDefault []
        |> L.find (\layout -> layout.name == name)
        |> Maybe.map
            (\layout ->
                let
                    ( cmds, tables ) =
                        model.schema
                            |> Maybe.map .tables
                            |> Maybe.map Dict.values
                            |> Maybe.withDefault []
                            |> List.map (\table -> showTableWithLayout (layout.tables |> Dict.get table.id) table)
                            |> List.unzip
                in
                ( model
                    |> setSchema
                        (Maybe.map
                            (\s ->
                                s
                                    |> setTables tables
                                    |> setState (\st -> { st | currentLayout = Just layout.name, zoom = layout.canvas.zoom, position = layout.canvas.position })
                            )
                        )
                , Cmd.batch [ observeTablesSize (cmds |> List.filterMap identity), activateTooltipsAndPopovers ]
                )
            )
        |> Maybe.withDefault ( model, Cmd.none )


updateLayout : LayoutName -> Model -> ( Model, Cmd Msg )
updateLayout name model =
    let
        newModel : Model
        newModel =
            model
                |> setSchema
                    (\ms ->
                        ms
                            |> Maybe.map
                                (\s ->
                                    { s
                                        | layouts = s.layouts |> List.map (\l -> B.lazyCond (l.name == name) (\_ -> s |> toLayout name) (\_ -> l))
                                        , state = s.state |> set (\st -> { st | currentLayout = Just name })
                                    }
                                )
                    )
    in
    ( newModel, newModel.schema |> Maybe.map saveSchema |> Maybe.withDefault Cmd.none )


deleteLayout : LayoutName -> Model -> ( Model, Cmd Msg )
deleteLayout name model =
    let
        newModel : Model
        newModel =
            model
                |> setSchema
                    (\ms ->
                        ms
                            |> Maybe.map
                                (\s ->
                                    { s
                                        | layouts = s.layouts |> List.filter (\l -> not (l.name == name))
                                        , state =
                                            if s.state.currentLayout == Just name then
                                                s.state |> set (\st -> { st | currentLayout = Nothing })

                                            else
                                                s.state
                                    }
                                )
                    )
    in
    ( newModel, newModel.schema |> Maybe.map saveSchema |> Maybe.withDefault Cmd.none )


showTableWithLayout : Maybe TableProps -> Table -> ( Maybe TableId, Table )
showTableWithLayout maybeProps table =
    case ( table.state.status, maybeProps ) of
        ( Uninitialized, Just props ) ->
            ( Just table.id, table |> setState (\state -> { state | status = Initializing }) |> setTableLayout props )

        ( Uninitialized, Nothing ) ->
            ( Nothing, table )

        ( Initializing, Just props ) ->
            ( Nothing, table |> setTableLayout props )

        ( Initializing, Nothing ) ->
            ( Nothing, table |> setState (\state -> { state | status = Uninitialized }) )

        ( Hidden, Just props ) ->
            ( Just table.id, table |> setState (\state -> { state | status = Shown, selected = False }) |> setTableLayout props )

        ( Hidden, Nothing ) ->
            ( Nothing, table )

        ( Shown, Just props ) ->
            ( Nothing, table |> setTableLayout props )

        ( Shown, Nothing ) ->
            ( Nothing, table |> setState (\state -> { state | status = Hidden }) )


setTableLayout : TableProps -> Table -> Table
setTableLayout props table =
    { table
        | state = table.state |> set (\state -> { state | position = props.position, color = props.color })
        , columns = table.columns |> Dict.map (\name column -> column |> setState (\state -> { state | order = props.columns |> Dict.get name |> Maybe.map .position }))
    }


updateSizes : List SizeChange -> Model -> ( Model, Cmd Msg )
updateSizes sizeChanges model =
    ( sizeChanges |> List.foldr updateSize model, Cmd.batch (sizeChanges |> List.filterMap (maybeChangeCmd model)) )


updateSize : SizeChange -> Model -> Model
updateSize change model =
    if change.id == conf.ids.erd then
        { model | canvas = model.canvas |> setSize (\_ -> change.size) }

    else
        { model | schema = model.schema |> Maybe.map (visitTable (parseTableId change.id) (setState (\state -> { state | size = change.size }))) }


maybeChangeCmd : Model -> SizeChange -> Maybe (Cmd Msg)
maybeChangeCmd model { id, size } =
    model.schema |> Maybe.andThen (\s -> s.tables |> getInitializingTable (parseTableId id) |> Maybe.map (\t -> t.id |> initializeTable size (getArea model.canvas s.state)))


getInitializingTable : TableId -> Tables -> Maybe Table
getInitializingTable id tables =
    Dict.get id tables |> M.filter (\t -> t.state.status == Initializing)


getArea : Canvas -> SchemaState -> Area
getArea canvas state =
    { left = (0 - state.position.left) / state.zoom
    , right = (canvas.size.width - state.position.left) / state.zoom
    , top = (0 - state.position.top) / state.zoom
    , bottom = (canvas.size.height - state.position.top) / state.zoom
    }


zoomCanvas : WheelEvent -> SchemaState -> SchemaState
zoomCanvas wheel state =
    let
        newZoom : ZoomLevel
        newZoom =
            (state.zoom + (wheel.delta.y * conf.zoom.speed)) |> clamp conf.zoom.min conf.zoom.max

        zoomFactor : Float
        zoomFactor =
            newZoom / state.zoom

        -- to zoom on cursor, works only if origin is top left (CSS property: "transform-origin: top left;")
        newLeft : Float
        newLeft =
            state.position.left - ((wheel.mouse.x - state.position.left) * (zoomFactor - 1))

        newTop : Float
        newTop =
            state.position.top - ((wheel.mouse.y - state.position.top) * (zoomFactor - 1))
    in
    { state | zoom = newZoom, position = Position newLeft newTop }


dragConfig : Draggable.Config DragId Msg
dragConfig =
    Draggable.customConfig
        [ onDragStart StartDragging
        , onDragEnd StopDragging
        , onDragBy OnDragBy
        ]


dragItem : Model -> Draggable.Delta -> ( Model, Cmd Msg )
dragItem model delta =
    case model.state.dragId of
        Just id ->
            if id == conf.ids.erd then
                ( { model | schema = model.schema |> Maybe.map (setState (updatePosition delta 1)) }, Cmd.none )

            else
                ( { model | schema = model.schema |> Maybe.map (\s -> s |> visitTable (parseTableId id) (setState (updatePosition delta s.state.zoom))) }, Cmd.none )

        Nothing ->
            ( model, toastError "Can't dragItem when no drag id" )



-- update helpers


visitTables : (Table -> Table) -> Schema -> Schema
visitTables transform schema =
    { schema | tables = schema.tables |> Dict.map (\_ table -> transform table) }


visitTable : TableId -> (Table -> Table) -> Schema -> Schema
visitTable id transform schema =
    { schema | tables = schema.tables |> Dict.update id (Maybe.map transform) }


getTable : TableId -> Schema -> Maybe Table
getTable id schema =
    schema.tables |> Dict.get id


setTables : List Table -> Schema -> Schema
setTables tables schema =
    { schema | tables = tables |> D.fromList .id }


setSize : (s -> s) -> { item | size : s } -> { item | size : s }
setSize transform item =
    { item | size = item.size |> transform }


updatePosition : Draggable.Delta -> ZoomLevel -> { item | position : Position } -> { item | position : Position }
updatePosition ( dx, dy ) zoom item =
    { item | position = Position (item.position.left + (dx / zoom)) (item.position.top + (dy / zoom)) }


decodeErrorToHtml : Decode.Error -> String
decodeErrorToHtml error =
    "<pre>" ++ Decode.errorToString error ++ "</pre>"


formatHttpError : Http.Error -> String
formatHttpError error =
    case error of
        BadUrl url ->
            "the URL " ++ url ++ " was invalid"

        Timeout ->
            "unable to reach the server, try again"

        NetworkError ->
            "unable to reach the server, check your network connection"

        BadStatus 500 ->
            "the server had a problem, try again later"

        BadStatus 400 ->
            "verify your information and try again"

        BadStatus 404 ->
            "file does not exist"

        BadStatus status ->
            "network error (" ++ String.fromInt status ++ ")"

        BadBody errorMessage ->
            errorMessage
