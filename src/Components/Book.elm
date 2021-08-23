module Components.Book exposing (main)

import Components.Atoms.Button exposing (buttonChapter)
import Components.Atoms.Link exposing (linkButtonChapter)
import Components.Organisms.Header exposing (headerChapter)
import Components.Slices.Feature exposing (featureChapter)
import Components.Slices.Hero exposing (heroChapter)
import Css
import Css.Global exposing (global)
import ElmBook exposing (withChapterGroups, withComponentOptions, withThemeOptions)
import ElmBook.ComponentOptions
import ElmBook.ElmCSS exposing (Book, book)
import ElmBook.ThemeOptions
import Html.Attributes exposing (..)
import Html.Styled as Html exposing (..)
import Html.Styled.Attributes as Attr exposing (css, href, src)
import Tailwind.Breakpoints as Bp
import Tailwind.Utilities as Tw exposing (globalStyles)


main : Book x
main =
    book "Azimutt UI"
        |> withThemeOptions
            [ ElmBook.ThemeOptions.subtitle "v1.0.1"
            , ElmBook.ThemeOptions.globals [ global globalStyles ]
            , ElmBook.ThemeOptions.logo logo
            ]
        |> withComponentOptions
            [ ElmBook.ComponentOptions.fullWidth True
            ]
        |> withChapterGroups
            [ ( "Atoms"
              , [ linkButtonChapter
                , buttonChapter
                ]
              )
            , ( "Molecules"
              , []
              )
            , ( "Organisms"
              , [ headerChapter
                ]
              )
            , ( "Slices"
              , [ heroChapter
                , featureChapter
                ]
              )
            ]


logo =
    img
        [ css
            [ Tw.h_8
            , Tw.w_auto
            , Bp.sm
                [ Tw.h_6
                ]
            ]
        , Attr.src "http://localhost:4000/assets/azimutt_logo.svg"
        , Attr.alt "Azimutt elm-book"
        ]
        []
