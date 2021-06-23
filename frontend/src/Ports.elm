port module Ports exposing (observeTableSize, sizesReceiver)

import Models exposing (SizeChange)
import Models.Schema exposing (TableId, formatTableId)


port observeSizes : List String -> Cmd msg


port sizesReceiver : (List SizeChange -> msg) -> Sub msg


observeTableSize : TableId -> Cmd msg
observeTableSize id =
    observeSizes [ formatTableId id ]
