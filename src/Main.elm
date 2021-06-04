module Main exposing (..)

import Browser
import Html exposing (Html, div, li, text, ul)
import Html.Attributes exposing (class)
import Http exposing (Error(..))
import Json.Decode exposing (Decoder, field, list, map, map2, map4, map6, maybe, string)



-- MAIN


main =
    Browser.element { init = init, update = update, subscriptions = subscriptions, view = view }



-- MODEL
-- basic type alias
-- TODO: make these types alias incompatibles, use opaque types ? but access their content...


type alias SchemaName =
    String


type alias TableName =
    String


type alias ColumnName =
    String


type alias ColumnType =
    String


type alias PrimaryKeyName =
    String


type alias ForeignKeyName =
    String


type alias UniqueIndexName =
    String


type alias TableComment =
    String


type alias ColumnComment =
    String



-- models, no primitive types allowed here


type alias PrimaryKey =
    { columns : List ColumnName, name : PrimaryKeyName }


type alias ForeignKey =
    { schema : SchemaName, table : TableName, column : ColumnName, name : ForeignKeyName }


type alias UniqueIndex =
    { columns : List ColumnName, name : UniqueIndexName }


type alias Column =
    { column : ColumnName, kind : ColumnType, reference : Maybe ForeignKey, comment : Maybe ColumnComment }


type alias Table =
    { schema : SchemaName, table : TableName, columns : List Column, primaryKey : Maybe PrimaryKey, uniques : List UniqueIndex, comment : Maybe TableComment }


type alias Schema =
    { tables : List Table }


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
        [ div [ class "header" ] [ text (table.schema ++ "." ++ table.table) ]
        , ul [ class "columns" ] (List.map viewColumn table.columns)
        ]


viewColumn : Column -> Html Msg
viewColumn column =
    li [] [ text column.column ]


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



-- HTTP


loadSchema : Cmd Msg
loadSchema =
    Http.get
        { url = "/test/resources/schema.json"
        , expect = Http.expectJson GotSchema schemaDecoder
        }


schemaNameDecoder : Decoder SchemaName
schemaNameDecoder =
    string


tableNameDecoder : Decoder TableName
tableNameDecoder =
    string


columnNameDecoder : Decoder ColumnName
columnNameDecoder =
    string


columnTypeDecoder : Decoder ColumnType
columnTypeDecoder =
    string


primaryKeyNameDecoder : Decoder PrimaryKeyName
primaryKeyNameDecoder =
    string


foreignKeyNameDecoder : Decoder ForeignKeyName
foreignKeyNameDecoder =
    string


uniqueIndexNameDecoder : Decoder UniqueIndexName
uniqueIndexNameDecoder =
    string


tableCommentDecoder : Decoder TableComment
tableCommentDecoder =
    string


columnCommentDecoder : Decoder ColumnComment
columnCommentDecoder =
    string


schemaDecoder : Decoder Schema
schemaDecoder =
    map Schema
        (field "tables" (list tableDecoder))


tableDecoder : Decoder Table
tableDecoder =
    map6 Table
        (field "schema" schemaNameDecoder)
        (field "table" tableNameDecoder)
        (field "columns" (list columnDecoder))
        (maybe (field "primaryKey" primaryKeyDecoder))
        (field "uniques" (list uniqueIndexDecoder))
        (maybe (field "comment" tableCommentDecoder))


columnDecoder : Decoder Column
columnDecoder =
    map4 Column
        (field "column" columnNameDecoder)
        (field "type" columnTypeDecoder)
        (maybe (field "reference" referenceDecoder))
        (maybe (field "comment" columnCommentDecoder))


primaryKeyDecoder : Decoder PrimaryKey
primaryKeyDecoder =
    map2 PrimaryKey
        (field "columns" (list columnNameDecoder))
        (field "name" primaryKeyNameDecoder)


referenceDecoder : Decoder ForeignKey
referenceDecoder =
    map4 ForeignKey
        (field "schema" schemaNameDecoder)
        (field "table" tableNameDecoder)
        (field "column" columnNameDecoder)
        (field "name" foreignKeyNameDecoder)


uniqueIndexDecoder : Decoder UniqueIndex
uniqueIndexDecoder =
    map2 UniqueIndex
        (field "columns" (list columnNameDecoder))
        (field "name" uniqueIndexNameDecoder)
