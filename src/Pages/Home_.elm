module Pages.Home_ exposing (view)

import Gen.Route as Route
import Html exposing (Html, a, div, h1, h2, img, p, text)
import Html.Attributes exposing (alt, class, href, id, src)
import View exposing (View)


view : View msg
view =
    { title = "Schema Viz"
    , body =
        [ hero, features ]
    }


hero : Html msg
hero =
    div [ class "text-center px-4 py-5 my-5" ]
        [ img [ class "d-block mx-auto mb-4", src "/assets/logo.png", alt "Schema Viz logo" ] []
        , h1 [ class "display-5 fw-bold" ] [ text "Schema Viz" ]
        , div [ class "col-lg-6 mx-auto" ]
            [ p [ class "lead mb-4" ]
                [ text "Understand your SQL database schema" ]
            , div [ class "d-grid gap-2 d-sm-flex justify-content-sm-center" ]
                [ a [ class "btn btn-outline-secondary btn-lg px-4", href "#features" ] [ text "Learn more" ]
                , a [ class "btn btn-primary btn-lg px-4 gap-3", href (Route.toHref Route.App) ] [ text "Explore your schema" ]
                ]
            ]
        ]


features : Html msg
features =
    div [ class "bg-light" ]
        [ div [ class "container px-4 py-5", id "features" ]
            [ h2 [ class "pb-2 border-bottom" ] [ text "Features" ]
            , div [ class "row g-4 pt-5 row-cols-1 row-cols-lg-3" ]
                [ div [ class "col d-flex align-items-start" ]
                    [ div []
                        [ h2 [] [ text "Selective display" ]
                        , p [] [ text "Paragraph of text beneath the heading to explain the heading. We'll add onto it with another sentence and probably just keep going until we run out of words." ]
                        ]
                    ]
                , div [ class "col d-flex align-items-start" ]
                    [ div []
                        [ h2 [] [ text "Search" ]
                        , p [] [ text "Paragraph of text beneath the heading to explain the heading. We'll add onto it with another sentence and probably just keep going until we run out of words." ]
                        ]
                    ]
                , div [ class "col d-flex align-items-start" ]
                    [ div []
                        [ h2 [] [ text "Layouts" ]
                        , p [] [ text "Paragraph of text beneath the heading to explain the heading. We'll add onto it with another sentence and probably just keep going until we run out of words." ]
                        ]
                    ]
                ]
            ]
        ]
