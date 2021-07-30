module PagesComponents.Website.Views.FeaturesListGridSection exposing (viewFeaturesListGridSection)

import Html exposing (Html, a, button, div, header, img, nav, p, span, text, input, label, form, h3, li, ul, h2, footer, blockquote, h1, main_)
import Html.Attributes as Attr
import Svg exposing (svg, path)
import Svg.Attributes as SvgAttr

viewFeaturesListGridSection : Html msg
viewFeaturesListGridSection =
   main_ []
            [ {- Hero section -}
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
            , {- Logo Cloud -}
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
            , {- Alternating Feature Sections -}
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
                                        [ {- Heroicon name: outline/inbox -}
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
                                        [ {- Heroicon name: outline/sparkles -}
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
            , {- Gradient Feature Section -}
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
                                    [ {- Heroicon name: outline/inbox -}
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
                                    [ {- Heroicon name: outline/users -}
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
                                    [ {- Heroicon name: outline/trash -}
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
                                    [ {- Heroicon name: outline/pencil-alt -}
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
                                    [ {- Heroicon name: outline/document-report -}
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
                                    [ {- Heroicon name: outline/reply -}
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
                                    [ {- Heroicon name: outline/chat-alt -}
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
                                    [ {- Heroicon name: outline/heart -}
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
            , div
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
                                    , text "use laoreet amet lacus nibh integer quis."
                                    ]
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
                                    , text "lacus nibh integer quis."
                                    ]
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
                                    , text "laoreet amet lacus nibh integer quis."
                                    ]
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
                                    , text "lacus nibh integer quis."
                                    ]
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
        