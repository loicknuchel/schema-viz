module PagesComponents.Home_.Views.FeaturesListGridSection exposing (viewFeaturesListGridSection)

import Html exposing (Html, div, h2, h3, main_, p, span, text)
import Html.Attributes exposing (class)
import PagesComponents.Home_.Views.Helpers.SvgIcon as SvgIcon


viewFeaturesListGridSection : Html msg
viewFeaturesListGridSection =
    main_ []
        [ div [ class "bg-gradient-to-r from-purple-800 to-indigo-700" ]
            [ div [ class "max-w-4xl mx-auto px-4 py-16 sm:px-6 sm:pt-20 sm:pb-24 lg:max-w-7xl lg:pt-24 lg:px-8" ]
                [ h2 [ class "text-3xl font-extrabold text-white tracking-tight" ]
                    [ text "Explore your SQL schema like never before" ]
                , p [ class "mt-4 max-w-3xl text-lg text-purple-200" ]
                    [ text "Ac tincidunt sapien vehicula erat auctor pellentesque rhoncus. Et magna sit morbi lobortis. Blandit aliquam sit nisl euismod mattis in." ]
                , div [ class "mt-12 grid grid-cols-1 gap-x-6 gap-y-12 sm:grid-cols-2 lg:mt-16 lg:grid-cols-4 lg:gap-x-8 lg:gap-y-16" ]
                    [ item SvgIcon.inbox
                        "Partial display"
                        """Maybe the less impressive but most useful feature when you work with a schema with 20, 40 or even 400 or 1000 tables!
                           Seeing only what you need is vital to understand how it works. This is true for tables but also for columns and relations!"""
                    , item SvgIcon.documentSearch
                        "Search"
                        """Search is awesome, don't know where to start? Just type a few words and you will have related tables and columns ranked by relevance.
                           Looking at table and column names, but also comments, keys or relations (soon)."""
                    , item SvgIcon.photograph
                        "Layouts"
                        """Your database is multi-purpose/multi-feature, why not save them to move from one to an other ?
                           Layouts are here for that: select tables and columns related to a feature and save them as a layout. So you can easily switch between them."""
                    , item SvgIcon.link
                        "Relation exploration"
                        """Start from a table and look at its relations to display more.
                           Outgoing, of course (foreign keys), but incoming ones also (foreign keys from other tables)!"""
                    ]
                ]
            ]
        ]


item : Html msg -> String -> String -> Html msg
item icon title description =
    div []
        [ div []
            [ span [ class "flex items-center justify-center h-12 w-12 rounded-md bg-white bg-opacity-10" ] [ icon ] ]
        , div [ class "mt-6" ]
            [ h3 [ class "text-lg font-medium text-white" ] [ text title ]
            , p [ class "mt-2 text-base text-purple-200" ] [ text description ]
            ]
        ]
