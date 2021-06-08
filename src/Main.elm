module Main exposing (..)

import Browser
import Browser.Dom
import Html exposing (Attribute, Html, div, li, text, ul)
import Html.Attributes exposing (class, style)
import Http exposing (Error(..))
import Models.Schema exposing (Column, ColumnName(..), ColumnType(..), Schema, SchemaName(..), Table, TableName(..), schemaDecoder)
import Task



-- MAIN


main =
    Browser.element { init = init, update = update, subscriptions = subscriptions, view = view }



-- MODEL


colors =
    { red = "#E3342F", pink = "#F66D9B", orange = "#F6993F", yellow = "#FFED4A", green = "#4DC0B5", blue = "#3490DC", darkBlue = "#6574CD", purple = "#9561E2", grey = "#B8C2CC" }


type alias Size =
    { width : Float, height : Float }


type alias AbsolutePosition =
    { top : Int, left : Int }


type alias UiTable =
    { sql : Table, color : String, position : AbsolutePosition }


type alias UiSchema =
    { tables : List UiTable }


type Model
    = Loading
    | Failure String
    | Rendering Schema
    | Success UiSchema


init : () -> ( Model, Cmd Msg )
init _ =
    ( Loading, loadSchema )



-- UPDATE


type Msg
    = GotSchema (Result Http.Error Schema)
    | GotWindowSize Size


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotSchema result ->
            case result of
                Ok schema ->
                    ( Rendering schema, windowSize )

                Err e ->
                    ( Failure (viewHttpError e), Cmd.none )

        GotWindowSize size ->
            case model of
                Rendering schema ->
                    ( Success (buildUiSchema size schema), Cmd.none )

                _ ->
                    ( Failure "bad", Cmd.none )


buildUiSchema : Size -> Schema -> UiSchema
buildUiSchema size schema =
    { tables = List.map (\table -> buildUiTable size table) schema.tables }


buildUiTable : Size -> Table -> UiTable
buildUiTable size table =
    { sql = table, color = colors.red, position = { top = round (size.width / 2), left = round (size.height / 2) } }



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


view : Model -> Html Msg
view model =
    case model of
        Failure e ->
            text ("Unable to load your schema: " ++ e)

        Loading ->
            text "Loading..."

        Rendering _ ->
            text "Rendering..."

        Success structure ->
            div [ class "app" ] (List.map (\table -> viewTable table) structure.tables)


viewTable : UiTable -> Html Msg
viewTable table =
    div [ class "table", borderColor table.color, top table.position.top, left table.position.left ]
        [ div [ class "header" ] [ text (formatTableName table) ]
        , ul [ class "columns" ] (List.map viewColumn table.sql.columns)
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


top : Int -> Attribute msg
top value =
    style "top" (asPx value)


left : Int -> Attribute msg
left value =
    style "left" (asPx value)


borderColor : String -> Attribute msg
borderColor color =
    style "border-color" color


asPx : Int -> String
asPx value =
    String.fromInt value ++ "px"



-- FORMAT: functions that return a String to be printed


formatTableName : UiTable -> String
formatTableName table =
    case ( table.sql.schema, table.sql.table ) of
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



-- HTTP


loadSchema : Cmd Msg
loadSchema =
    Http.get
        { url = "/test/resources/schema.json"
        , expect = Http.expectJson GotSchema schemaDecoder
        }


windowSize : Cmd Msg
windowSize =
    Task.perform (\viewport -> GotWindowSize { width = viewport.viewport.width, height = viewport.viewport.height }) Browser.Dom.getViewport
