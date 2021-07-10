module Update exposing (createLayout, createSampleSchema, createSchema, deleteLayout, dragConfig, dragItem, hideAllTables, hideColumn, hideTable, loadLayout, showAllTables, showColumn, showTable, updateLayout, updateSizes, useSchema, visitTable, visitTables, zoomCanvas)

import AssocList as Dict exposing (Dict)
import Commands.InitializeTable exposing (initializeTable)
import Conf exposing (conf)
import Draggable
import Draggable.Events exposing (onDragBy, onDragEnd, onDragStart)
import FileValue exposing (File)
import Http
import Json.Decode as Decode
import JsonFormats.SchemaFormat exposing (decodeSchema)
import Libs.Bool as B
import Libs.Dict as D
import Libs.Html.Events exposing (WheelEvent)
import Libs.List as L
import Libs.Maybe as M
import Libs.Result as R
import Libs.Std exposing (set, setSchema, setState)
import Libs.Task as T
import Mappers.SchemaMapper exposing (buildSchemaFromSql, emptySchema)
import Models exposing (Canvas, DragId, Errors, Model, Msg(..), initSwitch)
import Models.Schema exposing (Column, ColumnName, ColumnProps, Layout, LayoutName, Schema, Table, TableId, TableProps, TableStatus(..), formatTableId, parseTableId)
import Models.Utils exposing (Area, FileContent, Position, SizeChange, ZoomLevel)
import Ports exposing (activateTooltipsAndPopovers, click, hideModal, observeTableSize, observeTablesSize, saveSchema, toastError, toastInfo)
import SqlParser.SchemaParser exposing (parseSchema)
import Time
import Views.Helpers exposing (decodeErrorToHtml, formatHttpError)



-- utility methods to get the update case down to one line


useSchema : Schema -> Model -> ( Model, Cmd Msg )
useSchema schema model =
    loadSchema model ( [], schema )


createSchema : Time.Posix -> File -> FileContent -> Model -> ( Model, Cmd Msg )
createSchema now file content model =
    buildSchema now (model.storedSchemas |> List.map .name) file.name file.name (Just file.lastModified) content |> loadSchema model


createSampleSchema : Time.Posix -> String -> String -> Result Http.Error String -> Model -> ( Model, Cmd Msg )
createSampleSchema now name path response model =
    response
        |> R.fold
            (\err -> ( [ "Can't load '" ++ name ++ "': " ++ formatHttpError err ], emptySchema ))
            (buildSchema now (model.storedSchemas |> List.map .name) name path Nothing)
        |> loadSchema model


loadSchema : Model -> ( Errors, Schema ) -> ( Model, Cmd Msg )
loadSchema model ( errs, schema ) =
    if Dict.isEmpty schema.tables then
        ( { model | switch = initSwitch }, Cmd.batch (errs |> List.map toastError) )

    else
        ( { model | switch = initSwitch, schema = schema }
        , Cmd.batch
            ((errs |> List.map toastError)
                ++ [ toastInfo ("<b>" ++ schema.name ++ "</b> loaded.<br>Use the search bar to explore it")
                   , hideModal conf.ids.schemaSwitchModal
                   , saveSchema schema
                   ]
                ++ (if Dict.size schema.tables < 10 then
                        [ T.send ShowAllTables ]

                    else
                        [ click conf.ids.searchInput ]
                   )
            )
        )


buildSchema : Time.Posix -> List String -> String -> String -> Maybe Time.Posix -> FileContent -> ( Errors, Schema )
buildSchema now takenNames name path lastModified content =
    if path |> String.endsWith ".sql" then
        parseSchema path content |> Tuple.mapSecond (buildSchemaFromSql takenNames name { created = now, updated = now, fileLastModified = lastModified })

    else if path |> String.endsWith ".json" then
        Decode.decodeString (decodeSchema takenNames) content
            |> R.fold
                (\e -> ( [ "⚠️ Error in <b>" ++ path ++ "</b> ⚠️<br>" ++ decodeErrorToHtml e ], emptySchema ))
                (\schema -> ( [], schema ))

    else
        ( [ "Invalid file (" ++ path ++ "), expected .sql or .json one" ], emptySchema )


hideTable : TableId -> Schema -> Schema
hideTable id schema =
    schema |> visitTable id (setState (\state -> { state | status = Hidden }))


