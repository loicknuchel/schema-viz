module Libs.Html.Attributes exposing (role)

import Html exposing (Attribute)
import Html.Attributes exposing (attribute)



-- deps = { to = { only = [ "Libs.*" ] } }


role : String -> Attribute msg
role text =
    attribute "role" text
