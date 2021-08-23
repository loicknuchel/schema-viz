module Components.Book exposing (main)

import Components.Atoms.Button exposing (buttonChapter)
import Components.Atoms.Link exposing (linkButtonChapter)
import Components.Atoms.SvgIcon exposing (iconChapter)
import Components.Organisms.Footer exposing (footerChapter)
import Components.Organisms.Header exposing (headerChapter)
import Components.Slices.Cta exposing (ctaChapter)
import Components.Slices.Feature exposing (featureChapter)
import Components.Slices.Hero exposing (heroChapter)
import Css.Global exposing (global)
import ElmBook exposing (withChapterGroups, withComponentOptions, withThemeOptions)
import ElmBook.Chapter exposing (chapter, render)
import ElmBook.ComponentOptions
import ElmBook.ElmCSS exposing (Book, Chapter, book)
import ElmBook.ThemeOptions
import Html.Styled exposing (Html, img)
import Html.Styled.Attributes as Attr exposing (css)
import Tailwind.Breakpoints as Bp
import Tailwind.Utilities as Tw exposing (globalStyles)


main : Book x
main =
    book "Azimutt UI"
        |> withThemeOptions
            [ ElmBook.ThemeOptions.subtitle "v0.1.0"
            , ElmBook.ThemeOptions.globals [ global globalStyles ]
            , ElmBook.ThemeOptions.logo logo
            ]
        |> withComponentOptions
            [ ElmBook.ComponentOptions.fullWidth True
            ]
        |> withChapterGroups
            [ ( ""
              , [ docs ]
              )
            , ( "Atoms"
              , [ linkButtonChapter
                , buttonChapter
                , iconChapter
                ]
              )
            , ( "Molecules"
              , []
              )
            , ( "Organisms"
              , [ headerChapter
                , footerChapter
                ]
              )
            , ( "Slices"
              , [ heroChapter
                , featureChapter
                , ctaChapter
                ]
              )
            ]


logo : Html msg
logo =
    img
        [ css
            [ Tw.h_8
            , Tw.w_auto
            , Bp.sm
                [ Tw.h_6
                ]
            ]
        , Attr.src "/logo.svg"
        , Attr.alt "Azimutt elm-book"
        ]
        []


docs : Chapter x
docs =
    chapter "Readme"
        |> render """

work in progress
---
"""
