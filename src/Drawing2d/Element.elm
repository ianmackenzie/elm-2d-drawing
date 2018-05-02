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


type Element msg
    = Empty
    | Group (List (Attribute msg)) (List (Element msg))
    | PlaceIn Frame2d (Element msg)
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


noFillAttribute : Svg.Attribute msg
noFillAttribute =
    Svg.Attributes.fill "none"


noStrokeAttribute : Svg.Attribute msg
noStrokeAttribute =
    Svg.Attributes.stroke "none"


curveAttributes : List (Svg.Attribute msg) -> List (Svg.Attribute msg)
curveAttributes attributes =
    noFillAttribute :: attributes


drawCurveWith : Context -> Defs -> List (Attribute msg) -> (List (Svg.Attribute msg) -> a -> Svg msg) -> (Frame2d -> a -> a) -> a -> ( Svg msg, Defs )
drawCurveWith parentContext currentDefs attributes draw placeIn geometry =
    let
        ( localContext, updatedDefs, convertedAttributes ) =
            applyAttributes attributes parentContext currentDefs

        finalAttributes =
            noFillAttribute :: convertedAttributes

        placedGeometry =
            placeIn localContext.placementFrame geometry
    in
    ( draw finalAttributes placedGeometry, updatedDefs )


drawRegionWith : Context -> Defs -> List (Attribute msg) -> (List (Svg.Attribute msg) -> a -> Svg msg) -> (Frame2d -> a -> a) -> a -> ( Svg msg, Defs )
drawRegionWith parentContext currentDefs attributes draw placeIn geometry =
    let
        ( localContext, updatedDefs, convertedAttributes ) =
            applyAttributes attributes parentContext currentDefs

        ( finalAttributes, finalDefs ) =
            if localContext.bordersEnabled then
                case localContext.borderPosition of
                    BorderPosition.Centered ->
                        ( convertedAttributes, updatedDefs )

                    BorderPosition.Inside ->
                        Debug.crash "TODO"

                    BorderPosition.Outside ->
                        Debug.crash "TODO"
            else
                ( noStrokeAttribute :: convertedAttributes, updatedDefs )

        placedGeometry =
            placeIn localContext.placementFrame geometry
    in
    ( draw finalAttributes placedGeometry, finalDefs )


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

        PlaceIn frame element ->
            let
                childContext =
                    { parentContext
                        | placementFrame =
                            Frame2d.placeIn parentContext.placementFrame frame
                    }
            in
            render childContext currentDefs element

        LineSegment attributes lineSegment ->
            drawCurve attributes
                Svg.lineSegment2d
                LineSegment2d.placeIn
                lineSegment

        Triangle attributes triangle ->
            drawRegion attributes Svg.triangle2d Triangle2d.placeIn triangle

        Dot attributes point ->
            let
                ( localContext, updatedDefs, svgAttributes ) =
                    applyAttributes attributes parentContext currentDefs

                circle =
                    Circle2d.withRadius localContext.dotRadius
                        (Point2d.placeIn localContext.placementFrame point)
            in
            ( Svg.circle2d svgAttributes circle, updatedDefs )

        Arc attributes arc ->
            drawCurve attributes Svg.arc2d Arc2d.placeIn arc

        QuadraticSpline attributes spline ->
            drawCurve attributes
                Svg.quadraticSpline2d
                QuadraticSpline2d.placeIn
                spline

        CubicSpline attributes spline ->
            drawCurve attributes Svg.cubicSpline2d CubicSpline2d.placeIn spline

        Circle attributes circle ->
            drawRegion attributes Svg.circle2d Circle2d.placeIn circle

        Ellipse attributes ellipse ->
            drawRegion attributes Svg.ellipse2d Ellipse2d.placeIn ellipse

        EllipticalArc attributes ellipticalArc ->
            drawCurve attributes
                Svg.ellipticalArc2d
                EllipticalArc2d.placeIn
                ellipticalArc

        Polyline attributes polyline ->
            drawCurve attributes Svg.polyline2d Polyline2d.placeIn polyline

        Polygon attributes polygon ->
            drawRegion attributes Svg.polygon2d Polygon2d.placeIn polygon

        Text attributes point string ->
            let
                ( localContext, updatedDefs, svgAttributes ) =
                    applyAttributes attributes parentContext currentDefs

                placedPoint =
                    Point2d.placeIn localContext.placementFrame point

                ( x, y ) =
                    Point2d.coordinates placedPoint

                mirrorAxis =
                    Axis2d.through placedPoint Direction2d.x

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
                (xAttribute
                    :: yAttribute
                    :: fillAttribute
                    :: strokeAttribute
                    :: svgAttributes
                )
                [ Svg.text string ]
                |> Svg.mirrorAcross mirrorAxis
            , updatedDefs
            )

        RoundedRectangle attributes radius originalRectangle ->
            let
                ( localContext, updatedDefs, svgAttributes ) =
                    applyAttributes attributes parentContext currentDefs

                placedRectangle =
                    originalRectangle
                        |> Rectangle2d.placeIn localContext.placementFrame

                ( width, height ) =
                    Rectangle2d.dimensions placedRectangle

                halfWidth =
                    width / 2

                halfHeight =
                    height / 2

                rectangleAxes =
                    Rectangle2d.axes placedRectangle

                p0 =
                    Point2d.fromCoordinatesIn rectangleAxes
                        ( halfWidth - radius, -halfHeight )

                p1 =
                    Point2d.fromCoordinatesIn rectangleAxes
                        ( halfWidth, -halfHeight + radius )

                p2 =
                    Point2d.fromCoordinatesIn rectangleAxes
                        ( halfWidth, halfHeight - radius )

                p3 =
                    Point2d.fromCoordinatesIn rectangleAxes
                        ( halfWidth - radius, halfHeight )

                p4 =
                    Point2d.fromCoordinatesIn rectangleAxes
                        ( -halfWidth + radius, halfHeight )

                p5 =
                    Point2d.fromCoordinatesIn rectangleAxes
                        ( -halfWidth, halfHeight - radius )

                p6 =
                    Point2d.fromCoordinatesIn rectangleAxes
                        ( -halfWidth, -halfHeight + radius )

                p7 =
                    Point2d.fromCoordinatesIn rectangleAxes
                        ( -halfWidth + radius, -halfHeight )

                x0 =
                    toString (Point2d.xCoordinate p0)

                y0 =
                    toString (Point2d.yCoordinate p0)

                x1 =
                    toString (Point2d.xCoordinate p1)

                y1 =
                    toString (Point2d.yCoordinate p1)

                x2 =
                    toString (Point2d.xCoordinate p2)

                y2 =
                    toString (Point2d.yCoordinate p2)

                x3 =
                    toString (Point2d.xCoordinate p3)

                y3 =
                    toString (Point2d.yCoordinate p3)

                x4 =
                    toString (Point2d.xCoordinate p4)

                y4 =
                    toString (Point2d.yCoordinate p4)

                x5 =
                    toString (Point2d.xCoordinate p5)

                y5 =
                    toString (Point2d.yCoordinate p5)

                x6 =
                    toString (Point2d.xCoordinate p6)

                y6 =
                    toString (Point2d.yCoordinate p6)

                x7 =
                    toString (Point2d.xCoordinate p7)

                y7 =
                    toString (Point2d.yCoordinate p7)

                radiusString =
                    toString radius

                moveTo x y =
                    "M " ++ x ++ " " ++ y

                lineTo x y =
                    "L " ++ x ++ " " ++ y

                arcTo x y =
                    String.join " "
                        [ "A"
                        , radiusString
                        , radiusString
                        , "0"
                        , "0"
                        , "0"
                        , x
                        , y
                        ]

                path =
                    String.join " "
                        [ moveTo x0 y0
                        , arcTo x1 y1
                        , lineTo x2 y2
                        , arcTo x3 y3
                        , lineTo x4 y4
                        , arcTo x5 y5
                        , lineTo x6 y6
                        , arcTo x7 y7
                        , "Z"
                        ]

                pathAttribute =
                    Svg.Attributes.d path
            in
            ( Svg.path (pathAttribute :: svgAttributes) [], updatedDefs )

        Image url originalRectangle ->
            let
                placedRectangle =
                    originalRectangle
                        |> Rectangle2d.placeIn parentContext.placementFrame

                ( width, height ) =
                    Rectangle2d.dimensions placedRectangle
            in
            ( Svg.image
                [ Svg.Attributes.xlinkHref url
                , Svg.Attributes.x (toString (-width / 2))
                , Svg.Attributes.y (toString (-height / 2))
                , Svg.Attributes.width (toString width)
                , Svg.Attributes.height (toString height)
                ]
                []
                |> Svg.placeIn (Rectangle2d.axes placedRectangle)
                |> Svg.mirrorAcross (Rectangle2d.xAxis placedRectangle)
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
