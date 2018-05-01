module Drawing2d.Element exposing (Element(..), map, render)

import Arc2d exposing (Arc2d)
import Axis2d exposing (Axis2d)
import Circle2d exposing (Circle2d)
import CubicSpline2d exposing (CubicSpline2d)
import Direction2d exposing (Direction2d)
import Drawing2d.Attribute as Attribute exposing (Attribute)
import Drawing2d.BorderPosition as BorderPosition
import Drawing2d.Context as Context exposing (Context)
import Drawing2d.Defs exposing (Defs)
import Drawing2d.GradientContext as GradientContext
import Ellipse2d exposing (Ellipse2d)
import EllipticalArc2d exposing (EllipticalArc2d)
import Frame2d exposing (Frame2d)
import Geometry.Svg as Svg
import LineSegment2d exposing (LineSegment2d)
import Point2d exposing (Point2d)
import Polygon2d exposing (Polygon2d)
import Polyline2d exposing (Polyline2d)
import QuadraticSpline2d exposing (QuadraticSpline2d)
import Rectangle2d exposing (Rectangle2d)
import Svg exposing (Svg)
import Svg.Attributes
import Triangle2d exposing (Triangle2d)
import VirtualDom


type Element msg
    = Empty
    | Group (List (Attribute msg)) (List (Element msg))
    | PlaceIn Frame2d (Element msg)
    | ScaleAbout Point2d Float (Element msg)
    | LineSegment (List (Attribute msg)) LineSegment2d
    | Triangle (List (Attribute msg)) Triangle2d
    | Dot (List (Attribute msg)) Point2d
    | Arc (List (Attribute msg)) Arc2d
    | CubicSpline (List (Attribute msg)) CubicSpline2d
    | QuadraticSpline (List (Attribute msg)) QuadraticSpline2d
    | Polyline (List (Attribute msg)) Polyline2d
    | Polygon (List (Attribute msg)) Polygon2d
    | Circle (List (Attribute msg)) Circle2d
    | Ellipse (List (Attribute msg)) Ellipse2d
    | EllipticalArc (List (Attribute msg)) EllipticalArc2d
    | Text (List (Attribute msg)) Point2d String
    | RoundedRectangle (List (Attribute msg)) Float Rectangle2d
    | Image String Rectangle2d


applyAttribute : Attribute msg -> ( Context, Defs, List (List (Svg.Attribute msg)) ) -> ( Context, Defs, List (List (Svg.Attribute msg)) )
applyAttribute attribute ( context, defs, accumulatedAttributes ) =
    let
        ( updatedContext, updatedDefs, svgAttributes ) =
            Attribute.apply attribute context defs
    in
    ( updatedContext, updatedDefs, svgAttributes :: accumulatedAttributes )


nonScalingStrokeAttribute : Svg.Attribute msg
nonScalingStrokeAttribute =
    VirtualDom.attribute "vector-effect" "non-scaling-stroke"


noFillAttribute : Svg.Attribute msg
noFillAttribute =
    Svg.Attributes.fill "none"


noStrokeAttribute : Svg.Attribute msg
noStrokeAttribute =
    Svg.Attributes.stroke "none"


curveAttributes : List (Svg.Attribute msg) -> List (Svg.Attribute msg)
curveAttributes attributes =
    noFillAttribute :: nonScalingStrokeAttribute :: attributes


drawCurveWith : Context -> Defs -> List (Attribute msg) -> (List (Svg.Attribute msg) -> a -> Svg msg) -> a -> ( Svg msg, Defs )
drawCurveWith parentContext currentDefs attributes draw geometry =
    let
        ( localContext, updatedDefs, convertedAttributes ) =
            applyAttributes attributes parentContext currentDefs

        finalAttributes =
            noFillAttribute :: nonScalingStrokeAttribute :: convertedAttributes
    in
    ( draw finalAttributes geometry, updatedDefs )


drawRegionWith : Context -> Defs -> List (Attribute msg) -> (List (Svg.Attribute msg) -> a -> Svg msg) -> a -> ( Svg msg, Defs )
drawRegionWith parentContext currentDefs attributes draw geometry =
    let
        ( localContext, defsFromAttributes, convertedAttributes ) =
            applyAttributes attributes parentContext currentDefs

        ( defsWithGradientReference, attributesWithGradientReference ) =
            GradientContext.apply localContext.gradientContext
                defsFromAttributes
                convertedAttributes

        ( finalAttributes, finalDefs ) =
            if localContext.bordersEnabled then
                case localContext.borderPosition of
                    BorderPosition.Centered ->
                        ( nonScalingStrokeAttribute
                            :: attributesWithGradientReference
                        , defsWithGradientReference
                        )

                    BorderPosition.Inside ->
                        Debug.crash "TODO"

                    BorderPosition.Outside ->
                        Debug.crash "TODO"
            else
                ( noStrokeAttribute :: attributesWithGradientReference
                , defsWithGradientReference
                )
    in
    ( draw finalAttributes geometry, finalDefs )


