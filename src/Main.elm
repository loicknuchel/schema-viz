module Main exposing (..)

import Browser
import Browser.Dom as Dom
import Draggable
import Draggable.Events exposing (onDragBy, onDragEnd, onDragStart)
import Formats exposing (formatColumnName, formatColumnType, formatHttpError, formatTableId, formatTableName)
import Html exposing (Attribute, Html, div, li, text, ul)
import Html.Attributes exposing (class, id, style)
import Http
import Lib exposing (genChoose, genSequence, maybeFold)
import Models.Schema exposing (Column, ColumnName(..), ColumnType(..), Schema, SchemaName(..), Table, TableName(..), schemaDecoder)
import Models.Utils exposing (Color, Position, Size)
import Random
import Task exposing (Task)



-- MAIN


main : Program () Model Msg
main =
    Browser.element { init = init, update = update, subscriptions = subscriptions, view = view }



-- MODEL


type alias Error =
    String


type alias WindowSize =
    Size


type alias Menu =
    { id : DragId, position : Position }


type alias TableId =
    String


type alias SizedTable =
    { id : TableId, sql : Table, size : Size }


type alias SizedSchema =
    { tables : List SizedTable }


type alias UiTable =
    { id : TableId, sql : Table, size : Size, color : String, position : Position }


type alias UiSchema =
    { tables : List UiTable }


type alias DragId =
    String


type alias DragState =
    { id : Maybe DragId, drag : Draggable.State DragId }


type Model
    = Loading
    | Failure Error
    | HasData Schema
    | HasSizes SizedSchema Size
    | Success UiSchema Menu DragState


init : () -> ( Model, Cmd Msg )
init _ =
    ( Loading, loadSchema "/test/resources/schema.json" )


initMenu : Menu
initMenu =
    Menu "menu" (Position 0 0)



-- UPDATE


type Msg
    = GotSchema (Result Http.Error Schema)
    | GotSizes (Result Dom.Error ( SizedSchema, WindowSize ))
    | GotLayout UiSchema
    | StartDragging DragId
    | StopDragging
    | OnDragBy Draggable.Delta
    | DragMsg (Draggable.Msg DragId)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model ) of
        ( GotSchema (Ok schema), _ ) ->
            ( HasData schema, getSizes schema )

        ( GotSizes (Ok ( sizedSchema, size )), _ ) ->
            ( HasSizes sizedSchema size, renderLayout sizedSchema size )

        ( GotLayout schema, _ ) ->
            ( Success schema initMenu (DragState Nothing Draggable.init), Cmd.none )

        ( StartDragging id, Success schema menu drag ) ->
            ( Success schema menu { drag | id = Just id }, Cmd.none )

        ( StopDragging, Success schema menu drag ) ->
            ( Success schema menu { drag | id = Nothing }, Cmd.none )

        ( OnDragBy delta, Success schema menu drag ) ->
            case drag.id of
                Just id ->
                    if id == menu.id then
                        ( Success schema (updatePosition menu delta) drag, Cmd.none )

                    else
                        ( Success (updateTable (\table -> updatePosition table delta) id schema) menu drag, Cmd.none )

                Nothing ->
                    ( Failure "Can't OnDragBy when no drag id", Cmd.none )

        ( DragMsg dragMsg, Success schema menu drag ) ->
            case Draggable.update dragConfig dragMsg drag of
                ( newDrag, newMsg ) ->
                    ( Success schema menu newDrag, newMsg )

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


dragConfig : Draggable.Config DragId Msg
dragConfig =
    Draggable.customConfig
        [ onDragStart StartDragging
        , onDragEnd StopDragging
        , onDragBy OnDragBy
        ]


updateTable : (UiTable -> UiTable) -> TableId -> UiSchema -> UiSchema
updateTable transform id schema =
    { schema
        | tables =
            List.map
                (\table ->
                    if table.id == id then
                        transform table

                    else
                        table
                )
                schema.tables
    }


updatePosition : { m | position : Position } -> Draggable.Delta -> { m | position : Position }
updatePosition item ( dx, dy ) =
    { item | position = Position (item.position.left + dx) (item.position.top + dy) }



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    case model of
        Success _ _ { drag } ->
            Draggable.subscriptions DragMsg drag

        _ ->
            Sub.none



-- VIEW


view : Model -> Html Msg
view model =
    case model of
        Failure e ->
            text ("Unable to load your schema: " ++ e)

        Loading ->
            text "Loading..."

        HasData schema ->
            viewApp Nothing (List.map (\table -> UiTable (formatTableId table) table (Size 0 0) colors.grey (Position 0 0)) schema.tables)

        HasSizes schema _ ->
            viewApp Nothing (List.map (\table -> UiTable table.id table.sql table.size colors.grey (Position 0 0)) schema.tables)

        Success schema menu _ ->
            viewApp (Just menu) schema.tables


viewApp : Maybe Menu -> List UiTable -> Html Msg
viewApp menu tables =
    div [ class "app" ]
        [ viewMenu menu
        , viewErd tables
        ]


viewMenu : Maybe Menu -> Html Msg
viewMenu menu =
    div ([ class "menu", placeAt (maybeFold (Position 0 0) .position menu) ] ++ maybeFold [] (\m -> dragAttrs m.id) menu)
        [ text "menu" ]


viewErd : List UiTable -> Html Msg
viewErd tables =
    div [ class "erd" ] (List.map viewTable tables)


viewTable : UiTable -> Html Msg
viewTable table =
    div ([ class "table", placeAt table.position, id (formatTableId table.sql), borderColor table.color ] ++ dragAttrs table.id)
        [ div [ class "header" ] [ text (formatTableName table.sql) ]
        , ul [ class "columns" ] (List.map viewColumn table.sql.columns)
        ]


viewColumn : Column -> Html Msg
viewColumn column =
    li [ class "column" ] [ text (formatColumnName column ++ " " ++ formatColumnType column) ]


placeAt : Position -> Attribute msg
placeAt p =
    style "transform" ("translate(" ++ String.fromFloat p.left ++ "px, " ++ String.fromFloat p.top ++ "px)")


borderColor : String -> Attribute msg
borderColor color =
    style "border-color" color


dragAttrs : DragId -> List (Attribute Msg)
dragAttrs id =
    style "cursor" "pointer" :: Draggable.mouseTrigger id DragMsg :: Draggable.touchTriggers id DragMsg



-- MESSAGE BUILDERS


loadSchema : String -> Cmd Msg
loadSchema url =
    Http.get { url = url, expect = Http.expectJson GotSchema schemaDecoder }


getSizes : Schema -> Cmd Msg
getSizes schema =
    Task.attempt GotSizes (allSizes schema)


renderLayout : SizedSchema -> Size -> Cmd Msg
renderLayout schema size =
    Random.generate GotLayout (uiSchemaGen schema size)



-- GET SIZES


allSizes : Schema -> Task Dom.Error ( SizedSchema, Size )
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


windowSize : Task e Size
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
    case colors of
        { red, pink, orange, yellow, green, blue, darkBlue, purple, grey } ->
            genChoose ( red, [ pink, orange, yellow, green, blue, darkBlue, purple, grey ] )


colors =
    { red = "#E3342F", pink = "#F66D9B", orange = "#F6993F", yellow = "#FFED4A", green = "#4DC0B5", blue = "#3490DC", darkBlue = "#6574CD", purple = "#9561E2", grey = "#B8C2CC" }
