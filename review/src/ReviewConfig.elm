module ReviewConfig exposing (config)

{-| Do not rename the ReviewConfig module or the config function, because
`elm-review` will look for these.

To add packages that contain rules, add them to this review project using

    `elm install author/packagename`

when inside the directory containing this file.

-}

import NoDebug.Log
import NoDebug.TodoOrToString
import NoExposingEverything
import NoMissingSubscriptionsCall
import NoMissingTypeAnnotation
import NoMissingTypeAnnotationInLetIn
import NoMissingTypeExpose
import NoRecursiveUpdate
import NoUnused.CustomTypeConstructors
import NoUnused.Dependencies
import NoUnused.Exports
import NoUnused.Modules
import NoUnused.Parameters
import NoUnused.Patterns
import NoUnused.Variables
import NoUselessSubscriptions
import Review.Rule as Rule exposing (Rule)


config : List Rule
config =
    [ NoDebug.Log.rule
    , NoDebug.TodoOrToString.rule
    , NoExposingEverything.rule |> Rule.ignoreErrorsForDirectories [ "tests" ]
    , NoMissingSubscriptionsCall.rule
    , NoRecursiveUpdate.rule
    , NoUselessSubscriptions.rule
    , NoMissingTypeAnnotation.rule
    , NoMissingTypeAnnotationInLetIn.rule
    , NoMissingTypeExpose.rule
    , NoUnused.CustomTypeConstructors.rule [] |> Rule.ignoreErrorsForDirectories [ "src/Libs" ]
    , NoUnused.Dependencies.rule
    , NoUnused.Exports.rule |> Rule.ignoreErrorsForDirectories [ "src/Libs" ]
    , NoUnused.Modules.rule |> Rule.ignoreErrorsForDirectories [ "src/Libs" ]
    , NoUnused.Parameters.rule
    , NoUnused.Patterns.rule
    , NoUnused.Variables.rule |> Rule.ignoreErrorsForDirectories [ "src/Libs" ]
    ]
