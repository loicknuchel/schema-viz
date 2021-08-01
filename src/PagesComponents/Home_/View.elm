module PagesComponents.Home_.View exposing (viewHome)

import Html exposing (Html, div)
import Html.Attributes exposing (class)
import PagesComponents.Home_.Views.CtaSection exposing (viewCtaSection)
import PagesComponents.Home_.Views.FeaturesListGridSection exposing (viewFeaturesListGridSection)
import PagesComponents.Home_.Views.FeaturesSection exposing (viewFeaturesSection)
import PagesComponents.Home_.Views.FooterSection exposing (viewFooterSection)
import PagesComponents.Home_.Views.HeaderSection exposing (viewHeaderSection)
import PagesComponents.Home_.Views.HeroSection exposing (viewHeroSection)


viewHome : List (Html msg)
viewHome =
    [ div [ class "bg-white" ]
        [ viewHeaderSection
        , viewHeroSection
        , viewFeaturesSection
        , viewFeaturesListGridSection
        , viewCtaSection
        , viewFooterSection
        ]
    ]
