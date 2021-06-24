module Commands.GetSize exposing (getWindowSize)

import Browser.Dom as Dom
import Models exposing (Msg(..), WindowSize, ZoomLevel)
import Models.Utils exposing (Size)
import Task exposing (Task)



-- get sizes for elements that need it, not more


getWindowSize : Cmd Msg
getWindowSize =
    Task.attempt GotWindowSize windowSize



-- GET SIZES


elementSize : ZoomLevel -> String -> Task Dom.Error Size
elementSize zoom id =
    Task.map (\e -> Size (e.element.width / zoom) (e.element.height / zoom)) (Dom.getElement id)


windowSize : Task x WindowSize
windowSize =
    Task.map (\viewport -> Size viewport.viewport.width viewport.viewport.height) Dom.getViewport
