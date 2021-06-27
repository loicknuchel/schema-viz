module Views.Navbar exposing (viewNavbar)

import Html exposing (Html, a, button, div, form, img, input, li, nav, span, text, ul)
import Html.Attributes exposing (alt, attribute, class, height, href, id, placeholder, src, type_)


viewNavbar : Html msg
viewNavbar =
    nav [ class "navbar navbar-expand-md navbar-light bg-white shadow-sm", id "navbar" ]
        [ div [ class "container-fluid" ]
            [ a [ href "#", class "navbar-brand" ] [ img [ src "/assets/logo.png", alt "logo", height 24, class "d-inline-block align-text-top" ] [], text " Schema Viz" ]
            , button [ type_ "button", class "navbar-toggler", attribute "data-bs-toggle" "collapse", attribute "data-bs-target" "#navbar-content", attribute "aria-controls" "navbar-content", attribute "aria-expanded" "false", attribute "aria-label" "Toggle navigation" ]
                [ span [ class "navbar-toggler-icon" ] []
                ]
            , div [ class "collapse navbar-collapse", id "navbar-content" ]
                [ ul [ class "navbar-nav me-auto" ]
                    [ li [ class "nav-item" ] [ a [ href "#", class "nav-link", attribute "data-bs-toggle" "offcanvas", attribute "data-bs-target" "#menu", attribute "aria-controls" "menu" ] [ text "Toggle menu" ] ]
                    ]
                , form [ class "d-flex" ]
                    [ input [ type_ "search", class "form-control me-2", placeholder "Search", attribute "aria-label" "Search" ] []
                    ]
                ]
            ]
        ]
