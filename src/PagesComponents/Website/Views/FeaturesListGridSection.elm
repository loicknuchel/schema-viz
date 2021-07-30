module PagesComponents.Website.Views.FeaturesListGridSection exposing (viewFeaturesListGridSection)

import Html exposing (Html, div, h2, h3, main_, p, span, text)
import Html.Attributes as Attr
import Svg exposing (path, svg)
import Svg.Attributes as SvgAttr


viewFeaturesListGridSection : Html msg
viewFeaturesListGridSection =
    main_ []
        [ div
            [ Attr.class "bg-gradient-to-r from-purple-800 to-indigo-700"
            ]
            [ div
                [ Attr.class "max-w-4xl mx-auto px-4 py-16 sm:px-6 sm:pt-20 sm:pb-24 lg:max-w-7xl lg:pt-24 lg:px-8"
                ]
                [ h2
                    [ Attr.class "text-3xl font-extrabold text-white tracking-tight"
                    ]
                    [ text "Explore your SQL schema like never before" ]
                , p
                    [ Attr.class "mt-4 max-w-3xl text-lg text-purple-200"
                    ]
                    [ text "Ac tincidunt sapien vehicula erat auctor pellentesque rhoncus. Et magna sit morbi lobortis. Blandit aliquam sit nisl euismod mattis in." ]
                , div
                    [ Attr.class "mt-12 grid grid-cols-1 gap-x-6 gap-y-12 sm:grid-cols-2 lg:mt-16 lg:grid-cols-4 lg:gap-x-8 lg:gap-y-16"
                    ]
                    [ item "Partial display" "Maybe the less impressive but most useful feature when you work with a schema with 20, 40 or even 400 or 1000 tables! Seeing only what you need is vital to understand how it works. This is true for tables but also for columns and relations!" inboxIcon
                    , item "Search" "Search is awesome, don't know where to start? Just type a few words and you will have related tables and columns ranked by relevance. Looking at table and column names, but also comments, keys or relations (soon)." documentSearchIcon
                    , item "Layouts" "Your database is multi-purpose/multi-feature, why not save them to move from one to an other ? Layouts are here for that: select tables and columns related to a feature and save them as a layout. So you can easily switch between them." photographIcon
                    , item "Relation exploration" "Start from a table and look at its relations to display more. Outgoing, of course (foreign keys), but incoming ones also (foreign keys from other tables)!" linkIcon
                    ]
                ]
            ]
        ]


item : String -> String -> Html msg -> Html msg
item title description svgIcon =
    div []
        [ div []
            [ span
                [ Attr.class "flex items-center justify-center h-12 w-12 rounded-md bg-white bg-opacity-10"
                ]
                [ svgIcon
                ]
            ]
        , div
            [ Attr.class "mt-6"
            ]
            [ h3
                [ Attr.class "text-lg font-medium text-white"
                ]
                [ text title ]
            , p
                [ Attr.class "mt-2 text-base text-purple-200"
                ]
                [ text description ]
            ]
        ]



-- ICONS


inboxIcon : Html msg
inboxIcon =
    svg
        [ SvgAttr.class "w-6 h-6"
        , SvgAttr.fill "none"
        , SvgAttr.stroke "currentColor"
        , SvgAttr.viewBox "0 0 24 24"
        ]
        [ path
            [ SvgAttr.strokeLinecap "round"
            , SvgAttr.strokeLinejoin "round"
            , SvgAttr.strokeWidth "2"
            , SvgAttr.d "M19 11H5m14 0a2 2 0 012 2v6a2 2 0 01-2 2H5a2 2 0 01-2-2v-6a2 2 0 012-2m14 0V9a2 2 0 00-2-2M5 11V9a2 2 0 012-2m0 0V5a2 2 0 012-2h6a2 2 0 012 2v2M7 7h10"
            ]
            []
        ]


documentSearchIcon : Html msg
documentSearchIcon =
    svg
        [ SvgAttr.class "w-6 h-6"
        , SvgAttr.fill "none"
        , SvgAttr.stroke "currentColor"
        , SvgAttr.viewBox "0 0 24 24"
        ]
        [ path
            [ SvgAttr.strokeLinecap "round"
            , SvgAttr.strokeLinejoin "round"
            , SvgAttr.strokeWidth "2"
            , SvgAttr.d "M10 21h7a2 2 0 002-2V9.414a1 1 0 00-.293-.707l-5.414-5.414A1 1 0 0012.586 3H7a2 2 0 00-2 2v11m0 5l4.879-4.879m0 0a3 3 0 104.243-4.242 3 3 0 00-4.243 4.242z"
            ]
            []
        ]


photographIcon : Html msg
photographIcon =
    svg
        [ SvgAttr.class "w-6 h-6"
        , SvgAttr.fill "none"
        , SvgAttr.stroke "currentColor"
        , SvgAttr.viewBox "0 0 24 24"
        ]
        [ path
            [ SvgAttr.strokeLinecap "round"
            , SvgAttr.strokeLinejoin "round"
            , SvgAttr.strokeWidth "2"
            , SvgAttr.d "M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z"
            ]
            []
        ]


linkIcon : Html msg
linkIcon =
    svg
        [ SvgAttr.class "w-6 h-6"
        , SvgAttr.fill "none"
        , SvgAttr.stroke "currentColor"
        , SvgAttr.viewBox "0 0 24 24"
        ]
        [ path
            [ SvgAttr.strokeLinecap "round"
            , SvgAttr.strokeLinejoin "round"
            , SvgAttr.strokeWidth "2"
            , SvgAttr.d "M13.828 10.172a4 4 0 00-5.656 0l-4 4a4 4 0 105.656 5.656l1.102-1.101m-.758-4.899a4 4 0 005.656 0l4-4a4 4 0 00-5.656-5.656l-1.1 1.1"
            ]
            []
        ]
