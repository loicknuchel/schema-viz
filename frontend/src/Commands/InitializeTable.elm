module Commands.InitializeTable exposing (initializeTable)

import Conf exposing (conf)
import Libs.Std exposing (genChoose)
import Models exposing (Msg(..))
import Models.Schema exposing (TableId)
import Models.Utils exposing (Area, Color, Position, Size)
import Random



-- initialize table using random data


initializeTable : Size -> Area -> TableId -> Cmd Msg
initializeTable size area id =
    Random.generate (\( pos, color ) -> InitializedTable id size pos color) (positionAndColorGen size area)



-- RANDOM GENERATORS


positionAndColorGen : Size -> Area -> Random.Generator ( Position, Color )
positionAndColorGen size area =
    Random.map2 (\position color -> ( position, color )) (positionGen size area) colorGen


positionGen : Size -> Area -> Random.Generator Position
positionGen size area =
    Random.map2 (\left top -> Position left top) (Random.float area.left (area.right - size.width)) (Random.float area.top (area.bottom - size.height))


colorGen : Random.Generator Color
colorGen =
    case conf.colors of
        { pink, purple, darkBlue, blue, turquoise, lightBlue, lightGreen, green, yellow, orange, red, grey } ->
            genChoose ( pink, [ purple, darkBlue, blue, turquoise, lightBlue, lightGreen, green, yellow, orange, red, grey ] )
