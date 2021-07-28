module PagesComponents.App.Updates.Layout exposing (createLayout, deleteLayout, loadLayout, updateLayout)

import Dict
import Libs.Bool as B
import Models.Schema exposing (LayoutName, Schema)
import PagesComponents.App.Models exposing (Msg)
import PagesComponents.App.Updates.Helpers exposing (setLayout, setLayouts)
import Ports exposing (activateTooltipsAndPopovers, observeTablesSize, saveSchema)


createLayout : LayoutName -> Schema -> ( Schema, Cmd Msg )
createLayout name schema =
    -- TODO check that layout name does not already exist
    { schema | layoutName = Just name }
        |> setLayouts (Dict.update name (\_ -> Just schema.layout))
        |> (\newSchema -> ( newSchema, saveSchema newSchema ))


loadLayout : LayoutName -> Schema -> ( Schema, Cmd Msg )
loadLayout name schema =
    schema.layouts
        |> Dict.get name
        |> Maybe.map
            (\layout ->
                ( { schema | layoutName = Just name } |> setLayout (\_ -> layout)
                , Cmd.batch [ layout.tables |> Dict.keys |> observeTablesSize, activateTooltipsAndPopovers ]
                )
            )
        |> Maybe.withDefault ( schema, Cmd.none )


updateLayout : LayoutName -> Schema -> ( Schema, Cmd Msg )
updateLayout name schema =
    -- TODO check that layout name already exist
    { schema | layoutName = Just name }
        |> setLayouts (Dict.update name (\_ -> Just schema.layout))
        |> (\newSchema -> ( newSchema, saveSchema newSchema ))


deleteLayout : LayoutName -> Schema -> ( Schema, Cmd Msg )
deleteLayout name schema =
    { schema | layoutName = B.cond (schema.layoutName == Just name) Nothing (Just name) }
        |> setLayouts (Dict.update name (\_ -> Nothing))
        |> (\newSchema -> ( newSchema, saveSchema newSchema ))