applyAttributes : List (Attribute msg) -> Context -> Defs -> ( Context, Defs, List (Svg.Attribute msg) )
applyAttributes attributes context defs =
    let
        ( updatedContext, updatedDefs, accumulatedAttributes ) =
            List.foldl applyAttribute ( context, defs, [] ) attributes
    in
    ( updatedContext
    , updatedDefs
    , accumulatedAttributes |> List.reverse |> List.concat
    )


render : Context -> Defs -> Element msg -> ( Svg msg, Defs )
render parentContext currentDefs element =
    let
        drawCurve =
            drawCurveWith parentContext currentDefs

        drawRegion =
            drawRegionWith parentContext currentDefs
    in
    case element of
        Empty ->
            ( Svg.text "", currentDefs )

        Group attributes children ->
            let
                ( localContext, postGroupDefs, svgAttributes ) =
                    applyAttributes attributes parentContext currentDefs

                processChild childElement ( accumulatedSvgElements, preChildDefs ) =
                    let
                        ( childSvgElement, postChildDefs ) =
                            render localContext preChildDefs childElement
                    in
                    ( childSvgElement :: accumulatedSvgElements, postChildDefs )

                ( accumulatedChildElements, postChildrenDefs ) =
                    List.foldl processChild ( [], postGroupDefs ) children
            in
            ( Svg.g svgAttributes (List.reverse accumulatedChildElements)
            , postChildrenDefs
            )

        PlaceIn frame child ->
            let
                localContext =
                    { parentContext
                        | gradientContext =
                            GradientContext.relativeTo frame
                                parentContext.gradientContext
                    }

                ( childSvg, updatedDefs ) =
                    render localContext currentDefs child
            in
            ( Svg.placeIn frame childSvg, updatedDefs )

        ScaleAbout point scale child ->
            let
                localContext =
                    { parentContext
                        | scaleCorrection =
                            parentContext.scaleCorrection / scale
                        , gradientContext =
                            GradientContext.scaleAbout point
                                (1 / scale)
                                parentContext.gradientContext
                    }

                ( childSvg, updatedDefs ) =
                    render localContext currentDefs child
            in
            ( Svg.scaleAbout point scale childSvg, updatedDefs )

        LineSegment attributes lineSegment ->
            drawCurve attributes Svg.lineSegment2d lineSegment

        Triangle attributes triangle ->
            drawRegion attributes Svg.triangle2d triangle

        Dot attributes point ->
            let
                ( localContext, defsFromAttributes, svgAttributes ) =
                    applyAttributes attributes parentContext currentDefs

                ( finalDefs, svgAttributesWithGradient ) =
                    GradientContext.apply localContext.gradientContext
                        defsFromAttributes
                        svgAttributes

                finalAttributes =
                    nonScalingStrokeAttribute :: svgAttributesWithGradient

                dotRadius =
                    localContext.dotRadius * localContext.scaleCorrection

                circle =
                    Circle2d.withRadius dotRadius point
            in
            ( Svg.circle2d finalAttributes circle, finalDefs )

        Arc attributes arc ->
            drawCurve attributes Svg.arc2d arc

        QuadraticSpline attributes spline ->
            drawCurve attributes Svg.quadraticSpline2d spline

        CubicSpline attributes spline ->
            drawCurve attributes Svg.cubicSpline2d spline

        Circle attributes circle ->
            drawRegion attributes Svg.circle2d circle

        Ellipse attributes ellipse ->
            drawRegion attributes Svg.ellipse2d ellipse

        EllipticalArc attributes ellipticalArc ->
            drawCurve attributes Svg.ellipticalArc2d ellipticalArc

        Polyline attributes polyline ->
            drawCurve attributes Svg.polyline2d polyline

        Polygon attributes polygon ->
            drawRegion attributes Svg.polygon2d polygon

        Text attributes point string ->
            let
                ( localContext, updatedDefs, svgAttributes ) =
                    applyAttributes attributes parentContext currentDefs

                ( x, y ) =
                    Point2d.coordinates point

                mirrorAxis =
                    Axis2d.through point Direction2d.x

                fontSize =
                    localContext.fontSize * localContext.scaleCorrection

                fontSizeAttribute =
                    Svg.Attributes.fontSize (toString fontSize)

                xAttribute =
                    Svg.Attributes.x (toString x)

                yAttribute =
                    Svg.Attributes.y (toString y)

                fillAttribute =
                    Svg.Attributes.fill "currentColor"

                strokeAttribute =
                    Svg.Attributes.stroke "none"
            in
            ( Svg.text_
                (fontSizeAttribute
                    :: xAttribute
                    :: yAttribute
                    :: fillAttribute
                    :: strokeAttribute
                    :: svgAttributes
                )
                [ Svg.text string ]
                |> Svg.mirrorAcross mirrorAxis
            , updatedDefs
            )

        RoundedRectangle attributes radius rectangle ->
            let
                ( localContext, defsFromAttributes, svgAttributes ) =
                    applyAttributes attributes parentContext currentDefs

                rectangleAxes =
                    Rectangle2d.axes rectangle

                finalGradientContext =
                    localContext.gradientContext
                        |> GradientContext.relativeTo rectangleAxes

                ( finalDefs, svgAttributesWithGradient ) =
                    GradientContext.apply finalGradientContext
                        defsFromAttributes
                        svgAttributes

                ( width, height ) =
                    Rectangle2d.dimensions rectangle

                xAttribute =
                    Svg.Attributes.x (toString (-width / 2))

                yAttribute =
                    Svg.Attributes.y (toString (-height / 2))

                widthAttribute =
                    Svg.Attributes.width (toString width)

                heightAttribute =
                    Svg.Attributes.height (toString height)

                radiusString =
                    toString radius

                rxAttribute =
                    Svg.Attributes.rx radiusString

                ryAttribute =
                    Svg.Attributes.ry radiusString
            in
            ( Svg.rect
                (nonScalingStrokeAttribute
                    :: xAttribute
                    :: yAttribute
                    :: widthAttribute
                    :: heightAttribute
                    :: rxAttribute
                    :: ryAttribute
                    :: svgAttributesWithGradient
                )
                []
                |> Svg.placeIn (Rectangle2d.axes rectangle)
            , finalDefs
            )

        Image url rectangle ->
            let
                ( width, height ) =
                    Rectangle2d.dimensions rectangle
            in
            ( Svg.image
                [ Svg.Attributes.xlinkHref url
                , Svg.Attributes.x (toString (-width / 2))
                , Svg.Attributes.y (toString (-height / 2))
                , Svg.Attributes.width (toString width)
                , Svg.Attributes.height (toString height)
                ]
                []
                |> Svg.placeIn (Rectangle2d.axes rectangle)
                |> Svg.mirrorAcross (Rectangle2d.xAxis rectangle)
            , currentDefs
            )


