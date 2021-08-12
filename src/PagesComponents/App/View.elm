module PagesComponents.App.View exposing (viewApp)

import FontAwesome.Styles as Icon
import Html exposing (Html, node, text)
import PagesComponents.App.Models exposing (Model, Msg(..))
import PagesComponents.App.Views.Command exposing (viewCommands)
import PagesComponents.App.Views.Erd exposing (viewErd)
import PagesComponents.App.Views.Menu exposing (viewMenu)
import PagesComponents.App.Views.Modals.Confirm exposing (viewConfirm)
import PagesComponents.App.Views.Modals.CreateLayout exposing (viewCreateLayoutModal)
import PagesComponents.App.Views.Modals.HelpInstructions exposing (viewHelpModal)
import PagesComponents.App.Views.Modals.SchemaSwitch exposing (viewSchemaSwitchModal)
import PagesComponents.App.Views.Navbar exposing (viewNavbar)


viewApp : Model -> List (Html Msg)
viewApp model =
    [ Icon.css, node "style" [] [ text "body { overflow: hidden; }" ] ]
        ++ viewNavbar model.search model.project
        ++ viewMenu (model.project |> Maybe.map .schema)
        ++ [ viewErd model.hover model.sizes (model.project |> Maybe.map .schema)
           , viewCommands (model.project |> Maybe.map (\p -> p.schema.layout.canvas))
           , viewSchemaSwitchModal model.time model.switch (model.project |> Maybe.map (\_ -> "Schema Viz, easily explore your SQL schema!") |> Maybe.withDefault "Load a new schema") model.storedProjects
           , viewCreateLayoutModal model.newLayout
           , viewHelpModal
           , viewConfirm model.confirm
           ]
