module Main exposing (..)

import Browser
import Browser.Dom as Dom
import Draggable
import Formats exposing (formatColumnName, formatColumnType, formatHttpError, formatSize, formatTableId, formatTableName)
import Html exposing (Attribute, Html, div, li, text, ul)
import Html.Attributes exposing (attribute, class, id, style)
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


type alias Menu =
    { position : Position, drag : Draggable.State () }


type alias SizedTable =
    { sql : Table, size : Size }


type alias SizedSchema =
    { tables : List SizedTable }


type alias UiTable =
    { sql : Table, size : Size, color : String, position : Position }


type alias UiSchema =
    { tables : List UiTable }


type Model
    = Loading
    | Failure String
    | HasData Schema
    | HasSizes SizedSchema Size
    | Success UiSchema Menu


init : () -> ( Model, Cmd Msg )
init _ =
    ( Loading, loadSchema "/test/resources/schema.json" )


initMenu : Menu
initMenu =
    Menu (Position 0 0) Draggable.init



-- UPDATE


type Msg
    = GotSchema (Result Http.Error Schema)
    | GotSizes (Result Dom.Error ( SizedSchema, Size ))
    | GotLayout UiSchema
    | OnDragBy Draggable.Delta
    | DragMsg (Draggable.Msg ())


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotSchema (Ok schema) ->
            ( HasData schema, getSizes schema )

        GotSchema (Err e) ->
            ( Failure (formatHttpError e), Cmd.none )

        GotSizes (Ok ( sizedSchema, size )) ->
            ( HasSizes sizedSchema size, renderLayout sizedSchema size )

        GotSizes (Err (Dom.NotFound e)) ->
            ( Failure ("Size not found for '" ++ e ++ "' id"), Cmd.none )

        GotLayout schema ->
            ( Success schema initMenu, Cmd.none )

        OnDragBy ( dx, dy ) ->
            case model of
                Success schema menu ->
                    ( Success schema (Menu (Position (menu.position.left + dx) (menu.position.top + dy)) menu.drag), Cmd.none )

                _ ->
                    ( Failure "Can't OnDragBy when not Success", Cmd.none )

        DragMsg dragMsg ->
            case model of
                Success schema menu ->
                    case Draggable.update (Draggable.basicConfig OnDragBy) dragMsg menu of
                        ( newMenu, newMsg ) ->
                            ( Success schema newMenu, newMsg )

                _ ->
                    ( Failure "Can't DragMsg when not Success", Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    case model of
        Success _ { drag } ->
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
            viewApp Nothing (List.map (\table -> UiTable table (Size 0 0) colors.grey (Position 0 0)) schema.tables)

        HasSizes schema _ ->
            viewApp Nothing (List.map (\table -> UiTable table.sql table.size colors.grey (Position 0 0)) schema.tables)

        Success schema menu ->
            viewApp (Just menu) schema.tables


viewApp : Maybe Menu -> List UiTable -> Html Msg
viewApp menu tables =
    div [ class "app" ]
        [ viewMenu (Maybe.map .position menu)
        , viewErd tables
        ]


viewMenu : Maybe Position -> Html Msg
viewMenu position =
    div
        ([ class "menu" ]
            ++ pos (Maybe.withDefault (Position 0 0) position)
            ++ maybeFold [] (\_ -> Draggable.mouseTrigger () DragMsg :: Draggable.touchTriggers () DragMsg) position
        )
        [ text "menu" ]


viewErd : List UiTable -> Html Msg
viewErd tables =
    div [ class "erd" ] (List.map viewTable tables)


viewTable : UiTable -> Html Msg
viewTable table =
    div ([ class "table", id (formatTableId table.sql), borderColor table.color, attribute "data-size" (formatSize table.size) ] ++ pos table.position)
        [ div [ class "header" ] [ text (formatTableName table.sql) ]
        , ul [ class "columns" ] (List.map viewColumn table.sql.columns)
        ]


viewColumn : Column -> Html Msg
viewColumn column =
    li [ class "column" ] [ text (formatColumnName column ++ " " ++ formatColumnType column) ]


pos : Position -> List (Attribute msg)
pos position =
    [ left position.left, top position.top ]


top : Float -> Attribute msg
top value =
    style "top" (asPx value)


left : Float -> Attribute msg
left value =
    style "left" (asPx value)


borderColor : String -> Attribute msg
borderColor color =
    style "border-color" color


asPx : Float -> String
asPx value =
    String.fromFloat value ++ "px"



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
    Task.map (\e -> SizedTable table (Size e.element.width e.element.height)) (Dom.getElement (formatTableId table))


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
    Random.map2 (\color position -> UiTable table.sql table.size color position) colorGen (positionGen table size)


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
