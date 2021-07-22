module View exposing (viewApp)

import Css.Global
import FontAwesome.Styles as Icon
import Html exposing (Html, div)
import Html.Attributes exposing (class, id)
import Html.Styled as SHtml
import Models exposing (Model, Msg(..))
import Tailwind.Utilities exposing (globalStyles)
import Views.Command exposing (viewCommands)
import Views.Erd exposing (viewErd)
import Views.Menu exposing (viewMenu)
import Views.Modals.Confirm exposing (viewConfirm)
import Views.Modals.CreateLayout exposing (viewCreateLayoutModal)
import Views.Modals.HelpInstructions exposing (viewHelpModal)
import Views.Modals.SchemaSwitch exposing (viewSchemaSwitchModal)
import Views.Navbar exposing (viewNavbar)



-- deps = { to = { only = [ "Libs.*", "Models.*", "Views.*", "Conf" ] } }
-- view entry point, can include any module from Views, Models or Libs


viewApp : Model -> List (Html Msg)
viewApp model =
    -- INFO: add the tailwind styles in DOM
    [ Icon.css, Css.Global.global globalStyles |> SHtml.toUnstyled ]
        ++ viewNavbar model.search (model.schema |> Maybe.map (\s -> ( ( s.tables, s.layout ), ( s.layoutName, s.layouts ) )))
        ++ viewMenu (model.schema |> Maybe.map (\s -> ( s.tables, s.incomingRelations, s.layout )))
        ++ [ viewErd model.sizes (model.schema |> Maybe.map (\s -> ( s.tables, s.incomingRelations, s.layout )))
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
