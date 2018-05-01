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
import Frame2d exposing (Frame2d)
import Point2d exposing (Point2d)
import Svg
import Svg.Attributes


type GradientContext
    = NoContext
    | LinearContext String Point2d Point2d


none : GradientContext
none =
    NoContext


linear : String -> Point2d -> Point2d -> GradientContext
linear id startPoint endPoint =
    LinearContext id startPoint endPoint


relativeTo : Frame2d -> GradientContext -> GradientContext
relativeTo frame gradientContext =
    case gradientContext of
        NoContext ->
            NoContext

        LinearContext id startPoint endPoint ->
            LinearContext id
                (Point2d.relativeTo frame startPoint)
                (Point2d.relativeTo frame endPoint)


scaleAbout : Point2d -> Float -> GradientContext -> GradientContext
scaleAbout point scale gradientContext =
    case gradientContext of
        NoContext ->
            NoContext

        LinearContext id startPoint endPoint ->
            LinearContext id
                (Point2d.scaleAbout point scale startPoint)
                (Point2d.scaleAbout point scale endPoint)


apply : GradientContext -> Defs -> List (Svg.Attribute msg) -> ( Defs, List (Svg.Attribute msg) )
apply gradientContext defs currentAttributes =
    case gradientContext of
        NoContext ->
            ( defs, currentAttributes )

        LinearContext referencedId localStartPoint localEndPoint ->
            let
                ( id, updatedDefs ) =
                    defs
                        |> Defs.instantiateLinearGradient referencedId
                            localStartPoint
                            localEndPoint

                fillAttribute =
                    Svg.Attributes.fill ("url(#" ++ id ++ ")")
            in
            ( updatedDefs, fillAttribute :: currentAttributes )
