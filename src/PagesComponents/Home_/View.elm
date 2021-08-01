module PagesComponents.Home_.View exposing (viewWebsite)

import Html exposing (Html, div)
import Html.Attributes as Attr
import PagesComponents.Home_.Views.CtaSection exposing (viewCtaSection)
import PagesComponents.Home_.Views.FeaturesListGridSection exposing (viewFeaturesListGridSection)
import PagesComponents.Home_.Views.FeaturesSection exposing (viewFeaturesSection)
import PagesComponents.Home_.Views.FooterSection exposing (viewFooterSection)
import PagesComponents.Home_.Views.HeaderSection exposing (viewHeaderSection)
import PagesComponents.Home_.Views.HeroSection exposing (viewHeroSection)


viewWebsite : List (Html msg)
viewWebsite =
    []
        ++ [ div
                [ Attr.class "bg-white" ]
                [ viewHeaderSection, viewHeroSection, viewFeaturesSection, viewFeaturesListGridSection, viewCtaSection, viewFooterSection ]
           ]
