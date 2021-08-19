module Models.FindPath exposing (Model, Path, Result, Step, StepDir(..))

import Libs.Nel exposing (Nel)
import Models.Project exposing (Relation, TableId)


type alias Model =
    { from : Maybe TableId
    , to : Maybe TableId
    , paths : Maybe (List Path)
    }


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
