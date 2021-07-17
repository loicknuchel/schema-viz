module Updates.Schema exposing (createSampleSchema, createSchema, useSchema)

import Conf exposing (conf)
import Dict
import FileValue exposing (File)
import Http exposing (Error(..))
import Json.Decode as Decode
import JsonFormats.SchemaFormat exposing (decodeSchema)
import Libs.Bool as B
import Libs.Models exposing (FileContent, FileName)
import Libs.Result as R
import Libs.Task as T
import Mappers.SchemaMapper exposing (buildSchemaFromSql)
import Models exposing (Errors, Model, Msg(..), initSwitch)
import Models.Schema exposing (FileInfo, Schema, SchemaId)
import Ports exposing (click, hideModal, saveSchema, toastError, toastInfo)
import SqlParser.SchemaParser exposing (parseSchema)
import Time
import Updates.Helpers exposing (decodeErrorToHtml)



-- deps = { to = { except = [ "Main", "Update", "Updates.*", "View", "Views.*" ] } }


useSchema : Schema -> Model -> ( Model, Cmd Msg )
useSchema schema model =
    ( [], Just schema )
        |> loadSchema model


createSchema : Time.Posix -> File -> FileContent -> Model -> ( Model, Cmd Msg )
createSchema now file content model =
    buildSchema now (model.storedSchemas |> List.map .id) file.name file.name (Just { name = file.name, lastModified = file.lastModified }) content
        |> loadSchema model


createSampleSchema : Time.Posix -> SchemaId -> FileName -> Result Http.Error FileContent -> Model -> ( Model, Cmd Msg )
createSampleSchema now id path response model =
    response
        |> R.fold
            (\err -> ( [ "Can't load '" ++ id ++ "': " ++ formatHttpError err ], Nothing ))
            (buildSchema now (model.storedSchemas |> List.map .id) id path Nothing)
        |> loadSchema model


loadSchema : Model -> ( Errors, Maybe Schema ) -> ( Model, Cmd Msg )
loadSchema model ( errs, schema ) =
    ( { model | switch = initSwitch, schema = schema, sizes = model.sizes |> Dict.filter (\id _ -> not (id |> String.startsWith "table-")) }
    , Cmd.batch
        ((errs |> List.map toastError)
            ++ (schema
                    |> Maybe.map
                        (\s ->
                            B.cond (Dict.size s.tables < 10) (T.send ShowAllTables) (click conf.ids.searchInput)
                                :: [ toastInfo ("<b>" ++ s.id ++ "</b> loaded.<br>Use the search bar to explore it")
                                   , hideModal conf.ids.schemaSwitchModal
                                   , saveSchema s
                                   ]
                        )
                    |> Maybe.withDefault []
               )
        )
    )


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
