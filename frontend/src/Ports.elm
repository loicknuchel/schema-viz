port module Ports exposing (observeSize, observeTableSize, observeTablesSize, sizesReceiver)

import Models exposing (SizeChange)
import Models.Schema exposing (TableId, formatTableId)


port observeSizes : List String -> Cmd msg


port sizesReceiver : (List SizeChange -> msg) -> Sub msg


observeSize : String -> Cmd msg
observeSize id =
    observeSizes [ id ]


observeTableSize : TableId -> Cmd msg
observeTableSize id =
    observeSizes [ formatTableId id ]


observeTablesSize : List TableId -> Cmd msg
observeTablesSize ids =
    observeSizes (List.map formatTableId ids)
