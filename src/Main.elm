module Main exposing (..)

import Browser
import Html exposing (Html, div, li, text, ul)
import Html.Attributes exposing (class)
import Http exposing (Error(..))
import Models.Schema exposing (Column, ColumnName(..), Schema, SchemaName(..), Table, TableName(..), schemaDecoder)



-- MAIN


main =
    Browser.element { init = init, update = update, subscriptions = subscriptions, view = view }



-- MODEL


type Model
    = Loading
    | Failure Http.Error
    | Success Schema


init : () -> ( Model, Cmd Msg )
init _ =
    ( Loading, loadSchema )



-- UPDATE


type Msg
    = GotSchema (Result Http.Error Schema)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg _ =
    case msg of
        GotSchema result ->
            case result of
                Ok schema ->
                    ( Success schema, Cmd.none )

                Err e ->
                    ( Failure e, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


view : Model -> Html Msg
view model =
    case model of
        Failure e ->
            text ("Unable to load your schema: " ++ viewHttpError e)

        Loading ->
            text "Loading..."

        Success structure ->
            div [] (List.map (\table -> viewTable table) structure.tables)


viewTable : Table -> Html Msg
viewTable table =
    div [ class "table" ]
        [ div [ class "header" ] [ text (formatTableName table) ]
        , ul [ class "columns" ] (List.map viewColumn table.columns)
        ]


viewColumn : Column -> Html Msg
viewColumn column =
    li [] [ text (formatColumnName column) ]


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



-- FORMAT: functions that return a String to be printed


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



-- HTTP


loadSchema : Cmd Msg
loadSchema =
    Http.get
        { url = "/test/resources/schema.json"
        , expect = Http.expectJson GotSchema schemaDecoder
        }
