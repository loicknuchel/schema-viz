module PagesComponents.Home_.View exposing (viewHome)

import Components.Slices.Cta exposing (ctaSlice)
import Components.Slices.Feature exposing (featureListeSlice, featureSlice)
import Components.Slices.Hero exposing (heroSlice)
import Html exposing (Html, div)
import Html.Attributes exposing (class)
import Html.Styled as Styled
import PagesComponents.Home_.Views.FooterSection exposing (viewFooterSection)


viewHome : List (Html msg)
viewHome =
    [ div [ class "bg-white" ]
        [ heroSlice |> Styled.toUnstyled
        , featureSlice |> Styled.toUnstyled
        , featureListeSlice |> Styled.toUnstyled
        , ctaSlice |> Styled.toUnstyled
        , viewFooterSection
        ]
    ]
