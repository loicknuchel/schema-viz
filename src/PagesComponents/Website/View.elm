module PagesComponents.Website.View exposing (viewWebsite)

import Html exposing (Html, div)
import Html.Attributes as Attr
import PagesComponents.Website.Views.CtaSection exposing (viewCtaSection)
import PagesComponents.Website.Views.FeaturesListGridSection exposing (viewFeaturesListGridSection)
import PagesComponents.Website.Views.FeaturesSection exposing (viewFeaturesSection)
import PagesComponents.Website.Views.FooterSection exposing (viewFooterSection)
import PagesComponents.Website.Views.HeaderSection exposing (viewHeaderSection)
import PagesComponents.Website.Views.HeroSection exposing (viewHeroSection)


viewWebsite : List (Html msg)
viewWebsite =
    []
        ++ [ div
                [ Attr.class "bg-white" ]
                [ viewHeaderSection, viewHeroSection, viewFeaturesSection, viewFeaturesListGridSection, viewCtaSection, viewFooterSection ]
           ]
