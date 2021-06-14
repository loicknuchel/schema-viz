module Commands.GetSizes exposing (getSizes)

import Browser.Dom as Dom
import Decoders.SchemaDecoder exposing (JsonTable)
import Models exposing (Msg(..), WindowSize)
import Models.Schema exposing (TableId)
import Models.Utils exposing (Size)
import Task exposing (Task)
import Views.Helpers exposing (formatTableId)



-- get sizes for elements that need it, not more


getSizes : List ( JsonTable, TableId ) -> Cmd Msg
getSizes tables =
    Task.attempt GotSizes (allSizes tables)



-- GET SIZES


allSizes : List ( JsonTable, TableId ) -> Task Dom.Error ( List ( JsonTable, TableId, Size ), WindowSize )
allSizes tables =
    Task.map2 (\sizedSchema size -> ( sizedSchema, size )) (tablesSize tables) windowSize


tablesSize : List ( JsonTable, TableId ) -> Task Dom.Error (List ( JsonTable, TableId, Size ))
tablesSize tables =
    Task.sequence (List.map (\table -> tableSize table) tables)


tableSize : ( JsonTable, TableId ) -> Task Dom.Error ( JsonTable, TableId, Size )
tableSize ( table, id ) =
    Task.map (\e -> ( table, id, Size e.element.width e.element.height )) (Dom.getElement (formatTableId id))


windowSize : Task x WindowSize
windowSize =
    Task.map (\viewport -> Size viewport.viewport.width viewport.viewport.height) Dom.getViewport