showTable : Model -> TableId -> ( Model, Cmd Msg )
showTable model id =
    case getTable id model.schema |> Maybe.map (\t -> t.state.status) of
        Just Uninitialized ->
            -- race condition problem when observe is performed before table is shown :(
            ( { model | schema = model.schema |> visitTable id (setState (\state -> { state | status = Initializing })) }, Cmd.batch [ observeTableSize id, activateTooltipsAndPopovers ] )

        Just Initializing ->
            ( model, Cmd.none )

        Just Hidden ->
            ( { model | schema = model.schema |> visitTable id (setState (\state -> { state | status = Shown, selected = False })) }, Cmd.batch [ observeTableSize id, activateTooltipsAndPopovers ] )

        Just Shown ->
            ( model, toastInfo ("Table <b>" ++ formatTableId id ++ "</b> is already shown") )

        Nothing ->
            ( model, toastError ("Can't show table <b>" ++ formatTableId id ++ "</b>: not found") )


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


showAllTables : Model -> ( Model, Cmd Msg )
showAllTables model =
    let
        ( cmds, tables ) =
            model.schema.tables
                |> Dict.values
                |> List.map showTableByState
                |> List.unzip
    in
    ( { model | schema = model.schema |> setTables tables }
    , Cmd.batch [ observeTablesSize (cmds |> List.filterMap identity), activateTooltipsAndPopovers ]
    )


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


toLayout : LayoutName -> Model -> Layout
toLayout name model =
    { name = name
    , canvas = { zoom = model.canvas.zoom, position = model.canvas.position }
    , tables = model.schema.tables |> Dict.values |> List.filter (\t -> t.state.status == Shown) |> List.map tableToLayout |> Dict.fromList
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
                |> setState (\s -> { s | newLayout = Nothing, currentLayout = Just name })
                |> setSchema (\s -> { s | layouts = (model |> toLayout name) :: s.layouts })
    in
    ( newModel, Cmd.batch [ saveSchema newModel.schema, activateTooltipsAndPopovers ] )


loadLayout : LayoutName -> Model -> ( Model, Cmd Msg )
loadLayout name model =
    model.schema.layouts
        |> L.find (\layout -> layout.name == name)
        |> Maybe.map
            (\layout ->
                let
                    ( cmds, tables ) =
                        model.schema.tables
                            |> Dict.values
                            |> List.map (\table -> showTableWithLayout (layout.tables |> Dict.get table.id) table)
                            |> List.unzip
                in
                ( model
                    |> set (\m -> { m | canvas = { size = model.canvas.size, zoom = layout.canvas.zoom, position = layout.canvas.position } })
                    |> setSchema (setTables tables)
                    |> setState (\s -> { s | currentLayout = Just name })
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
                |> setSchema (\s -> { s | layouts = s.layouts |> List.map (\l -> B.cond (l.name == name) (\_ -> model |> toLayout name) (\_ -> l)) })
                |> setState (\s -> { s | currentLayout = Just name })
    in
    ( newModel, saveSchema newModel.schema )


deleteLayout : LayoutName -> Model -> ( Model, Cmd Msg )
deleteLayout name model =
    let
        newModel : Model
        newModel =
            model
                |> setSchema (\s -> { s | layouts = s.layouts |> List.filter (\l -> not (l.name == name)) })
                |> setState
                    (\s ->
                        if s.currentLayout == Just name then
                            { s | currentLayout = Nothing }

                        else
                            s
                    )
    in
    ( newModel, saveSchema newModel.schema )


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
        { model | schema = model.schema |> visitTable (parseTableId change.id) (setState (\state -> { state | size = change.size })) }


maybeChangeCmd : Model -> SizeChange -> Maybe (Cmd Msg)
maybeChangeCmd model { id, size } =
    model.schema.tables |> getInitializingTable (parseTableId id) |> Maybe.map (\t -> t.id |> initializeTable size (getArea model.canvas))


getInitializingTable : TableId -> Dict TableId Table -> Maybe Table
getInitializingTable id tables =
    Dict.get id tables |> M.filter (\t -> t.state.status == Initializing)


getArea : Canvas -> Area
getArea canvas =
    { left = (0 - canvas.position.left) / canvas.zoom
    , right = (canvas.size.width - canvas.position.left) / canvas.zoom
    , top = (0 - canvas.position.top) / canvas.zoom
    , bottom = (canvas.size.height - canvas.position.top) / canvas.zoom
    }


zoomCanvas : WheelEvent -> Canvas -> Canvas
zoomCanvas wheel canvas =
    let
        newZoom : ZoomLevel
        newZoom =
            (canvas.zoom + (wheel.delta.y * conf.zoom.speed)) |> clamp conf.zoom.min conf.zoom.max

        zoomFactor : Float
        zoomFactor =
            newZoom / canvas.zoom

        -- to zoom on cursor, works only if origin is top left (CSS property: "transform-origin: top left;")
        newLeft : Float
        newLeft =
            canvas.position.left - ((wheel.mouse.x - canvas.position.left) * (zoomFactor - 1))

        newTop : Float
        newTop =
            canvas.position.top - ((wheel.mouse.y - canvas.position.top) * (zoomFactor - 1))
    in
    { canvas | zoom = newZoom, position = Position newLeft newTop }


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
                ( { model | canvas = model.canvas |> updatePosition delta 1 }, Cmd.none )

            else
                ( { model | schema = model.schema |> visitTable (parseTableId id) (setState (updatePosition delta model.canvas.zoom)) }, Cmd.none )

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
