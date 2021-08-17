module Components.Reset exposing (..)
import Css.Global
import Html.Styled exposing (div)
import Tailwind.Utilities as Tw

resetCSS chapter =
    div []
        [ -- This will give us the standard tailwind style-reset as well as the fonts
          Css.Global.global Tw.globalStyles
        , chapter
        ]
