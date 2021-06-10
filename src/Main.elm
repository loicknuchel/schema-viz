module Main exposing (..)

import Browser
import Browser.Dom
import Draggable
import Html exposing (Attribute, Html, div, li, text, ul)
import Html.Attributes exposing (attribute, class, id, style)
import Http exposing (Error(..))
import Models.Schema exposing (Column, ColumnName(..), ColumnType(..), Schema, SchemaName(..), Table, TableName(..), schemaDecoder)
import Random
import Task exposing (Task)



-- MAIN


main : Program () Model Msg
main =
    Browser.element { init = init, update = update, subscriptions = subscriptions, view = view }



-- MODEL


colors =
    { red = "#E3342F", pink = "#F66D9B", orange = "#F6993F", yellow = "#FFED4A", green = "#4DC0B5", blue = "#3490DC", darkBlue = "#6574CD", purple = "#9561E2", grey = "#B8C2CC" }


type alias Color =
    String


type alias Size =
    { width : Float, height : Float }


type alias Position =
    { top : Float, left : Float }


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



-- UPDATE


type Msg
    = GotSchema (Result Http.Error Schema)
    | GotSizes (Result Browser.Dom.Error ( SizedSchema, Size ))
    | GotLayout UiSchema
    | OnDragBy Draggable.Delta
    | DragMsg (Draggable.Msg ())


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotSchema (Ok schema) ->
            ( HasData schema, getSizes schema )

        GotSchema (Err e) ->
            ( Failure (viewHttpError e), Cmd.none )

        GotSizes (Ok ( sizedSchema, size )) ->
            ( HasSizes sizedSchema size, renderLayout sizedSchema size )

        GotSizes (Err (Browser.Dom.NotFound e)) ->
            ( Failure ("Size not found for '" ++ e ++ "' id"), Cmd.none )

        GotLayout schema ->
            ( Success schema (Menu (Position 0 0) Draggable.init), Cmd.none )

        OnDragBy ( dx, dy ) ->
            case model of
                Success schema menu ->
                    ( Success schema { position = { top = menu.position.top + dy, left = menu.position.left + dx }, drag = menu.drag }, Cmd.none )

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
            div [ class "app" ]
                [ div [ class "menu", top 0, left 0 ] [ text "menu" ]
                , div [ class "erd" ] (List.map (\table -> viewTable table (Size 0 0) colors.grey (Position 0 0)) schema.tables)
                ]

        HasSizes schema _ ->
            div [ class "app" ]
                [ div [ class "menu", top 0, left 0 ] [ text "menu" ]
                , div [ class "erd" ] (List.map (\table -> viewTable table.sql table.size colors.grey (Position 0 0)) schema.tables)
                ]

        Success schema menu ->
            div [ class "app" ]
                [ div ([ class "menu", top menu.position.top, left menu.position.left, Draggable.mouseTrigger () DragMsg ] ++ Draggable.touchTriggers () DragMsg) [ text "menu" ]
                , div [ class "erd" ] (List.map (\table -> viewTable table.sql table.size table.color table.position) schema.tables)
                ]


viewTable : Table -> Size -> Color -> Position -> Html Msg
viewTable table size color position =
    div [ id (formatTableId table), class "table", borderColor color, top position.top, left position.left, attribute "data-size" (String.fromFloat size.width ++ "x" ++ String.fromFloat size.height) ]
        [ div [ class "header" ] [ text (formatTableName table) ]
        , ul [ class "columns" ] (List.map viewColumn table.columns)
        ]


viewColumn : Column -> Html Msg
viewColumn column =
    li [ class "column" ] [ text (formatColumnName column ++ " " ++ formatColumnType column) ]


viewHttpError : Http.Error -> String
viewHttpError error =
    case error of
        BadUrl url ->
            "The URL " ++ url ++ " was invalid"

        Timeout ->
            "Unable to reach the server, try again"

        NetworkError ->
            "Unable to reach the server, check your network connection"

        BadStatus 500 ->
            "The server had a problem, try again later"

        BadStatus 400 ->
            "Verify your information and try again"

        BadStatus _ ->
            "Unknown error"

        BadBody errorMessage ->
            errorMessage


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



-- FORMAT: functions that return a String to be printed


formatTableId : Table -> String
formatTableId table =
    case ( table.schema, table.table ) of
        ( SchemaName schema, TableName name ) ->
            schema ++ "." ++ name


formatTableName : Table -> String
formatTableName table =
    case ( table.schema, table.table ) of
        ( SchemaName schema, TableName name ) ->
            schema ++ "." ++ name


formatColumnName : Column -> String
formatColumnName column =
    case column.column of
        ColumnName name ->
            name


formatColumnType : Column -> String
formatColumnType column =
    case column.kind of
        ColumnType kind ->
            kind



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


allSizes : Schema -> Task Browser.Dom.Error ( SizedSchema, Size )
allSizes schema =
    Task.map2 (\sizedSchema size -> ( sizedSchema, size )) (schemaSize schema) windowSize


schemaSize : Schema -> Task Browser.Dom.Error SizedSchema
schemaSize schema =
    Task.map (\tables -> { tables = tables }) (tablesSize schema.tables)


tablesSize : List Table -> Task Browser.Dom.Error (List SizedTable)
tablesSize tables =
    Task.sequence (List.map (\table -> tableSize table) tables)


tableSize : Table -> Task Browser.Dom.Error SizedTable
tableSize table =
    Task.map (\e -> SizedTable table (Size e.element.width e.element.height)) (Browser.Dom.getElement (formatTableId table))


windowSize : Task e Size
windowSize =
    Task.map (\viewport -> Size viewport.viewport.width viewport.viewport.height) Browser.Dom.getViewport



-- RANDOM GENERATORS


uiSchemaGen : SizedSchema -> Size -> Random.Generator UiSchema
uiSchemaGen schema size =
    Random.map (\tables -> { tables = tables }) (uiTablesGen schema.tables size)


uiTablesGen : List SizedTable -> Size -> Random.Generator (List UiTable)
uiTablesGen tables size =
    sequenceGen (List.map (\table -> uiTableGen table size) tables)


uiTableGen : SizedTable -> Size -> Random.Generator UiTable
uiTableGen table size =
    Random.map2 (\color position -> { sql = table.sql, size = table.size, color = color, position = position }) colorGen (positionGen table size)


positionGen : SizedTable -> Size -> Random.Generator Position
positionGen table size =
    Random.map2 (\w h -> { top = h, left = w }) (Random.float 0 (size.width - table.size.width)) (Random.float 0 (size.height - table.size.height))


colorGen : Random.Generator Color
colorGen =
    case colors of
        { red, pink, orange, yellow, green, blue, darkBlue, purple, grey } ->
            choose ( red, [ pink, orange, yellow, green, blue, darkBlue, purple, grey ] )


sequenceGen : List (Random.Generator a) -> Random.Generator (List a)
sequenceGen generators =
    List.foldr (Random.map2 (::)) (Random.constant []) generators


choose : ( a, List a ) -> Random.Generator a
choose ( item, list ) =
    Random.map (\num -> getOrElse (List.head (List.drop num list)) item) (Random.int 0 (List.length list))


getOrElse : Maybe a -> a -> a
getOrElse maybe default =
    case maybe of
        Just a ->
            a

        Nothing ->
            default
