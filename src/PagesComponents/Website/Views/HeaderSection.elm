module PagesComponents.Website.Views.HeaderSection exposing (viewHeader)

import Html exposing (Html, a, button, div, header, img, nav, p, span, text, input, label, form, h3, li, ul, h2, footer, blockquote, h1, main_)
import Html.Attributes as Attr
import Svg exposing (svg, path)
import Svg.Attributes as SvgAttr


viewHeader : Html msg
viewHeader =
       div
        [ Attr.class "bg-white"
        ]
        [ header []
            [ div
                [ Attr.class "relative bg-white"
                ]
                [ div
                    [ Attr.class "flex justify-between items-center max-w-7xl mx-auto px-4 py-6 sm:px-6 md:justify-start md:space-x-10 lg:px-8"
                    ]
                    [ div
                        [ Attr.class "flex justify-start lg:w-0 lg:flex-1"
                        ]
                        [ a
                            [ Attr.href "#"
                            ]
                            [ span
                                [ Attr.class "sr-only"
                                ]
                                [ text "Workflow" ]
                            , img
                                [ Attr.class "h-8 w-auto sm:h-10"
                                , Attr.src "https://tailwindui.com/img/logos/workflow-mark-purple-600-to-indigo-600.svg"
                                , Attr.alt ""
                                ]
                                []
                             ]
                         ]
                    , div
                        [ Attr.class "-mr-2 -my-2 md:hidden"
                        ]
                        [ button
                            [ Attr.type_ "button"
                            , Attr.class "bg-white rounded-md p-2 inline-flex items-center justify-center text-gray-400 hover:text-gray-500 hover:bg-gray-100 focus:outline-none focus:ring-2 focus:ring-inset focus:ring-indigo-500"
                            , Attr.attribute "aria-expanded" "false"
                            ]
                            [ span
                                [ Attr.class "sr-only"
                                ]
                                [ text "Open menu" ]
                            ,                             {- Heroicon name: outline/menu -}
                            svg
                                [ SvgAttr.class "h-6 w-6"
                                , SvgAttr.fill "none"
                                , SvgAttr.viewBox "0 0 24 24"
                                , SvgAttr.stroke "currentColor"
                                , Attr.attribute "aria-hidden" "true"
                                ]
                                [ path
                                    [ SvgAttr.strokeLinecap "round"
                                    , SvgAttr.strokeLinejoin "round"
                                    , SvgAttr.strokeWidth "2"
                                    , SvgAttr.d "M4 6h16M4 12h16M4 18h16"
                                    ]
                                    []
                                 ]
                             ]
                         ]
                    , nav
                        [ Attr.class "hidden md:flex space-x-10"
                        ]
                        [ div
                            [ Attr.class "relative"
                            ]
                            [ button
                                [ Attr.type_ "button"
                                , Attr.class "text-gray-500 group bg-white rounded-md inline-flex items-center text-base font-medium hover:text-gray-900 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
                                , Attr.attribute "aria-expanded" "false"
                                ]
                                [ span []
                                    [ text "Solutions" ]
                                , svg
                                    [ SvgAttr.class "text-gray-400 ml-2 h-5 w-5 group-hover:text-gray-500"
                                    , SvgAttr.viewBox "0 0 20 20"
                                    , SvgAttr.fill "currentColor"
                                    , Attr.attribute "aria-hidden" "true"
                                    ]
                                    [ path
                                        [ SvgAttr.fillRule "evenodd"
                                        , SvgAttr.d "M5.293 7.293a1 1 0 011.414 0L10 10.586l3.293-3.293a1 1 0 111.414 1.414l-4 4a1 1 0 01-1.414 0l-4-4a1 1 0 010-1.414z"
                                        , SvgAttr.clipRule "evenodd"
                                        ]
                                        []
                                     ]
                                 ]
                            , div
                                [ Attr.class "absolute z-10 -ml-4 mt-3 transform w-screen max-w-md lg:max-w-2xl lg:ml-0 lg:left-1/2 lg:-translate-x-1/2"
                                ]
                                [ div
                                    [ Attr.class "rounded-lg shadow-lg ring-1 ring-black ring-opacity-5 overflow-hidden"
                                    ]
                                    [ div
                                        [ Attr.class "relative grid gap-6 bg-white px-5 py-6 sm:gap-8 sm:p-8 lg:grid-cols-2"
                                        ]
                                        [ a
                                            [ Attr.href "#"
                                            , Attr.class "-m-3 p-3 flex items-start rounded-lg hover:bg-gray-50"
                                            ]
                                            [ div
                                                [ Attr.class "flex-shrink-0 flex items-center justify-center h-10 w-10 rounded-md bg-gradient-to-r from-purple-600 to-indigo-600 text-white sm:h-12 sm:w-12"
                                                ]
                                                [ svg
                                                    [ SvgAttr.class "h-6 w-6"
                                                    , SvgAttr.fill "none"
                                                    , SvgAttr.viewBox "0 0 24 24"
                                                    , SvgAttr.stroke "currentColor"
                                                    , Attr.attribute "aria-hidden" "true"
                                                    ]
                                                    [ path
                                                        [ SvgAttr.strokeLinecap "round"
                                                        , SvgAttr.strokeLinejoin "round"
                                                        , SvgAttr.strokeWidth "2"
                                                        , SvgAttr.d "M20 13V6a2 2 0 00-2-2H6a2 2 0 00-2 2v7m16 0v5a2 2 0 01-2 2H6a2 2 0 01-2-2v-5m16 0h-2.586a1 1 0 00-.707.293l-2.414 2.414a1 1 0 01-.707.293h-3.172a1 1 0 01-.707-.293l-2.414-2.414A1 1 0 006.586 13H4"
                                                        ]
                                                        []
                                                     ]
                                                 ]
                                            , div
                                                [ Attr.class "ml-4"
                                                ]
                                                [ p
                                                    [ Attr.class "text-base font-medium text-gray-900"
                                                    ]
                                                    [ text "Inbox" ]
                                                , p
                                                    [ Attr.class "mt-1 text-sm text-gray-500"
                                                    ]
                                                    [ text "Get a better understanding of where your traffic is coming from." ]
                                                 ]
                                             ]
                                        , a
                                            [ Attr.href "#"
                                            , Attr.class "-m-3 p-3 flex items-start rounded-lg hover:bg-gray-50"
                                            ]
                                            [ div
                                                [ Attr.class "flex-shrink-0 flex items-center justify-center h-10 w-10 rounded-md bg-gradient-to-r from-purple-600 to-indigo-600 text-white sm:h-12 sm:w-12"
                                                ]
                                                [                                                 {- Heroicon name: outline/annotation -}
                                                svg
                                                    [ SvgAttr.class "h-6 w-6"
                                                    , SvgAttr.fill "none"
                                                    , SvgAttr.viewBox "0 0 24 24"
                                                    , SvgAttr.stroke "currentColor"
                                                    , Attr.attribute "aria-hidden" "true"
                                                    ]
                                                    [ path
                                                        [ SvgAttr.strokeLinecap "round"
                                                        , SvgAttr.strokeLinejoin "round"
                                                        , SvgAttr.strokeWidth "2"
                                                        , SvgAttr.d "M7 8h10M7 12h4m1 8l-4-4H5a2 2 0 01-2-2V6a2 2 0 012-2h14a2 2 0 012 2v8a2 2 0 01-2 2h-3l-4 4z"
                                                        ]
                                                        []
                                                     ]
                                                 ]
                                            , div
                                                [ Attr.class "ml-4"
                                                ]
                                                [ p
                                                    [ Attr.class "text-base font-medium text-gray-900"
                                                    ]
                                                    [ text "Messaging" ]
                                                , p
                                                    [ Attr.class "mt-1 text-sm text-gray-500"
                                                    ]
                                                    [ text "Speak directly to your customers in a more meaningful way." ]
                                                 ]
                                             ]
                                        , a
                                            [ Attr.href "#"
                                            , Attr.class "-m-3 p-3 flex items-start rounded-lg hover:bg-gray-50"
                                            ]
                                            [ div
                                                [ Attr.class "flex-shrink-0 flex items-center justify-center h-10 w-10 rounded-md bg-gradient-to-r from-purple-600 to-indigo-600 text-white sm:h-12 sm:w-12"
                                                ]
                                                [                                                 {- Heroicon name: outline/chat-alt-2 -}
                                                svg
                                                    [ SvgAttr.class "h-6 w-6"
                                                    , SvgAttr.fill "none"
                                                    , SvgAttr.viewBox "0 0 24 24"
                                                    , SvgAttr.stroke "currentColor"
                                                    , Attr.attribute "aria-hidden" "true"
                                                    ]
                                                    [ path
                                                        [ SvgAttr.strokeLinecap "round"
                                                        , SvgAttr.strokeLinejoin "round"
                                                        , SvgAttr.strokeWidth "2"
                                                        , SvgAttr.d "M17 8h2a2 2 0 012 2v6a2 2 0 01-2 2h-2v4l-4-4H9a1.994 1.994 0 01-1.414-.586m0 0L11 14h4a2 2 0 002-2V6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2v4l.586-.586z"
                                                        ]
                                                        []
                                                     ]
                                                 ]
                                            , div
                                                [ Attr.class "ml-4"
                                                ]
                                                [ p
                                                    [ Attr.class "text-base font-medium text-gray-900"
                                                    ]
                                                    [ text "Live Chat" ]
                                                , p
                                                    [ Attr.class "mt-1 text-sm text-gray-500"
                                                    ]
                                                    [ text "Your customers' data will be safe and secure." ]
                                                 ]
                                             ]
                                        , a
                                            [ Attr.href "#"
                                            , Attr.class "-m-3 p-3 flex items-start rounded-lg hover:bg-gray-50"
                                            ]
                                            [ div
                                                [ Attr.class "flex-shrink-0 flex items-center justify-center h-10 w-10 rounded-md bg-gradient-to-r from-purple-600 to-indigo-600 text-white sm:h-12 sm:w-12"
                                                ]
                                                [                                                 {- Heroicon name: outline/question-mark-circle -}
                                                svg
                                                    [ SvgAttr.class "h-6 w-6"
                                                    , SvgAttr.fill "none"
                                                    , SvgAttr.viewBox "0 0 24 24"
                                                    , SvgAttr.stroke "currentColor"
                                                    , Attr.attribute "aria-hidden" "true"
                                                    ]
                                                    [ path
                                                        [ SvgAttr.strokeLinecap "round"
                                                        , SvgAttr.strokeLinejoin "round"
                                                        , SvgAttr.strokeWidth "2"
                                                        , SvgAttr.d "M8.228 9c.549-1.165 2.03-2 3.772-2 2.21 0 4 1.343 4 3 0 1.4-1.278 2.575-3.006 2.907-.542.104-.994.54-.994 1.093m0 3h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
                                                        ]
                                                        []
                                                     ]
                                                 ]
                                            , div
                                                [ Attr.class "ml-4"
                                                ]
                                                [ p
                                                    [ Attr.class "text-base font-medium text-gray-900"
                                                    ]
                                                    [ text "Knowledge Base" ]
                                                , p
                                                    [ Attr.class "mt-1 text-sm text-gray-500"
                                                    ]
                                                    [ text "Connect with third-party tools that you're already using." ]
                                                 ]
                                             ]
                                         ]
                                     ]
                                 ]
                             ]
                        , a
                            [ Attr.href "#"
                            , Attr.class "text-base font-medium text-gray-500 hover:text-gray-900"
                            ]
                            [ text "Pricing" ]
                        , a
                            [ Attr.href "#"
                            , Attr.class "text-base font-medium text-gray-500 hover:text-gray-900"
                            ]
                            [ text "Partners" ]
                        , a
                            [ Attr.href "#"
                            , Attr.class "text-base font-medium text-gray-500 hover:text-gray-900"
                            ]
                            [ text "Company" ]
                         ]
                    , div
                        [ Attr.class "hidden md:flex items-center justify-end md:flex-1 lg:w-0"
                        ]
                        [ a
                            [ Attr.href "#"
                            , Attr.class "whitespace-nowrap text-base font-medium text-gray-500 hover:text-gray-900"
                            ]
                            [ text "Sign in" ]
                        , a
                            [ Attr.href "#"
                            , Attr.class "ml-8 whitespace-nowrap inline-flex items-center justify-center bg-gradient-to-r from-purple-600 to-indigo-600 bg-origin-border px-4 py-2 border border-transparent rounded-md shadow-sm text-base font-medium text-white hover:from-purple-700 hover:to-indigo-700"
                            ]
                            [ text "Sign up" ]
                         ]
                     ]
                ,                 {-
        Mobile menu, show/hide based on mobile menu state.

        Entering: "duration-200 ease-out"
          From: "opacity-0 scale-95"
          To: "opacity-100 scale-100"
        Leaving: "duration-100 ease-in"
          From: "opacity-100 scale-100"
          To: "opacity-0 scale-95"
      -}
                div
                    [ Attr.class "absolute z-30 top-0 inset-x-0 p-2 transition transform origin-top-right md:hidden"
                    ]
                    [ div
                        [ Attr.class "rounded-lg shadow-lg ring-1 ring-black ring-opacity-5 bg-white divide-y-2 divide-gray-50"
                        ]
                        [ div
                            [ Attr.class "pt-5 pb-6 px-5"
                            ]
                            [ div
                                [ Attr.class "flex items-center justify-between"
                                ]
                                [ div []
                                    [ img
                                        [ Attr.class "h-8 w-auto"
                                        , Attr.src "https://tailwindui.com/img/logos/workflow-mark-purple-600-to-indigo-600.svg"
                                        , Attr.alt "Workflow"
                                        ]
                                        []
                                     ]
                                , div
                                    [ Attr.class "-mr-2"
                                    ]
                                    [ button
                                        [ Attr.type_ "button"
                                        , Attr.class "bg-white rounded-md p-2 inline-flex items-center justify-center text-gray-400 hover:text-gray-500 hover:bg-gray-100 focus:outline-none focus:ring-2 focus:ring-inset focus:ring-indigo-500"
                                        ]
                                        [ span
                                            [ Attr.class "sr-only"
                                            ]
                                            [ text "Close menu" ]
                                        ,                                         {- Heroicon name: outline/x -}
                                        svg
                                            [ SvgAttr.class "h-6 w-6"
                                            , SvgAttr.fill "none"
                                            , SvgAttr.viewBox "0 0 24 24"
                                            , SvgAttr.stroke "currentColor"
                                            , Attr.attribute "aria-hidden" "true"
                                            ]
                                            [ path
                                                [ SvgAttr.strokeLinecap "round"
                                                , SvgAttr.strokeLinejoin "round"
                                                , SvgAttr.strokeWidth "2"
                                                , SvgAttr.d "M6 18L18 6M6 6l12 12"
                                                ]
                                                []
                                             ]
                                         ]
                                     ]
                                 ]
                            , div
                                [ Attr.class "mt-6"
                                ]
                                [ nav
                                    [ Attr.class "grid grid-cols-1 gap-7"
                                    ]
                                    [ a
                                        [ Attr.href "#"
                                        , Attr.class "-m-3 p-3 flex items-center rounded-lg hover:bg-gray-50"
                                        ]
                                        [ div
                                            [ Attr.class "flex-shrink-0 flex items-center justify-center h-10 w-10 rounded-md bg-gradient-to-r from-purple-600 to-indigo-600 text-white"
                                            ]
                                            [                                             {- Heroicon name: outline/inbox -}
                                            svg
                                                [ SvgAttr.class "h-6 w-6"
                                                , SvgAttr.fill "none"
                                                , SvgAttr.viewBox "0 0 24 24"
                                                , SvgAttr.stroke "currentColor"
                                                , Attr.attribute "aria-hidden" "true"
                                                ]
                                                [ path
                                                    [ SvgAttr.strokeLinecap "round"
                                                    , SvgAttr.strokeLinejoin "round"
                                                    , SvgAttr.strokeWidth "2"
                                                    , SvgAttr.d "M20 13V6a2 2 0 00-2-2H6a2 2 0 00-2 2v7m16 0v5a2 2 0 01-2 2H6a2 2 0 01-2-2v-5m16 0h-2.586a1 1 0 00-.707.293l-2.414 2.414a1 1 0 01-.707.293h-3.172a1 1 0 01-.707-.293l-2.414-2.414A1 1 0 006.586 13H4"
                                                    ]
                                                    []
                                                 ]
                                             ]
                                        , div
                                            [ Attr.class "ml-4 text-base font-medium text-gray-900"
                                            ]
                                            [ text "Inbox" ]
                                         ]
                                    , a
                                        [ Attr.href "#"
                                        , Attr.class "-m-3 p-3 flex items-center rounded-lg hover:bg-gray-50"
                                        ]
                                        [ div
                                            [ Attr.class "flex-shrink-0 flex items-center justify-center h-10 w-10 rounded-md bg-gradient-to-r from-purple-600 to-indigo-600 text-white"
                                            ]
                                            [                                             {- Heroicon name: outline/annotation -}
                                            svg
                                                [ SvgAttr.class "h-6 w-6"
                                                , SvgAttr.fill "none"
                                                , SvgAttr.viewBox "0 0 24 24"
                                                , SvgAttr.stroke "currentColor"
                                                , Attr.attribute "aria-hidden" "true"
                                                ]
                                                [ path
                                                    [ SvgAttr.strokeLinecap "round"
                                                    , SvgAttr.strokeLinejoin "round"
                                                    , SvgAttr.strokeWidth "2"
                                                    , SvgAttr.d "M7 8h10M7 12h4m1 8l-4-4H5a2 2 0 01-2-2V6a2 2 0 012-2h14a2 2 0 012 2v8a2 2 0 01-2 2h-3l-4 4z"
                                                    ]
                                                    []
                                                 ]
                                             ]
                                        , div
                                            [ Attr.class "ml-4 text-base font-medium text-gray-900"
                                            ]
                                            [ text "Messaging" ]
                                         ]
                                    , a
                                        [ Attr.href "#"
                                        , Attr.class "-m-3 p-3 flex items-center rounded-lg hover:bg-gray-50"
                                        ]
                                        [ div
                                            [ Attr.class "flex-shrink-0 flex items-center justify-center h-10 w-10 rounded-md bg-gradient-to-r from-purple-600 to-indigo-600 text-white"
                                            ]
                                            [                                             {- Heroicon name: outline/chat-alt-2 -}
                                            svg
                                                [ SvgAttr.class "h-6 w-6"
                                                , SvgAttr.fill "none"
                                                , SvgAttr.viewBox "0 0 24 24"
                                                , SvgAttr.stroke "currentColor"
                                                , Attr.attribute "aria-hidden" "true"
                                                ]
                                                [ path
                                                    [ SvgAttr.strokeLinecap "round"
                                                    , SvgAttr.strokeLinejoin "round"
                                                    , SvgAttr.strokeWidth "2"
                                                    , SvgAttr.d "M17 8h2a2 2 0 012 2v6a2 2 0 01-2 2h-2v4l-4-4H9a1.994 1.994 0 01-1.414-.586m0 0L11 14h4a2 2 0 002-2V6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2v4l.586-.586z"
                                                    ]
                                                    []
                                                 ]
                                             ]
                                        , div
                                            [ Attr.class "ml-4 text-base font-medium text-gray-900"
                                            ]
                                            [ text "Live Chat" ]
                                         ]
                                    , a
                                        [ Attr.href "#"
                                        , Attr.class "-m-3 p-3 flex items-center rounded-lg hover:bg-gray-50"
                                        ]
                                        [ div
                                            [ Attr.class "flex-shrink-0 flex items-center justify-center h-10 w-10 rounded-md bg-gradient-to-r from-purple-600 to-indigo-600 text-white"
                                            ]
                                            [                                             {- Heroicon name: outline/question-mark-circle -}
                                            svg
                                                [ SvgAttr.class "h-6 w-6"
                                                , SvgAttr.fill "none"
                                                , SvgAttr.viewBox "0 0 24 24"
                                                , SvgAttr.stroke "currentColor"
                                                , Attr.attribute "aria-hidden" "true"
                                                ]
                                                [ path
                                                    [ SvgAttr.strokeLinecap "round"
                                                    , SvgAttr.strokeLinejoin "round"
                                                    , SvgAttr.strokeWidth "2"
                                                    , SvgAttr.d "M8.228 9c.549-1.165 2.03-2 3.772-2 2.21 0 4 1.343 4 3 0 1.4-1.278 2.575-3.006 2.907-.542.104-.994.54-.994 1.093m0 3h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
                                                    ]
                                                    []
                                                 ]
                                             ]
                                        , div
                                            [ Attr.class "ml-4 text-base font-medium text-gray-900"
                                            ]
                                            [ text "Knowledge Base" ]
                                         ]
                                     ]
                                 ]
                             ]
                        , div
                            [ Attr.class "py-6 px-5"
                            ]
                            [ div
                                [ Attr.class "grid grid-cols-2 gap-4"
                                ]
                                [ a
                                    [ Attr.href "#"
                                    , Attr.class "text-base font-medium text-gray-900 hover:text-gray-700"
                                    ]
                                    [ text "Pricing" ]
                                , a
                                    [ Attr.href "#"
                                    , Attr.class "text-base font-medium text-gray-900 hover:text-gray-700"
                                    ]
                                    [ text "Partners" ]
                                , a
                                    [ Attr.href "#"
                                    , Attr.class "text-base font-medium text-gray-900 hover:text-gray-700"
                                    ]
                                    [ text "Company" ]
                                 ]
                            , div
                                [ Attr.class "mt-6"
                                ]
                                [ a
                                    [ Attr.href "#"
                                    , Attr.class "w-full flex items-center justify-center bg-gradient-to-r from-purple-600 to-indigo-600 bg-origin-border px-4 py-2 border border-transparent rounded-md shadow-sm text-base font-medium text-white hover:from-purple-700 hover:to-indigo-700"
                                    ]
                                    [ text "Sign up" ]
                                , p
                                    [ Attr.class "mt-6 text-center text-base font-medium text-gray-500"
                                    ]
                                    [ text "Existing customer?", a
                                        [ Attr.href "#"
                                        , Attr.class "text-gray-900"
                                        ]
                                        [ text "Sign in" ]
                                     ]
                                 ]
                             ]
                         ]
                     ]
                 ]
             ]
        , main_ []
            [             {- Hero section -}
            div
                [ Attr.class "relative"
                ]
                [ div
                    [ Attr.class "absolute inset-x-0 bottom-0 h-1/2 bg-gray-100"
                    ]
                    []
                , div
                    [ Attr.class "max-w-7xl mx-auto sm:px-6 lg:px-8"
                    ]
                    [ div
                        [ Attr.class "relative shadow-xl sm:rounded-2xl sm:overflow-hidden"
                        ]
                        [ div
                            [ Attr.class "absolute inset-0"
                            ]
                            [ img
                                [ Attr.class "h-full w-full object-cover"
                                , Attr.src "https://images.unsplash.com/photo-1521737852567-6949f3f9f2b5?ixid=MXwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHw%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=2830&q=80&sat=-100"
                                , Attr.alt "People working on laptops"
                                ]
                                []
                            , div
                                [ Attr.class "absolute inset-0 bg-gradient-to-r from-purple-800 to-indigo-700 mix-blend-multiply"
                                ]
                                []
                             ]
                        , div
                            [ Attr.class "relative px-4 py-16 sm:px-6 sm:py-24 lg:py-32 lg:px-8"
                            ]
                            [ h1
                                [ Attr.class "text-center text-4xl font-extrabold tracking-tight sm:text-5xl lg:text-6xl"
                                ]
                                [ span
                                    [ Attr.class "block text-white"
                                    ]
                                    [ text "Take control of your" ]
                                , span
                                    [ Attr.class "block text-indigo-200"
                                    ]
                                    [ text "customer support" ]
                                 ]
                            , p
                                [ Attr.class "mt-6 max-w-lg mx-auto text-center text-xl text-indigo-200 sm:max-w-3xl"
                                ]
                                [ text "Anim aute id magna aliqua ad ad non deserunt sunt. Qui irure qui lorem cupidatat commodo. Elit sunt amet fugiat veniam occaecat fugiat aliqua." ]
                            , div
                                [ Attr.class "mt-10 max-w-sm mx-auto sm:max-w-none sm:flex sm:justify-center"
                                ]
                                [ div
                                    [ Attr.class "space-y-4 sm:space-y-0 sm:mx-auto sm:inline-grid sm:grid-cols-2 sm:gap-5"
                                    ]
                                    [ a
                                        [ Attr.href "#"
                                        , Attr.class "flex items-center justify-center px-4 py-3 border border-transparent text-base font-medium rounded-md shadow-sm text-indigo-700 bg-white hover:bg-indigo-50 sm:px-8"
                                        ]
                                        [ text "Get started" ]
                                    , a
                                        [ Attr.href "#"
                                        , Attr.class "flex items-center justify-center px-4 py-3 border border-transparent text-base font-medium rounded-md shadow-sm text-white bg-indigo-500 bg-opacity-60 hover:bg-opacity-70 sm:px-8"
                                        ]
                                        [ text "Live demo" ]
                                     ]
                                 ]
                             ]
                         ]
                     ]
                 ]
            ,             {- Logo Cloud -}
            div
                [ Attr.class "bg-gray-100"
                ]
                [ div
                    [ Attr.class "max-w-7xl mx-auto py-16 px-4 sm:px-6 lg:px-8"
                    ]
                    [ p
                        [ Attr.class "text-center text-sm font-semibold uppercase text-gray-500 tracking-wide"
                        ]
                        [ text "Trusted by over 5 very average small businesses" ]
                    , div
                        [ Attr.class "mt-6 grid grid-cols-2 gap-8 md:grid-cols-6 lg:grid-cols-5"
                        ]
                        [ div
                            [ Attr.class "col-span-1 flex justify-center md:col-span-2 lg:col-span-1"
                            ]
                            [ img
                                [ Attr.class "h-12"
                                , Attr.src "https://tailwindui.com/img/logos/tuple-logo-gray-400.svg"
                                , Attr.alt "Tuple"
                                ]
                                []
                             ]
                        , div
                            [ Attr.class "col-span-1 flex justify-center md:col-span-2 lg:col-span-1"
                            ]
                            [ img
                                [ Attr.class "h-12"
                                , Attr.src "https://tailwindui.com/img/logos/mirage-logo-gray-400.svg"
                                , Attr.alt "Mirage"
                                ]
                                []
                             ]
                        , div
                            [ Attr.class "col-span-1 flex justify-center md:col-span-2 lg:col-span-1"
                            ]
                            [ img
                                [ Attr.class "h-12"
                                , Attr.src "https://tailwindui.com/img/logos/statickit-logo-gray-400.svg"
                                , Attr.alt "StaticKit"
                                ]
                                []
                             ]
                        , div
                            [ Attr.class "col-span-1 flex justify-center md:col-span-2 md:col-start-2 lg:col-span-1"
                            ]
                            [ img
                                [ Attr.class "h-12"
                                , Attr.src "https://tailwindui.com/img/logos/transistor-logo-gray-400.svg"
                                , Attr.alt "Transistor"
                                ]
                                []
                             ]
                        , div
                            [ Attr.class "col-span-2 flex justify-center md:col-span-2 md:col-start-4 lg:col-span-1"
                            ]
                            [ img
                                [ Attr.class "h-12"
                                , Attr.src "https://tailwindui.com/img/logos/workcation-logo-gray-400.svg"
                                , Attr.alt "Workcation"
                                ]
                                []
                             ]
                         ]
                     ]
                 ]
            ,             {- Alternating Feature Sections -}
            div
                [ Attr.class "relative pt-16 pb-32 overflow-hidden"
                ]
                [ div
                    [ Attr.attribute "aria-hidden" "true"
                    , Attr.class "absolute inset-x-0 top-0 h-48 bg-gradient-to-b from-gray-100"
                    ]
                    []
                , div
                    [ Attr.class "relative"
                    ]
                    [ div
                        [ Attr.class "lg:mx-auto lg:max-w-7xl lg:px-8 lg:grid lg:grid-cols-2 lg:grid-flow-col-dense lg:gap-24"
                        ]
                        [ div
                            [ Attr.class "px-4 max-w-xl mx-auto sm:px-6 lg:py-16 lg:max-w-none lg:mx-0 lg:px-0"
                            ]
                            [ div []
                                [ div []
                                    [ span
                                        [ Attr.class "h-12 w-12 rounded-md flex items-center justify-center bg-gradient-to-r from-purple-600 to-indigo-600"
                                        ]
                                        [                                         {- Heroicon name: outline/inbox -}
                                        svg
                                            [ SvgAttr.class "h-6 w-6 text-white"
                                            , SvgAttr.fill "none"
                                            , SvgAttr.viewBox "0 0 24 24"
                                            , SvgAttr.stroke "currentColor"
                                            , Attr.attribute "aria-hidden" "true"
                                            ]
                                            [ path
                                                [ SvgAttr.strokeLinecap "round"
                                                , SvgAttr.strokeLinejoin "round"
                                                , SvgAttr.strokeWidth "2"
                                                , SvgAttr.d "M20 13V6a2 2 0 00-2-2H6a2 2 0 00-2 2v7m16 0v5a2 2 0 01-2 2H6a2 2 0 01-2-2v-5m16 0h-2.586a1 1 0 00-.707.293l-2.414 2.414a1 1 0 01-.707.293h-3.172a1 1 0 01-.707-.293l-2.414-2.414A1 1 0 006.586 13H4"
                                                ]
                                                []
                                             ]
                                         ]
                                     ]
                                , div
                                    [ Attr.class "mt-6"
                                    ]
                                    [ h2
                                        [ Attr.class "text-3xl font-extrabold tracking-tight text-gray-900"
                                        ]
                                        [ text "Stay on top of customer support" ]
                                    , p
                                        [ Attr.class "mt-4 text-lg text-gray-500"
                                        ]
                                        [ text "Semper curabitur ullamcorper posuere nunc sed. Ornare iaculis bibendum malesuada faucibus lacinia porttitor. Pulvinar laoreet sagittis viverra duis. In venenatis sem arcu pretium pharetra at. Lectus viverra dui tellus ornare pharetra." ]
                                    , div
                                        [ Attr.class "mt-6"
                                        ]
                                        [ a
                                            [ Attr.href "#"
                                            , Attr.class "inline-flex bg-gradient-to-r from-purple-600 to-indigo-600 bg-origin-border px-4 py-2 border border-transparent text-base font-medium rounded-md shadow-sm text-white hover:from-purple-700 hover:to-indigo-700"
                                            ]
                                            [ text "Get started" ]
                                         ]
                                     ]
                                 ]
                            , div
                                [ Attr.class "mt-8 border-t border-gray-200 pt-6"
                                ]
                                [ blockquote []
                                    [ div []
                                        [ p
                                            [ Attr.class "text-base text-gray-500"
                                            ]
                                            [ text "“Cras velit quis eros eget rhoncus lacus ultrices sed diam. Sit orci risus aenean curabitur donec aliquet. Mi venenatis in euismod ut.”" ]
                                         ]
                                    , footer
                                        [ Attr.class "mt-3"
                                        ]
                                        [ div
                                            [ Attr.class "flex items-center space-x-3"
                                            ]
                                            [ div
                                                [ Attr.class "flex-shrink-0"
                                                ]
                                                [ img
                                                    [ Attr.class "h-6 w-6 rounded-full"
                                                    , Attr.src "https://images.unsplash.com/photo-1509783236416-c9ad59bae472?ixlib=rb-=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=facearea&facepad=8&w=1024&h=1024&q=80"
                                                    , Attr.alt ""
                                                    ]
                                                    []
                                                 ]
                                            , div
                                                [ Attr.class "text-base font-medium text-gray-700"
                                                ]
                                                [ text "Marcia Hill, Digital Marketing Manager" ]
                                             ]
                                         ]
                                     ]
                                 ]
                             ]
                        , div
                            [ Attr.class "mt-12 sm:mt-16 lg:mt-0"
                            ]
                            [ div
                                [ Attr.class "pl-4 -mr-48 sm:pl-6 md:-mr-16 lg:px-0 lg:m-0 lg:relative lg:h-full"
                                ]
                                [ img
                                    [ Attr.class "w-full rounded-xl shadow-xl ring-1 ring-black ring-opacity-5 lg:absolute lg:left-0 lg:h-full lg:w-auto lg:max-w-none"
                                    , Attr.src "https://tailwindui.com/img/component-images/inbox-app-screenshot-1.jpg"
                                    , Attr.alt "Inbox user interface"
                                    ]
                                    []
                                 ]
                             ]
                         ]
                     ]
                , div
                    [ Attr.class "mt-24"
                    ]
                    [ div
                        [ Attr.class "lg:mx-auto lg:max-w-7xl lg:px-8 lg:grid lg:grid-cols-2 lg:grid-flow-col-dense lg:gap-24"
                        ]
                        [ div
                            [ Attr.class "px-4 max-w-xl mx-auto sm:px-6 lg:py-32 lg:max-w-none lg:mx-0 lg:px-0 lg:col-start-2"
                            ]
                            [ div []
                                [ div []
                                    [ span
                                        [ Attr.class "h-12 w-12 rounded-md flex items-center justify-center bg-gradient-to-r from-purple-600 to-indigo-600"
                                        ]
                                        [                                         {- Heroicon name: outline/sparkles -}
                                        svg
                                            [ SvgAttr.class "h-6 w-6 text-white"
                                            , SvgAttr.fill "none"
                                            , SvgAttr.viewBox "0 0 24 24"
                                            , SvgAttr.stroke "currentColor"
                                            , Attr.attribute "aria-hidden" "true"
                                            ]
                                            [ path
                                                [ SvgAttr.strokeLinecap "round"
                                                , SvgAttr.strokeLinejoin "round"
                                                , SvgAttr.strokeWidth "2"
                                                , SvgAttr.d "M5 3v4M3 5h4M6 17v4m-2-2h4m5-16l2.286 6.857L21 12l-5.714 2.143L13 21l-2.286-6.857L5 12l5.714-2.143L13 3z"
                                                ]
                                                []
                                             ]
                                         ]
                                     ]
                                , div
                                    [ Attr.class "mt-6"
                                    ]
                                    [ h2
                                        [ Attr.class "text-3xl font-extrabold tracking-tight text-gray-900"
                                        ]
                                        [ text "Better understand your customers" ]
                                    , p
                                        [ Attr.class "mt-4 text-lg text-gray-500"
                                        ]
                                        [ text "Semper curabitur ullamcorper posuere nunc sed. Ornare iaculis bibendum malesuada faucibus lacinia porttitor. Pulvinar laoreet sagittis viverra duis. In venenatis sem arcu pretium pharetra at. Lectus viverra dui tellus ornare pharetra." ]
                                    , div
                                        [ Attr.class "mt-6"
                                        ]
                                        [ a
                                            [ Attr.href "#"
                                            , Attr.class "inline-flex bg-gradient-to-r from-purple-600 to-indigo-600 bg-origin-border px-4 py-2 border border-transparent text-base font-medium rounded-md shadow-sm text-white hover:from-purple-700 hover:to-indigo-700"
                                            ]
                                            [ text "Get started" ]
                                         ]
                                     ]
                                 ]
                             ]
                        , div
                            [ Attr.class "mt-12 sm:mt-16 lg:mt-0 lg:col-start-1"
                            ]
                            [ div
                                [ Attr.class "pr-4 -ml-48 sm:pr-6 md:-ml-16 lg:px-0 lg:m-0 lg:relative lg:h-full"
                                ]
                                [ img
                                    [ Attr.class "w-full rounded-xl shadow-xl ring-1 ring-black ring-opacity-5 lg:absolute lg:right-0 lg:h-full lg:w-auto lg:max-w-none"
                                    , Attr.src "https://tailwindui.com/img/component-images/inbox-app-screenshot-2.jpg"
                                    , Attr.alt "Customer profile user interface"
                                    ]
                                    []
                                 ]
                             ]
                         ]
                     ]
                 ]
            ,             {- Gradient Feature Section -}
            div
                [ Attr.class "bg-gradient-to-r from-purple-800 to-indigo-700"
                ]
                [ div
                    [ Attr.class "max-w-4xl mx-auto px-4 py-16 sm:px-6 sm:pt-20 sm:pb-24 lg:max-w-7xl lg:pt-24 lg:px-8"
                    ]
                    [ h2
                        [ Attr.class "text-3xl font-extrabold text-white tracking-tight"
                        ]
                        [ text "Inbox support built for efficiency" ]
                    , p
                        [ Attr.class "mt-4 max-w-3xl text-lg text-purple-200"
                        ]
                        [ text "Ac tincidunt sapien vehicula erat auctor pellentesque rhoncus. Et magna sit morbi lobortis. Blandit aliquam sit nisl euismod mattis in." ]
                    , div
                        [ Attr.class "mt-12 grid grid-cols-1 gap-x-6 gap-y-12 sm:grid-cols-2 lg:mt-16 lg:grid-cols-4 lg:gap-x-8 lg:gap-y-16"
                        ]
                        [ div []
                            [ div []
                                [ span
                                    [ Attr.class "flex items-center justify-center h-12 w-12 rounded-md bg-white bg-opacity-10"
                                    ]
                                    [                                     {- Heroicon name: outline/inbox -}
                                    svg
                                        [ SvgAttr.class "h-6 w-6 text-white"
                                        , SvgAttr.fill "none"
                                        , SvgAttr.viewBox "0 0 24 24"
                                        , SvgAttr.stroke "currentColor"
                                        , Attr.attribute "aria-hidden" "true"
                                        ]
                                        [ path
                                            [ SvgAttr.strokeLinecap "round"
                                            , SvgAttr.strokeLinejoin "round"
                                            , SvgAttr.strokeWidth "2"
                                            , SvgAttr.d "M20 13V6a2 2 0 00-2-2H6a2 2 0 00-2 2v7m16 0v5a2 2 0 01-2 2H6a2 2 0 01-2-2v-5m16 0h-2.586a1 1 0 00-.707.293l-2.414 2.414a1 1 0 01-.707.293h-3.172a1 1 0 01-.707-.293l-2.414-2.414A1 1 0 006.586 13H4"
                                            ]
                                            []
                                         ]
                                     ]
                                 ]
                            , div
                                [ Attr.class "mt-6"
                                ]
                                [ h3
                                    [ Attr.class "text-lg font-medium text-white"
                                    ]
                                    [ text "Unlimited Inboxes" ]
                                , p
                                    [ Attr.class "mt-2 text-base text-purple-200"
                                    ]
                                    [ text "Ac tincidunt sapien vehicula erat auctor pellentesque rhoncus. Et magna sit morbi lobortis." ]
                                 ]
                             ]
                        , div []
                            [ div []
                                [ span
                                    [ Attr.class "flex items-center justify-center h-12 w-12 rounded-md bg-white bg-opacity-10"
                                    ]
                                    [                                     {- Heroicon name: outline/users -}
                                    svg
                                        [ SvgAttr.class "h-6 w-6 text-white"
                                        , SvgAttr.fill "none"
                                        , SvgAttr.viewBox "0 0 24 24"
                                        , SvgAttr.stroke "currentColor"
                                        , Attr.attribute "aria-hidden" "true"
                                        ]
                                        [ path
                                            [ SvgAttr.strokeLinecap "round"
                                            , SvgAttr.strokeLinejoin "round"
                                            , SvgAttr.strokeWidth "2"
                                            , SvgAttr.d "M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z"
                                            ]
                                            []
                                         ]
                                     ]
                                 ]
                            , div
                                [ Attr.class "mt-6"
                                ]
                                [ h3
                                    [ Attr.class "text-lg font-medium text-white"
                                    ]
                                    [ text "Manage Team Members" ]
                                , p
                                    [ Attr.class "mt-2 text-base text-purple-200"
                                    ]
                                    [ text "Ac tincidunt sapien vehicula erat auctor pellentesque rhoncus. Et magna sit morbi lobortis." ]
                                 ]
                             ]
                        , div []
                            [ div []
                                [ span
                                    [ Attr.class "flex items-center justify-center h-12 w-12 rounded-md bg-white bg-opacity-10"
                                    ]
                                    [                                     {- Heroicon name: outline/trash -}
                                    svg
                                        [ SvgAttr.class "h-6 w-6 text-white"
                                        , SvgAttr.fill "none"
                                        , SvgAttr.viewBox "0 0 24 24"
                                        , SvgAttr.stroke "currentColor"
                                        , Attr.attribute "aria-hidden" "true"
                                        ]
                                        [ path
                                            [ SvgAttr.strokeLinecap "round"
                                            , SvgAttr.strokeLinejoin "round"
                                            , SvgAttr.strokeWidth "2"
                                            , SvgAttr.d "M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"
                                            ]
                                            []
                                         ]
                                     ]
                                 ]
                            , div
                                [ Attr.class "mt-6"
                                ]
                                [ h3
                                    [ Attr.class "text-lg font-medium text-white"
                                    ]
                                    [ text "Spam Report" ]
                                , p
                                    [ Attr.class "mt-2 text-base text-purple-200"
                                    ]
                                    [ text "Ac tincidunt sapien vehicula erat auctor pellentesque rhoncus. Et magna sit morbi lobortis." ]
                                 ]
                             ]
                        , div []
                            [ div []
                                [ span
                                    [ Attr.class "flex items-center justify-center h-12 w-12 rounded-md bg-white bg-opacity-10"
                                    ]
                                    [                                     {- Heroicon name: outline/pencil-alt -}
                                    svg
                                        [ SvgAttr.class "h-6 w-6 text-white"
                                        , SvgAttr.fill "none"
                                        , SvgAttr.viewBox "0 0 24 24"
                                        , SvgAttr.stroke "currentColor"
                                        , Attr.attribute "aria-hidden" "true"
                                        ]
                                        [ path
                                            [ SvgAttr.strokeLinecap "round"
                                            , SvgAttr.strokeLinejoin "round"
                                            , SvgAttr.strokeWidth "2"
                                            , SvgAttr.d "M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"
                                            ]
                                            []
                                         ]
                                     ]
                                 ]
                            , div
                                [ Attr.class "mt-6"
                                ]
                                [ h3
                                    [ Attr.class "text-lg font-medium text-white"
                                    ]
                                    [ text "Compose in Markdown" ]
                                , p
                                    [ Attr.class "mt-2 text-base text-purple-200"
                                    ]
                                    [ text "Ac tincidunt sapien vehicula erat auctor pellentesque rhoncus. Et magna sit morbi lobortis." ]
                                 ]
                             ]
                        , div []
                            [ div []
                                [ span
                                    [ Attr.class "flex items-center justify-center h-12 w-12 rounded-md bg-white bg-opacity-10"
                                    ]
                                    [                                     {- Heroicon name: outline/document-report -}
                                    svg
                                        [ SvgAttr.class "h-6 w-6 text-white"
                                        , SvgAttr.fill "none"
                                        , SvgAttr.viewBox "0 0 24 24"
                                        , SvgAttr.stroke "currentColor"
                                        , Attr.attribute "aria-hidden" "true"
                                        ]
                                        [ path
                                            [ SvgAttr.strokeLinecap "round"
                                            , SvgAttr.strokeLinejoin "round"
                                            , SvgAttr.strokeWidth "2"
                                            , SvgAttr.d "M9 17v-2m3 2v-4m3 4v-6m2 10H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"
                                            ]
                                            []
                                         ]
                                     ]
                                 ]
                            , div
                                [ Attr.class "mt-6"
                                ]
                                [ h3
                                    [ Attr.class "text-lg font-medium text-white"
                                    ]
                                    [ text "Team Reporting" ]
                                , p
                                    [ Attr.class "mt-2 text-base text-purple-200"
                                    ]
                                    [ text "Ac tincidunt sapien vehicula erat auctor pellentesque rhoncus. Et magna sit morbi lobortis." ]
                                 ]
                             ]
                        , div []
                            [ div []
                                [ span
                                    [ Attr.class "flex items-center justify-center h-12 w-12 rounded-md bg-white bg-opacity-10"
                                    ]
                                    [                                     {- Heroicon name: outline/reply -}
                                    svg
                                        [ SvgAttr.class "h-6 w-6 text-white"
                                        , SvgAttr.fill "none"
                                        , SvgAttr.viewBox "0 0 24 24"
                                        , SvgAttr.stroke "currentColor"
                                        , Attr.attribute "aria-hidden" "true"
                                        ]
                                        [ path
                                            [ SvgAttr.strokeLinecap "round"
                                            , SvgAttr.strokeLinejoin "round"
                                            , SvgAttr.strokeWidth "2"
                                            , SvgAttr.d "M3 10h10a8 8 0 018 8v2M3 10l6 6m-6-6l6-6"
                                            ]
                                            []
                                         ]
                                     ]
                                 ]
                            , div
                                [ Attr.class "mt-6"
                                ]
                                [ h3
                                    [ Attr.class "text-lg font-medium text-white"
                                    ]
                                    [ text "Saved Replies" ]
                                , p
                                    [ Attr.class "mt-2 text-base text-purple-200"
                                    ]
                                    [ text "Ac tincidunt sapien vehicula erat auctor pellentesque rhoncus. Et magna sit morbi lobortis." ]
                                 ]
                             ]
                        , div []
                            [ div []
                                [ span
                                    [ Attr.class "flex items-center justify-center h-12 w-12 rounded-md bg-white bg-opacity-10"
                                    ]
                                    [                                     {- Heroicon name: outline/chat-alt -}
                                    svg
                                        [ SvgAttr.class "h-6 w-6 text-white"
                                        , SvgAttr.fill "none"
                                        , SvgAttr.viewBox "0 0 24 24"
                                        , SvgAttr.stroke "currentColor"
                                        , Attr.attribute "aria-hidden" "true"
                                        ]
                                        [ path
                                            [ SvgAttr.strokeLinecap "round"
                                            , SvgAttr.strokeLinejoin "round"
                                            , SvgAttr.strokeWidth "2"
                                            , SvgAttr.d "M8 10h.01M12 10h.01M16 10h.01M9 16H5a2 2 0 01-2-2V6a2 2 0 012-2h14a2 2 0 012 2v8a2 2 0 01-2 2h-5l-5 5v-5z"
                                            ]
                                            []
                                         ]
                                     ]
                                 ]
                            , div
                                [ Attr.class "mt-6"
                                ]
                                [ h3
                                    [ Attr.class "text-lg font-medium text-white"
                                    ]
                                    [ text "Email Commenting" ]
                                , p
                                    [ Attr.class "mt-2 text-base text-purple-200"
                                    ]
                                    [ text "Ac tincidunt sapien vehicula erat auctor pellentesque rhoncus. Et magna sit morbi lobortis." ]
                                 ]
                             ]
                        , div []
                            [ div []
                                [ span
                                    [ Attr.class "flex items-center justify-center h-12 w-12 rounded-md bg-white bg-opacity-10"
                                    ]
                                    [                                     {- Heroicon name: outline/heart -}
                                    svg
                                        [ SvgAttr.class "h-6 w-6 text-white"
                                        , SvgAttr.fill "none"
                                        , SvgAttr.viewBox "0 0 24 24"
                                        , SvgAttr.stroke "currentColor"
                                        , Attr.attribute "aria-hidden" "true"
                                        ]
                                        [ path
                                            [ SvgAttr.strokeLinecap "round"
                                            , SvgAttr.strokeLinejoin "round"
                                            , SvgAttr.strokeWidth "2"
                                            , SvgAttr.d "M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z"
                                            ]
                                            []
                                         ]
                                     ]
                                 ]
                            , div
                                [ Attr.class "mt-6"
                                ]
                                [ h3
                                    [ Attr.class "text-lg font-medium text-white"
                                    ]
                                    [ text "Connect with Customers" ]
                                , p
                                    [ Attr.class "mt-2 text-base text-purple-200"
                                    ]
                                    [ text "Ac tincidunt sapien vehicula erat auctor pellentesque rhoncus. Et magna sit morbi lobortis." ]
                                 ]
                             ]
                         ]
                     ]
                 ]
            ,             {- Stats section -}
            div
                [ Attr.class "relative bg-gray-900"
                ]
                [ div
                    [ Attr.class "h-80 absolute inset-x-0 bottom-0 xl:top-0 xl:h-full"
                    ]
                    [ div
                        [ Attr.class "h-full w-full xl:grid xl:grid-cols-2"
                        ]
                        [ div
                            [ Attr.class "h-full xl:relative xl:col-start-2"
                            ]
                            [ img
                                [ Attr.class "h-full w-full object-cover opacity-25 xl:absolute xl:inset-0"
                                , Attr.src "https://images.unsplash.com/photo-1521737852567-6949f3f9f2b5?ixid=MXwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHw%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=2830&q=80&sat=-100"
                                , Attr.alt "People working on laptops"
                                ]
                                []
                            , div
                                [ Attr.attribute "aria-hidden" "true"
                                , Attr.class "absolute inset-x-0 top-0 h-32 bg-gradient-to-b from-gray-900 xl:inset-y-0 xl:left-0 xl:h-full xl:w-32 xl:bg-gradient-to-r"
                                ]
                                []
                             ]
                         ]
                     ]
                , div
                    [ Attr.class "max-w-4xl mx-auto px-4 sm:px-6 lg:max-w-7xl lg:px-8 xl:grid xl:grid-cols-2 xl:grid-flow-col-dense xl:gap-x-8"
                    ]
                    [ div
                        [ Attr.class "relative pt-12 pb-64 sm:pt-24 sm:pb-64 xl:col-start-1 xl:pb-24"
                        ]
                        [ h2
                            [ Attr.class "text-sm font-semibold tracking-wide uppercase"
                            ]
                            [ span
                                [ Attr.class "bg-gradient-to-r from-purple-300 to-indigo-300 bg-clip-text text-transparent"
                                ]
                                [ text "Valuable Metrics" ]
                             ]
                        , p
                            [ Attr.class "mt-3 text-3xl font-extrabold text-white"
                            ]
                            [ text "Get actionable data that will help grow your business" ]
                        , p
                            [ Attr.class "mt-5 text-lg text-gray-300"
                            ]
                            [ text "Rhoncus sagittis risus arcu erat lectus bibendum. Ut in adipiscing quis in viverra tristique sem. Ornare feugiat viverra eleifend fusce orci in quis amet. Sit in et vitae tortor, massa. Dapibus laoreet amet lacus nibh integer quis. Eu vulputate diam sit tellus quis at." ]
                        , div
                            [ Attr.class "mt-12 grid grid-cols-1 gap-y-12 gap-x-6 sm:grid-cols-2"
                            ]
                            [ p []
                                [ span
                                    [ Attr.class "block text-2xl font-bold text-white"
                                    ]
                                    [ text "8K+" ]
                                , span
                                    [ Attr.class "mt-1 block text-base text-gray-300"
                                    ]
                                    [ span
                                        [ Attr.class "font-medium text-white"
                                        ]
                                        [ text "Companies" ]
                                    , text "use laoreet amet lacus nibh integer quis." ]
                                 ]
                            , p []
                                [ span
                                    [ Attr.class "block text-2xl font-bold text-white"
                                    ]
                                    [ text "25K+" ]
                                , span
                                    [ Attr.class "mt-1 block text-base text-gray-300"
                                    ]
                                    [ span
                                        [ Attr.class "font-medium text-white"
                                        ]
                                        [ text "Countries around the globe" ]
                                    , text "lacus nibh integer quis." ]
                                 ]
                            , p []
                                [ span
                                    [ Attr.class "block text-2xl font-bold text-white"
                                    ]
                                    [ text "98%" ]
                                , span
                                    [ Attr.class "mt-1 block text-base text-gray-300"
                                    ]
                                    [ span
                                        [ Attr.class "font-medium text-white"
                                        ]
                                        [ text "Customer satisfaction" ]
                                    , text "laoreet amet lacus nibh integer quis." ]
                                 ]
                            , p []
                                [ span
                                    [ Attr.class "block text-2xl font-bold text-white"
                                    ]
                                    [ text "12M+" ]
                                , span
                                    [ Attr.class "mt-1 block text-base text-gray-300"
                                    ]
                                    [ span
                                        [ Attr.class "font-medium text-white"
                                        ]
                                        [ text "Issues resolved" ]
                                    , text "lacus nibh integer quis." ]
                                 ]
                             ]
                         ]
                     ]
                 ]
            , div
                [ Attr.class "bg-white"
                ]
                [ div
                    [ Attr.class "max-w-4xl mx-auto py-16 px-4 sm:px-6 sm:py-24 lg:max-w-7xl lg:px-8 lg:flex lg:items-center lg:justify-between"
                    ]
                    [ h2
                        [ Attr.class "text-4xl font-extrabold tracking-tight text-gray-900 sm:text-4xl"
                        ]
                        [ span
                            [ Attr.class "block"
                            ]
                            [ text "Ready to get started?" ]
                        , span
                            [ Attr.class "block bg-gradient-to-r from-purple-600 to-indigo-600 bg-clip-text text-transparent"
                            ]
                            [ text "Get in touch or create an account." ]
                         ]
                    , div
                        [ Attr.class "mt-6 space-y-4 sm:space-y-0 sm:flex sm:space-x-5"
                        ]
                        [ a
                            [ Attr.href "#"
                            , Attr.class "flex items-center justify-center bg-gradient-to-r from-purple-600 to-indigo-600 bg-origin-border px-4 py-3 border border-transparent text-base font-medium rounded-md shadow-sm text-white hover:from-purple-700 hover:to-indigo-700"
                            ]
                            [ text "Learn more" ]
                        , a
                            [ Attr.href "#"
                            , Attr.class "flex items-center justify-center px-4 py-3 border border-transparent text-base font-medium rounded-md shadow-sm text-indigo-800 bg-indigo-50 hover:bg-indigo-100"
                            ]
                            [ text "Get started" ]
                         ]
                     ]
                 ]
             ]
        , footer
            [ Attr.class "bg-gray-50"
            , Attr.attribute "aria-labelledby" "footer-heading"
            ]
            [ h2
                [ Attr.id "footer-heading"
                , Attr.class "sr-only"
                ]
                [ text "Footer" ]
            , div
                [ Attr.class "max-w-7xl mx-auto pt-16 pb-8 px-4 sm:px-6 lg:pt-24 lg:px-8"
                ]
                [ div
                    [ Attr.class "xl:grid xl:grid-cols-3 xl:gap-8"
                    ]
                    [ div
                        [ Attr.class "grid grid-cols-2 gap-8 xl:col-span-2"
                        ]
                        [ div
                            [ Attr.class "md:grid md:grid-cols-2 md:gap-8"
                            ]
                            [ div []
                                [ h3
                                    [ Attr.class "text-sm font-semibold text-gray-400 tracking-wider uppercase"
                                    ]
                                    [ text "Solutions" ]
                                , ul
                                    [ Attr.class "mt-4 space-y-4"
                                    ]
                                    [ li []
                                        [ a
                                            [ Attr.href "#"
                                            , Attr.class "text-base text-gray-500 hover:text-gray-900"
                                            ]
                                            [ text "Marketing" ]
                                         ]
                                    , li []
                                        [ a
                                            [ Attr.href "#"
                                            , Attr.class "text-base text-gray-500 hover:text-gray-900"
                                            ]
                                            [ text "Analytics" ]
                                         ]
                                    , li []
                                        [ a
                                            [ Attr.href "#"
                                            , Attr.class "text-base text-gray-500 hover:text-gray-900"
                                            ]
                                            [ text "Commerce" ]
                                         ]
                                    , li []
                                        [ a
                                            [ Attr.href "#"
                                            , Attr.class "text-base text-gray-500 hover:text-gray-900"
                                            ]
                                            [ text "Insights" ]
                                         ]
                                     ]
                                 ]
                            , div
                                [ Attr.class "mt-12 md:mt-0"
                                ]
                                [ h3
                                    [ Attr.class "text-sm font-semibold text-gray-400 tracking-wider uppercase"
                                    ]
                                    [ text "Support" ]
                                , ul
                                    [ Attr.class "mt-4 space-y-4"
                                    ]
                                    [ li []
                                        [ a
                                            [ Attr.href "#"
                                            , Attr.class "text-base text-gray-500 hover:text-gray-900"
                                            ]
                                            [ text "Pricing" ]
                                         ]
                                    , li []
                                        [ a
                                            [ Attr.href "#"
                                            , Attr.class "text-base text-gray-500 hover:text-gray-900"
                                            ]
                                            [ text "Documentation" ]
                                         ]
                                    , li []
                                        [ a
                                            [ Attr.href "#"
                                            , Attr.class "text-base text-gray-500 hover:text-gray-900"
                                            ]
                                            [ text "Guides" ]
                                         ]
                                    , li []
                                        [ a
                                            [ Attr.href "#"
                                            , Attr.class "text-base text-gray-500 hover:text-gray-900"
                                            ]
                                            [ text "API Status" ]
                                         ]
                                     ]
                                 ]
                             ]
                        , div
                            [ Attr.class "md:grid md:grid-cols-2 md:gap-8"
                            ]
                            [ div []
                                [ h3
                                    [ Attr.class "text-sm font-semibold text-gray-400 tracking-wider uppercase"
                                    ]
                                    [ text "Company" ]
                                , ul
                                    [ Attr.class "mt-4 space-y-4"
                                    ]
                                    [ li []
                                        [ a
                                            [ Attr.href "#"
                                            , Attr.class "text-base text-gray-500 hover:text-gray-900"
                                            ]
                                            [ text "About" ]
                                         ]
                                    , li []
                                        [ a
                                            [ Attr.href "#"
                                            , Attr.class "text-base text-gray-500 hover:text-gray-900"
                                            ]
                                            [ text "Blog" ]
                                         ]
                                    , li []
                                        [ a
                                            [ Attr.href "#"
                                            , Attr.class "text-base text-gray-500 hover:text-gray-900"
                                            ]
                                            [ text "Jobs" ]
                                         ]
                                    , li []
                                        [ a
                                            [ Attr.href "#"
                                            , Attr.class "text-base text-gray-500 hover:text-gray-900"
                                            ]
                                            [ text "Press" ]
                                         ]
                                    , li []
                                        [ a
                                            [ Attr.href "#"
                                            , Attr.class "text-base text-gray-500 hover:text-gray-900"
                                            ]
                                            [ text "Partners" ]
                                         ]
                                     ]
                                 ]
                            , div
                                [ Attr.class "mt-12 md:mt-0"
                                ]
                                [ h3
                                    [ Attr.class "text-sm font-semibold text-gray-400 tracking-wider uppercase"
                                    ]
                                    [ text "Legal" ]
                                , ul
                                    [ Attr.class "mt-4 space-y-4"
                                    ]
                                    [ li []
                                        [ a
                                            [ Attr.href "#"
                                            , Attr.class "text-base text-gray-500 hover:text-gray-900"
                                            ]
                                            [ text "Claim" ]
                                         ]
                                    , li []
                                        [ a
                                            [ Attr.href "#"
                                            , Attr.class "text-base text-gray-500 hover:text-gray-900"
                                            ]
                                            [ text "Privacy" ]
                                         ]
                                    , li []
                                        [ a
                                            [ Attr.href "#"
                                            , Attr.class "text-base text-gray-500 hover:text-gray-900"
                                            ]
                                            [ text "Terms" ]
                                         ]
                                     ]
                                 ]
                             ]
                         ]
                    , div
                        [ Attr.class "mt-12 xl:mt-0"
                        ]
                        [ h3
                            [ Attr.class "text-sm font-semibold text-gray-400 tracking-wider uppercase"
                            ]
                            [ text "Subscribe to our newsletter" ]
                        , p
                            [ Attr.class "mt-4 text-base text-gray-500"
                            ]
                            [ text "The latest news, articles, and resources, sent to your inbox weekly." ]
                        , form
                            [ Attr.class "mt-4 sm:flex sm:max-w-md"
                            ]
                            [ label
                                [ Attr.for "email-address"
                                , Attr.class "sr-only"
                                ]
                                [ text "Email address" ]
                            , input
                                [ Attr.type_ "email"
                                , Attr.name "email-address"
                                , Attr.id "email-address"
                                , Attr.attribute "autocomplete" "email"
                                , Attr.required True
                                , Attr.class "appearance-none min-w-0 w-full bg-white border border-gray-300 rounded-md shadow-sm py-2 px-4 text-base text-gray-900 placeholder-gray-500 focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 focus:placeholder-gray-400"
                                , Attr.placeholder "Enter your email"
                                ]
                                []
                            , div
                                [ Attr.class "mt-3 rounded-md sm:mt-0 sm:ml-3 sm:flex-shrink-0"
                                ]
                                [ button
                                    [ Attr.type_ "submit"
                                    , Attr.class "w-full flex items-center justify-center bg-gradient-to-r from-purple-600 to-indigo-600 bg-origin-border px-4 py-3 border border-transparent text-base font-medium rounded-md shadow-sm text-white hover:from-purple-700 hover:to-indigo-700"
                                    ]
                                    [ text "Subscribe" ]
                                 ]
                             ]
                         ]
                     ]
                , div
                    [ Attr.class "mt-12 border-t border-gray-200 pt-8 md:flex md:items-center md:justify-between lg:mt-16"
                    ]
                    [ div
                        [ Attr.class "flex space-x-6 md:order-2"
                        ]
                        [ a
                            [ Attr.href "#"
                            , Attr.class "text-gray-400 hover:text-gray-500"
                            ]
                            [ span
                                [ Attr.class "sr-only"
                                ]
                                [ text "Facebook" ]
                            , svg
                                [ SvgAttr.class "h-6 w-6"
                                , SvgAttr.fill "currentColor"
                                , SvgAttr.viewBox "0 0 24 24"
                                , Attr.attribute "aria-hidden" "true"
                                ]
                                [ path
                                    [ SvgAttr.fillRule "evenodd"
                                    , SvgAttr.d "M22 12c0-5.523-4.477-10-10-10S2 6.477 2 12c0 4.991 3.657 9.128 8.438 9.878v-6.987h-2.54V12h2.54V9.797c0-2.506 1.492-3.89 3.777-3.89 1.094 0 2.238.195 2.238.195v2.46h-1.26c-1.243 0-1.63.771-1.63 1.562V12h2.773l-.443 2.89h-2.33v6.988C18.343 21.128 22 16.991 22 12z"
                                    , SvgAttr.clipRule "evenodd"
                                    ]
                                    []
                                 ]
                             ]
                        , a
                            [ Attr.href "#"
                            , Attr.class "text-gray-400 hover:text-gray-500"
                            ]
                            [ span
                                [ Attr.class "sr-only"
                                ]
                                [ text "Instagram" ]
                            , svg
                                [ SvgAttr.class "h-6 w-6"
                                , SvgAttr.fill "currentColor"
                                , SvgAttr.viewBox "0 0 24 24"
                                , Attr.attribute "aria-hidden" "true"
                                ]
                                [ path
                                    [ SvgAttr.fillRule "evenodd"
                                    , SvgAttr.d "M12.315 2c2.43 0 2.784.013 3.808.06 1.064.049 1.791.218 2.427.465a4.902 4.902 0 011.772 1.153 4.902 4.902 0 011.153 1.772c.247.636.416 1.363.465 2.427.048 1.067.06 1.407.06 4.123v.08c0 2.643-.012 2.987-.06 4.043-.049 1.064-.218 1.791-.465 2.427a4.902 4.902 0 01-1.153 1.772 4.902 4.902 0 01-1.772 1.153c-.636.247-1.363.416-2.427.465-1.067.048-1.407.06-4.123.06h-.08c-2.643 0-2.987-.012-4.043-.06-1.064-.049-1.791-.218-2.427-.465a4.902 4.902 0 01-1.772-1.153 4.902 4.902 0 01-1.153-1.772c-.247-.636-.416-1.363-.465-2.427-.047-1.024-.06-1.379-.06-3.808v-.63c0-2.43.013-2.784.06-3.808.049-1.064.218-1.791.465-2.427a4.902 4.902 0 011.153-1.772A4.902 4.902 0 015.45 2.525c.636-.247 1.363-.416 2.427-.465C8.901 2.013 9.256 2 11.685 2h.63zm-.081 1.802h-.468c-2.456 0-2.784.011-3.807.058-.975.045-1.504.207-1.857.344-.467.182-.8.398-1.15.748-.35.35-.566.683-.748 1.15-.137.353-.3.882-.344 1.857-.047 1.023-.058 1.351-.058 3.807v.468c0 2.456.011 2.784.058 3.807.045.975.207 1.504.344 1.857.182.466.399.8.748 1.15.35.35.683.566 1.15.748.353.137.882.3 1.857.344 1.054.048 1.37.058 4.041.058h.08c2.597 0 2.917-.01 3.96-.058.976-.045 1.505-.207 1.858-.344.466-.182.8-.398 1.15-.748.35-.35.566-.683.748-1.15.137-.353.3-.882.344-1.857.048-1.055.058-1.37.058-4.041v-.08c0-2.597-.01-2.917-.058-3.96-.045-.976-.207-1.505-.344-1.858a3.097 3.097 0 00-.748-1.15 3.098 3.098 0 00-1.15-.748c-.353-.137-.882-.3-1.857-.344-1.023-.047-1.351-.058-3.807-.058zM12 6.865a5.135 5.135 0 110 10.27 5.135 5.135 0 010-10.27zm0 1.802a3.333 3.333 0 100 6.666 3.333 3.333 0 000-6.666zm5.338-3.205a1.2 1.2 0 110 2.4 1.2 1.2 0 010-2.4z"
                                    , SvgAttr.clipRule "evenodd"
                                    ]
                                    []
                                 ]
                             ]
                        , a
                            [ Attr.href "#"
                            , Attr.class "text-gray-400 hover:text-gray-500"
                            ]
                            [ span
                                [ Attr.class "sr-only"
                                ]
                                [ text "Twitter" ]
                            , svg
                                [ SvgAttr.class "h-6 w-6"
                                , SvgAttr.fill "currentColor"
                                , SvgAttr.viewBox "0 0 24 24"
                                , Attr.attribute "aria-hidden" "true"
                                ]
                                [ path
                                    [ SvgAttr.d "M8.29 20.251c7.547 0 11.675-6.253 11.675-11.675 0-.178 0-.355-.012-.53A8.348 8.348 0 0022 5.92a8.19 8.19 0 01-2.357.646 4.118 4.118 0 001.804-2.27 8.224 8.224 0 01-2.605.996 4.107 4.107 0 00-6.993 3.743 11.65 11.65 0 01-8.457-4.287 4.106 4.106 0 001.27 5.477A4.072 4.072 0 012.8 9.713v.052a4.105 4.105 0 003.292 4.022 4.095 4.095 0 01-1.853.07 4.108 4.108 0 003.834 2.85A8.233 8.233 0 012 18.407a11.616 11.616 0 006.29 1.84"
                                    ]
                                    []
                                 ]
                             ]
                        , a
                            [ Attr.href "#"
                            , Attr.class "text-gray-400 hover:text-gray-500"
                            ]
                            [ span
                                [ Attr.class "sr-only"
                                ]
                                [ text "GitHub" ]
                            , svg
                                [ SvgAttr.class "h-6 w-6"
                                , SvgAttr.fill "currentColor"
                                , SvgAttr.viewBox "0 0 24 24"
                                , Attr.attribute "aria-hidden" "true"
                                ]
                                [ path
                                    [ SvgAttr.fillRule "evenodd"
                                    , SvgAttr.d "M12 2C6.477 2 2 6.484 2 12.017c0 4.425 2.865 8.18 6.839 9.504.5.092.682-.217.682-.483 0-.237-.008-.868-.013-1.703-2.782.605-3.369-1.343-3.369-1.343-.454-1.158-1.11-1.466-1.11-1.466-.908-.62.069-.608.069-.608 1.003.07 1.531 1.032 1.531 1.032.892 1.53 2.341 1.088 2.91.832.092-.647.35-1.088.636-1.338-2.22-.253-4.555-1.113-4.555-4.951 0-1.093.39-1.988 1.029-2.688-.103-.253-.446-1.272.098-2.65 0 0 .84-.27 2.75 1.026A9.564 9.564 0 0112 6.844c.85.004 1.705.115 2.504.337 1.909-1.296 2.747-1.027 2.747-1.027.546 1.379.202 2.398.1 2.651.64.7 1.028 1.595 1.028 2.688 0 3.848-2.339 4.695-4.566 4.943.359.309.678.92.678 1.855 0 1.338-.012 2.419-.012 2.747 0 .268.18.58.688.482A10.019 10.019 0 0022 12.017C22 6.484 17.522 2 12 2z"
                                    , SvgAttr.clipRule "evenodd"
                                    ]
                                    []
                                 ]
                             ]
                        , a
                            [ Attr.href "#"
                            , Attr.class "text-gray-400 hover:text-gray-500"
                            ]
                            [ span
                                [ Attr.class "sr-only"
                                ]
                                [ text "Dribbble" ]
                            , svg
                                [ SvgAttr.class "h-6 w-6"
                                , SvgAttr.fill "currentColor"
                                , SvgAttr.viewBox "0 0 24 24"
                                , Attr.attribute "aria-hidden" "true"
                                ]
                                [ path
                                    [ SvgAttr.fillRule "evenodd"
                                    , SvgAttr.d "M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10c5.51 0 10-4.48 10-10S17.51 2 12 2zm6.605 4.61a8.502 8.502 0 011.93 5.314c-.281-.054-3.101-.629-5.943-.271-.065-.141-.12-.293-.184-.445a25.416 25.416 0 00-.564-1.236c3.145-1.28 4.577-3.124 4.761-3.362zM12 3.475c2.17 0 4.154.813 5.662 2.148-.152.216-1.443 1.941-4.48 3.08-1.399-2.57-2.95-4.675-3.189-5A8.687 8.687 0 0112 3.475zm-3.633.803a53.896 53.896 0 013.167 4.935c-3.992 1.063-7.517 1.04-7.896 1.04a8.581 8.581 0 014.729-5.975zM3.453 12.01v-.26c.37.01 4.512.065 8.775-1.215.25.477.477.965.694 1.453-.109.033-.228.065-.336.098-4.404 1.42-6.747 5.303-6.942 5.629a8.522 8.522 0 01-2.19-5.705zM12 20.547a8.482 8.482 0 01-5.239-1.8c.152-.315 1.888-3.656 6.703-5.337.022-.01.033-.01.054-.022a35.318 35.318 0 011.823 6.475 8.4 8.4 0 01-3.341.684zm4.761-1.465c-.086-.52-.542-3.015-1.659-6.084 2.679-.423 5.022.271 5.314.369a8.468 8.468 0 01-3.655 5.715z"
                                    , SvgAttr.clipRule "evenodd"
                                    ]
                                    []
                                 ]
                             ]
                         ]
                    , p
                        [ Attr.class "mt-8 text-base text-gray-400 md:mt-0 md:order-1"
                        ]
                        [ text "© 2020 Workflow, Inc. All rights reserved." ]
                     ]
                 ]
             ]
         ]
    