module Libs.Html.Attributes exposing (role)

import Html exposing (Attribute)
import Html.Attributes exposing (attribute)


role : String -> Attribute msg
role text =
    attribute "role" text
