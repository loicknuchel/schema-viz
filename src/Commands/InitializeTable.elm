module Commands.InitializeTable exposing (initializeTable)

import Models exposing (Msg(..))
import Models.Schema exposing (TableId)
import Models.Utils exposing (Area, Position, Size)
import Random



-- deps = { to = { only = [ "Libs.*", "Conf.*", "Models.*", "Ports.*" ] } }
-- initialize table using random data


initializeTable : Size -> Area -> TableId -> Cmd Msg
initializeTable size area id =
    positionGen size area |> Random.generate (InitializedTable id size)



-- RANDOM GENERATORS


positionGen : Size -> Area -> Random.Generator Position
positionGen size area =
    Random.map2 (\left top -> Position left top) (Random.float area.left (area.right - size.width)) (Random.float area.top (area.bottom - size.height))
