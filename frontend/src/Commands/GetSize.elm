module Commands.GetSize exposing (getTableSize, getWindowSize)

import Browser.Dom as Dom
import Models exposing (Msg(..), WindowSize)
import Models.Schema exposing (TableId)
import Models.Utils exposing (Size)
import Task exposing (Task)
import Views.Helpers exposing (formatTableId)



-- get sizes for elements that need it, not more


getWindowSize : Cmd Msg
getWindowSize =
    Task.attempt GotWindowSize windowSize


getTableSize : TableId -> Cmd Msg
getTableSize id =
    Task.attempt GotTableSize (Task.map (\size -> ( id, size )) (elementSize (formatTableId id)))



-- GET SIZES


elementSize : String -> Task Dom.Error Size
elementSize id =
    Task.map (\e -> Size e.element.width e.element.height) (Dom.getElement id)


windowSize : Task x WindowSize
windowSize =
    Task.map (\viewport -> Size viewport.viewport.width viewport.viewport.height) Dom.getViewport
