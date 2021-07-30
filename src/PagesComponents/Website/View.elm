module PagesComponents.Website.View exposing (..)

import FontAwesome.Styles as Icon
import Html exposing (Html, a, blockquote, button, div, footer, form, h1, h2, h3, header, img, input, label, li, main_, nav, p, span, text, ul)
import Html.Attributes as Attr

import PagesComponents.Website.Views.CtaSection exposing (viewCtaSection)
import PagesComponents.Website.Views.FeaturesListGridSection exposing (viewFeaturesListGridSection)
import PagesComponents.Website.Views.FeaturesSection exposing (viewFeaturesSection)
import PagesComponents.Website.Views.FooterSection exposing (viewFooterSection)
import PagesComponents.Website.Views.HeaderSection exposing (viewHeaderSection)
import PagesComponents.Website.Views.HeroSection exposing (viewHeroSection)



viewWebsite : List (Html msg)
viewWebsite =
    [ Icon.css ]
        ++ [ div
                [ Attr.class "bg-white"]
                [ viewHeaderSection, viewHeroSection, viewFeaturesSection, viewFeaturesListGridSection, viewCtaSection, viewFooterSection ]
           ]
