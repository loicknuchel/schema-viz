module Commands.InitializeTable exposing (initializeTable)

import Libs.Std exposing (genChoose)
import Models exposing (Msg(..), WindowSize, conf)
import Models.Schema exposing (TableId)
import Models.Utils exposing (Color, Position, Size)
import Random



-- initialize table using random data


initializeTable : TableId -> Size -> WindowSize -> Cmd Msg
initializeTable id size windowSize =
    Random.generate (\( pos, color ) -> InitializedTable id size pos color) (positionAndColorGen size windowSize)



-- RANDOM GENERATORS


positionAndColorGen : Size -> WindowSize -> Random.Generator ( Position, Color )
positionAndColorGen size windowSize =
    Random.map2 (\p c -> ( p, c )) (positionGen size windowSize) colorGen


positionGen : Size -> WindowSize -> Random.Generator Position
positionGen table windowSize =
    Random.map2 (\w h -> Position w h) (Random.float 0 (windowSize.width - table.width)) (Random.float 0 (windowSize.height - table.height))


colorGen : Random.Generator Color
colorGen =
    case conf.colors of
        { pink, purple, darkBlue, blue, turquoise, lightBlue, lightGreen, green, yellow, orange, red, grey } ->
            genChoose ( pink, [ purple, darkBlue, blue, turquoise, lightBlue, lightGreen, green, yellow, orange, red, grey ] )