map : (a -> b) -> Element a -> Element b
map function element =
    let
        mapAttributes =
            List.map (Attribute.map function)

        mapElement =
            map function
    in
    case element of
        Empty ->
            Empty

        Group attributes elements ->
            Group (mapAttributes attributes)
                (List.map mapElement elements)

        PlaceIn frame element ->
            PlaceIn frame (mapElement element)

        ScaleAbout point scale element ->
            ScaleAbout point scale (mapElement element)

        LineSegment attributes lineSegment ->
            LineSegment (mapAttributes attributes) lineSegment

        Triangle attributes triangle ->
            Triangle (mapAttributes attributes) triangle

        Dot attributes point ->
            Dot (mapAttributes attributes) point

        Arc attributes arc ->
            Arc (mapAttributes attributes) arc

        CubicSpline attributes spline ->
            CubicSpline (mapAttributes attributes) spline

        QuadraticSpline attributes spline ->
            QuadraticSpline (mapAttributes attributes) spline

        Polyline attributes polyline ->
            Polyline (mapAttributes attributes) polyline

        Polygon attributes polygon ->
            Polygon (mapAttributes attributes) polygon

        Circle attributes circle ->
            Circle (mapAttributes attributes) circle

        Ellipse attributes ellipse ->
            Ellipse (mapAttributes attributes) ellipse

        EllipticalArc attributes arc ->
            EllipticalArc (mapAttributes attributes) arc

        Text attributes point string ->
            Text (mapAttributes attributes) point string

        RoundedRectangle attributes radius rectangle ->
            RoundedRectangle (mapAttributes attributes)
                radius
                rectangle

        Image url rectangle ->
            Image url rectangle
