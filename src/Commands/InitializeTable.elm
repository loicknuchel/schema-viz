module Commands.InitializeTable exposing (initializeTable)

import Libs.Area exposing (Area)
import Libs.Position exposing (Position)
import Libs.Size exposing (Size)
import Models exposing (Msg(..))
import Models.Schema exposing (TableId)
import Random



-- deps = { to = { only = [ "Libs.*", "Conf.*", "Models.*", "Ports.*" ] } }
-- initialize table using random data


initializeTable : Size -> Area -> TableId -> Cmd Msg
initializeTable size area id =
    positionGen size area |> Random.generate (InitializedTable id)



-- RANDOM GENERATORS


positionGen : Size -> Area -> Random.Generator Position
positionGen size area =
    Random.map2 Position
        (Random.float area.left (max area.left (area.right - size.width)))
        (Random.float area.top (max area.top (area.bottom - size.height)))
