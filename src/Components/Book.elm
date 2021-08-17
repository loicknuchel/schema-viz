module Components.Book exposing (main)

import Components.Atoms.Button exposing (buttonChapter)
import Components.Atoms.Link exposing (firstChapter)


import ElmBook exposing (withChapters)
import ElmBook.ElmCSS exposing (Book, Chapter, book)


main : Book ()
main =
    book "ElmBook with Elm-CSS"
        |> withChapters
            [ firstChapter
            ]

