module Drawing2d.GradientContext
    exposing
        ( GradientContext
        , apply
        , linear
        , none
        , relativeTo
        , scaleAbout
        )

import Drawing2d.Defs as Defs exposing (Defs)
import Drawing2d.LinearGradient as LinearGradient exposing (LinearGradient)
import Frame2d exposing (Frame2d)
import Point2d exposing (Point2d)
import Svg
import Svg.Attributes


type GradientContext
    = NoContext
    | LinearContext LinearGradient


none : GradientContext
none =
    NoContext


linear : LinearGradient -> GradientContext
linear =
    LinearContext


relativeTo : Frame2d -> GradientContext -> GradientContext
relativeTo frame gradientContext =
    case gradientContext of
        NoContext ->
            NoContext

        LinearContext linearGradient ->
            LinearContext (LinearGradient.relativeTo frame linearGradient)


scaleAbout : Point2d -> Float -> GradientContext -> GradientContext
scaleAbout point scale gradientContext =
    case gradientContext of
        NoContext ->
            NoContext

        LinearContext linearGradient ->
            LinearContext (LinearGradient.scaleAbout point scale linearGradient)


apply : GradientContext -> Defs -> List (Svg.Attribute msg) -> ( Defs, List (Svg.Attribute msg) )
apply gradientContext defs currentAttributes =
    case gradientContext of
        NoContext ->
            ( defs, currentAttributes )

        LinearContext linearGradient ->
            let
                ( id, updatedDefs ) =
                    Defs.addLinearGradient linearGradient defs

                fillAttribute =
                    Svg.Attributes.fill ("url(#" ++ id ++ ")")
            in
            ( updatedDefs, fillAttribute :: currentAttributes )
