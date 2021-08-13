module Components.Book exposing (main)

import Components.Atoms.Button exposing (buttonChapter)
import ElmBook exposing (..)


main : Book ()
main =
    book "Schemavizz Components"
        |> withChapterGroups
            [ ( "Components"
              , [ buttonChapter
                ]
              )
            ]
