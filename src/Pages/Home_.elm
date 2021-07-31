module Pages.Home_ exposing (Model, Msg, page)

import Gen.Params.Home_ exposing (Params)
import Gen.Route as Route
import Html exposing (Html, a, div, h1, h2, img, p, span, text)
import Html.Attributes exposing (alt, class, height, href, id, src, style, width)
import Page
import PagesComponents.Containers as Containers
import Ports exposing (trackPage)
import Request
import Shared
import View exposing (View)


page : Shared.Model -> Request.With Params -> Page.With Model msg
page _ _ =
    Page.element
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }


type alias Model =
    ()


type alias Msg =
    ()


init : ( Model, Cmd msg )
init =
    ( (), trackPage "home" )


update : msg -> Model -> ( Model, Cmd msg )
update _ model =
    ( model, Cmd.none )


view : Model -> View msg
view _ =
    { title = "Schema Viz"
    , body = Containers.root [ hero, features, footer ]
    }


hero : Html msg
hero =
    div [ class "px-4 mt-5 text-center border-bottom" ]
        [ img [ class "d-block mx-auto mb-4", src "/assets/logo.png", width 100, height 100, alt "Schema Viz logo" ] []
        , h1 [ class "display-5 fw-bold" ] [ text "Schema Viz" ]
        , div [ class "col-lg-6 mx-auto" ]
            [ p [ class "lead mb-4" ] [ text "Explore and understand your SQL schema" ]
            , div [ class "d-grid gap-2 d-sm-flex justify-content-sm-center mb-5" ]
                [ a [ class "btn btn-outline-secondary btn-lg px-4", href "#features" ] [ text "Learn more" ]
                , a [ class "btn btn-primary btn-lg px-4 gap-3", href (Route.toHref Route.App) ] [ text "Explore your schema" ]
                ]
            ]
        , div [ class "overflow-hidden", style "max-height" "50vh" ]
            [ div [ class "container px-5" ]
                [ span [ class "img-swipe" ]
                    [ img [ src "/assets/schema-viz-screenshot.png", class "img-fluid border rounded-3 shadow-lg mb-4 img-default", alt "Schema Viz screenshot", width 800, height 759 ] []
                    , img [ src "/assets/schema-viz-screenshot-complex.png", class "img-fluid border rounded-3 shadow-lg mb-4 img-hover", alt "Schema Viz screenshot", width 800, height 759 ] []
                    ]
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
                        [ h2 [] [ text "Partial display" ]
                        , p [] [ text """Maybe the less impressive but most useful feature when you work with a schema with 20, 40 or even 400 or 1000 tables!
                                         Seeing only what you need is vital to understand how it works.
                                         This is true for tables but also for columns and relations!""" ]
                        ]
                    ]
                , div [ class "col d-flex align-items-start" ]
                    [ div []
                        [ h2 [] [ text "Search" ]
                        , p [] [ text """Search is awesome, don't know where to start? Just type a few words and you will have related tables and columns ranked by relevance.
                                         Looking at table and column names, but also comments, keys or relations (soon).""" ]
                        ]
                    ]
                , div [ class "col d-flex align-items-start" ]
                    [ div []
                        [ h2 [] [ text "Layouts" ]
                        , p [] [ text """Your database is probably supporting many features, why not save them to move from one to an other ?
                                         Layouts are here for that: select tables and columns related to a feature and save them as a layout.
                                         So you can easily switch between them.""" ]
                        ]
                    ]
                , div [ class "col d-flex align-items-start" ]
                    [ div []
                        [ h2 [] [ text "Relation exploration" ]
                        , p [] [ text """Start from a table and look at its relations to display more.
                                         Outgoing, of course (foreign keys), but incoming ones also (foreign keys from other tables)!""" ]
                        ]
                    ]
                , div [ class "col d-flex align-items-start" ]
                    [ div []
                        [ h2 [] [ text "Relation search (soon)" ]
                        , p [] [ text """Did you ever ask yourself how to join two tables ?
                                         Schema Viz is here for you, showing all the possible path between two tables.
                                         But also between a table and a column!""" ]
                        ]
                    ]
                , div [ class "col d-flex align-items-start" ]
                    [ div []
                        [ h2 [] [ text "Lorem Ipsum" ]
                        , p [] [ text """You came this far ??? Awesome! You seem quite interested and ready to dig in ^^
                                         The best you can do now is to """, a [ href (Route.toHref Route.App) ] [ text "try it out" ], text " right away :D" ]
                        ]
                    ]
                ]
            ]
        ]


footer : Html msg
footer =
    div [] []


subscriptions : Model -> Sub msg
subscriptions _ =
    Sub.none
