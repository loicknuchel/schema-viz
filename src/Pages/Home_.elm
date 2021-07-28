module Pages.Home_ exposing (view)

import Gen.Route as Route
import Html
import Html.Attributes as Attr
import View exposing (View)


view : View msg
view =
    { title = "Homepage"
    , body =
        [ Html.text "Hello, world!"
        , Html.br [] []
        , Html.a [ Attr.href (Route.toHref Route.App) ] [ Html.text "discover app" ]
        ]
    }
