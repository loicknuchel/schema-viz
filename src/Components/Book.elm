module Components.Book exposing (main)

import Components.Atoms.Button exposing (buttonChapter)
import Components.Atoms.Link exposing (linkButtonChapter)
import Components.Organisms.Header exposing (headerChapter)
import Components.Slices.Feature exposing (featureChapter)
import Components.Slices.Hero exposing (heroChapter)
import Css.Global exposing (global)
import ElmBook exposing (withChapterGroups, withThemeOptions)
import ElmBook.ElmCSS exposing (Book, book)
import ElmBook.ThemeOptions
import Tailwind.Utilities exposing (globalStyles)


main : Book x
main =
    book "Azimutt book"
        |> withThemeOptions
            [ ElmBook.ThemeOptions.subtitle "v1.0.1"
            , ElmBook.ThemeOptions.globals [ global globalStyles ]
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
