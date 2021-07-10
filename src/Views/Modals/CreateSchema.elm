module Views.Modals.CreateSchema exposing (viewCreateLayoutModal)

import Conf exposing (conf)
import Html exposing (Html, button, div, input, label, text)
import Html.Attributes exposing (autofocus, class, disabled, for, id, type_, value)
import Html.Events exposing (onClick, onInput)
import Libs.Bootstrap exposing (Toggle(..), bsDismiss, bsModal)
import Models exposing (Msg(..))
import Models.Schema exposing (LayoutName)


viewCreateLayoutModal : LayoutName -> Html Msg
viewCreateLayoutModal newLayout =
    bsModal conf.ids.newLayoutModal
        "Save layout"
        [ div [ class "row g-3 align-items-center" ]
            [ div [ class "col-auto" ] [ label [ class "col-form-label", for "new-layout-name" ] [ text "Layout name" ] ]
            , div [ class "col-auto" ] [ input [ type_ "text", class "form-control", id "new-layout-name", value newLayout, onInput NewLayout, autofocus True ] [] ]
            ]
        ]
        [ button [ type_ "button", class "btn btn-secondary", bsDismiss Modal ] [ text "Cancel" ]
        , button [ type_ "button", class "btn btn-primary", bsDismiss Modal, disabled (newLayout == ""), onClick (CreateLayout newLayout) ] [ text "Save layout" ]
        ]
