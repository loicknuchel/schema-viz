module PagesComponents.App.View exposing (viewApp)

import FontAwesome.Styles as Icon
import Html exposing (Html, div)
import Html.Attributes exposing (class, id)
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
    [ Icon.css ]
        ++ viewNavbar model.search (model.schema |> Maybe.map (\s -> ( s.id, ( s.tables, s.layout ), ( s.layoutName, s.layouts ) )))
        ++ viewMenu (model.schema |> Maybe.map (\s -> ( s.tables, s.incomingRelations, s.layout )))
        ++ [ viewErd model.hover model.sizes (model.schema |> Maybe.map (\s -> ( s.tables, s.incomingRelations, s.layout )))
           , viewCommands (model.schema |> Maybe.map (\s -> s.layout.canvas))
           , viewSchemaSwitchModal model.time model.switch (model.schema |> Maybe.map (\_ -> "Schema Viz, easily explore your SQL schema!") |> Maybe.withDefault "Load a new schema") model.storedSchemas
           , viewCreateLayoutModal model.newLayout
           , viewHelpModal
           , viewConfirm model.confirm
           , viewToasts
           ]


viewToasts : Html Msg
viewToasts =
    div [ id "toast-container", class "toast-container position-fixed bottom-0 end-0 p-3" ] []
