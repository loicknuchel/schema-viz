module Libs.Task exposing (send)

import Task


send : msg -> Cmd msg
send msg =
    Task.succeed msg |> Task.perform identity


andThen : msg -> msg -> Cmd msg
andThen msg2 msg1 =
    Task.succeed msg1 |> Task.andThen (\_ -> Task.succeed msg2) |> Task.perform identity
