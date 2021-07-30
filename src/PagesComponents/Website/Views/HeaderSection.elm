module PagesComponents.Website.Views.HeaderSection exposing (viewHeaderSection)

import Html exposing (Html, a, blockquote, button, div, footer, form, h1, h2, h3, header, img, input, label, li, main_, nav, p, span, text, ul)
import Html.Attributes as Attr
import Svg exposing (path, svg)
import Svg.Attributes as SvgAttr


viewHeaderSection : Html msg
viewHeaderSection =
    header []
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
                        , {- Heroicon name: outline/menu -}
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
                                            [ {- Heroicon name: outline/annotation -}
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
                                            [ {- Heroicon name: outline/chat-alt-2 -}
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
                                            [ {- Heroicon name: outline/question-mark-circle -}
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
            , {-
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
                                    , {- Heroicon name: outline/x -}
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
                                        [ {- Heroicon name: outline/inbox -}
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
                                        [ {- Heroicon name: outline/annotation -}
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
                                        [ {- Heroicon name: outline/chat-alt-2 -}
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
                                        [ {- Heroicon name: outline/question-mark-circle -}
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
                                [ text "Existing customer?"
                                , a
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
