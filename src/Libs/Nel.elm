module Libs.Nel exposing (Nel)


type alias Nel a =
    { head : a, tail : List a }
