module Models.FindPath exposing (Model, Path, PathState(..), Result, Step, StepDir(..))

import Libs.Nel exposing (Nel)
import Models.Project exposing (Relation, TableId)


type alias Model =
    { from : Maybe TableId
    , to : Maybe TableId
    , result : PathState
    }


type PathState
    = Empty
    | Searching
    | Found Result


type alias Result =
    { from : TableId
    , to : TableId
    , paths : List Path
    }


type alias Path =
    Nel Step


type alias Step =
    { relation : Relation, direction : StepDir }


type StepDir
    = Right
    | Left
