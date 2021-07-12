module Libs.Result exposing (fold)

-- deps = { to = { only = [ "Libs.*" ] } }


fold : (x -> b) -> (a -> b) -> Result x a -> b
fold onError onSuccess result =
    case result of
        Ok a ->
            onSuccess a

        Err x ->
            onError x


bimap : (x -> y) -> (a -> b) -> Result x a -> Result y b
bimap onError onSuccess result =
    case result of
        Ok a ->
            Ok (onSuccess a)

        Err x ->
            Err (onError x)
