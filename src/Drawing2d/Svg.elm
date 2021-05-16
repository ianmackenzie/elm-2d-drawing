module Drawing2d.Svg exposing
    ( arc2d
    , boundingBox2d
    , circle2d
    , cubicSpline2d
    , ellipse2d
    , ellipticalArc2d
    , lineSegment2d
    , polygon2d
    , polyline2d
    , quadraticSpline2d
    , rectangle2d
    , triangle2d
    , unsafePath
    )

import Angle exposing (Angle)
import Arc2d exposing (Arc2d)
import Axis2d exposing (Axis2d)
import BoundingBox2d exposing (BoundingBox2d)
import Circle2d exposing (Circle2d)
import CubicSpline2d exposing (CubicSpline2d)
import Direction2d exposing (Direction2d)
import Ellipse2d exposing (Ellipse2d)
import EllipticalArc2d exposing (EllipticalArc2d)
import Frame2d exposing (Frame2d)
import LineSegment2d exposing (LineSegment2d)
import Parameter1d
import Pixels exposing (Pixels)
import Point2d exposing (Point2d)
import Polygon2d exposing (Polygon2d)
import Polyline2d exposing (Polyline2d)
import QuadraticSpline2d exposing (QuadraticSpline2d)
import Quantity exposing (Quantity(..))
import Rectangle2d exposing (Rectangle2d)
import Svg exposing (Svg)
import Svg.Attributes
import Triangle2d exposing (Triangle2d)
import Vector2d exposing (Vector2d)


coordinatesString : Point2d units coordinates -> String
coordinatesString point =
    let
        { x, y } =
            Point2d.unwrap point
    in
    String.fromFloat x ++ "," ++ String.fromFloat -y


pointsAttribute : List (Point2d units coordinates) -> Svg.Attribute msg
pointsAttribute points =
    Svg.Attributes.points (String.join " " (List.map coordinatesString points))


unsafePath : List (Svg.Attribute msg) -> String -> Svg msg
unsafePath svgAttributes pathString =
    Svg.path (Svg.Attributes.d pathString :: svgAttributes) []


lineSegment2d : List (Svg.Attribute msg) -> LineSegment2d units coordinates -> Svg msg
lineSegment2d attributes lineSegment =
    let
        p1 =
            Point2d.unwrap (LineSegment2d.startPoint lineSegment)

        p2 =
            Point2d.unwrap (LineSegment2d.endPoint lineSegment)
    in
    Svg.line
        (Svg.Attributes.x1 (String.fromFloat p1.x)
            :: Svg.Attributes.y1 (String.fromFloat -p1.y)
            :: Svg.Attributes.x2 (String.fromFloat p2.x)
            :: Svg.Attributes.y2 (String.fromFloat -p2.y)
            :: attributes
        )
        []


triangle2d : List (Svg.Attribute msg) -> Triangle2d units coordinates -> Svg msg
triangle2d attributes triangle =
    let
        ( p1, p2, p3 ) =
            Triangle2d.vertices triangle
    in
    Svg.polygon (pointsAttribute [ p1, p2, p3 ] :: attributes) []


polyline2d : List (Svg.Attribute msg) -> Polyline2d units coordinates -> Svg msg
polyline2d attributes polyline =
    let
        vertices =
            Polyline2d.vertices polyline
    in
    Svg.polyline (pointsAttribute vertices :: attributes) []


polygon2d : List (Svg.Attribute msg) -> Polygon2d units coordinates -> Svg msg
polygon2d attributes polygon =
    let
        loops =
            Polygon2d.outerLoop polygon :: Polygon2d.innerLoops polygon

        loopString loop =
            case loop of
                [] ->
                    ""

                _ ->
                    let
                        coordinateStrings =
                            loop
                                |> List.map
                                    (\point ->
                                        let
                                            { x, y } =
                                                Point2d.unwrap point
                                        in
                                        String.fromFloat x ++ " " ++ String.fromFloat -y
                                    )
                    in
                    "M " ++ String.join " L " coordinateStrings ++ " Z"
    in
    unsafePath attributes (String.join " " (List.map loopString loops))


rectangle2d : List (Svg.Attribute msg) -> Rectangle2d units coordinates -> Svg msg
rectangle2d attributes rectangle =
    polygon2d attributes (Rectangle2d.toPolygon rectangle)


arc2d : List (Svg.Attribute msg) -> Arc2d units coordinates -> Svg msg
arc2d attributes arc =
    let
        sweptAngle =
            Arc2d.sweptAngle arc
    in
    if sweptAngle == Quantity.zero then
        lineSegment2d attributes
            (LineSegment2d.from (Arc2d.startPoint arc) (Arc2d.endPoint arc))

    else
        let
            maxSegmentAngle =
                Angle.turns (1 / 3)

            numSegments =
                1 + floor (abs (Quantity.ratio sweptAngle maxSegmentAngle))

            sweepFlag =
                if sweptAngle |> Quantity.greaterThanOrEqualTo Quantity.zero then
                    "0"

                else
                    "1"

            p0 =
                Point2d.unwrap (Arc2d.startPoint arc)

            (Quantity radius) =
                Arc2d.radius arc

            radiusString =
                String.fromFloat radius

            moveCommand =
                [ "M"
                , String.fromFloat p0.x
                , String.fromFloat -p0.y
                ]

            arcSegment parameterValue =
                let
                    { x, y } =
                        Point2d.unwrap (Arc2d.pointOn arc parameterValue)
                in
                [ "A"
                , radiusString
                , radiusString
                , "0"
                , "0"
                , sweepFlag
                , String.fromFloat x
                , String.fromFloat -y
                ]

            arcSegments =
                Parameter1d.trailing numSegments arcSegment

            pathComponents =
                moveCommand ++ List.concat arcSegments
        in
        unsafePath attributes (String.join " " pathComponents)


ellipticalArc2d : List (Svg.Attribute msg) -> EllipticalArc2d units coordinates -> Svg msg
ellipticalArc2d attributes arc =
    let
        sweptAngle =
            EllipticalArc2d.sweptAngle arc

        maxSegmentAngle =
            Angle.turns (1 / 3)

        numSegments =
            1 + floor (abs (Quantity.ratio sweptAngle maxSegmentAngle))

        sweepFlag =
            if sweptAngle |> Quantity.greaterThanOrEqualTo Quantity.zero then
                "0"

            else
                "1"

        p0 =
            Point2d.unwrap (EllipticalArc2d.startPoint arc)

        (Quantity xRadius) =
            EllipticalArc2d.xRadius arc

        xRadiusString =
            String.fromFloat xRadius

        (Quantity yRadius) =
            EllipticalArc2d.yRadius arc

        yRadiusString =
            String.fromFloat yRadius

        xDirection =
            EllipticalArc2d.xDirection arc

        xAngleString =
            String.fromFloat -(Angle.inDegrees (Direction2d.toAngle xDirection))

        moveCommand =
            [ "M"
            , String.fromFloat p0.x
            , String.fromFloat -p0.y
            ]

        arcSegment parameterValue =
            let
                { x, y } =
                    Point2d.unwrap (EllipticalArc2d.pointOn arc parameterValue)
            in
            [ "A"
            , xRadiusString
            , yRadiusString
            , xAngleString
            , "0"
            , sweepFlag
            , String.fromFloat x
            , String.fromFloat -y
            ]

        arcSegments =
            Parameter1d.trailing numSegments arcSegment

        pathComponents =
            moveCommand ++ List.concat arcSegments
    in
    unsafePath attributes (String.join " " pathComponents)


circle2d : List (Svg.Attribute msg) -> Circle2d units coordinates -> Svg msg
circle2d attributes circle =
    let
        { x, y } =
            Point2d.unwrap (Circle2d.centerPoint circle)

        cx =
            Svg.Attributes.cx (String.fromFloat x)

        cy =
            Svg.Attributes.cy (String.fromFloat -y)

        (Quantity radius) =
            Circle2d.radius circle

        r =
            Svg.Attributes.r (String.fromFloat radius)
    in
    Svg.circle (cx :: cy :: r :: attributes) []


ellipse2d : List (Svg.Attribute msg) -> Ellipse2d units coordinates -> Svg msg
ellipse2d attributes ellipse =
    ellipticalArc2d attributes (Ellipse2d.toEllipticalArc ellipse)


quadraticSpline2d : List (Svg.Attribute msg) -> QuadraticSpline2d units coordinates -> Svg msg
quadraticSpline2d attributes spline =
    let
        p1 =
            Point2d.unwrap (QuadraticSpline2d.firstControlPoint spline)

        p2 =
            Point2d.unwrap (QuadraticSpline2d.secondControlPoint spline)

        p3 =
            Point2d.unwrap (QuadraticSpline2d.thirdControlPoint spline)

        pathComponents =
            [ "M"
            , String.fromFloat p1.x
            , String.fromFloat -p1.y
            , "Q"
            , String.fromFloat p2.x
            , String.fromFloat -p2.y
            , String.fromFloat p3.x
            , String.fromFloat -p3.y
            ]
    in
    unsafePath attributes (String.join " " pathComponents)


cubicSpline2d : List (Svg.Attribute msg) -> CubicSpline2d units coordinates -> Svg msg
cubicSpline2d attributes spline =
    let
        p1 =
            Point2d.unwrap (CubicSpline2d.firstControlPoint spline)

        p2 =
            Point2d.unwrap (CubicSpline2d.secondControlPoint spline)

        p3 =
            Point2d.unwrap (CubicSpline2d.thirdControlPoint spline)

        p4 =
            Point2d.unwrap (CubicSpline2d.fourthControlPoint spline)

        pathComponents =
            [ "M"
            , String.fromFloat p1.x
            , String.fromFloat -p1.y
            , "C"
            , String.fromFloat p2.x
            , String.fromFloat -p2.y
            , String.fromFloat p3.x
            , String.fromFloat -p3.y
            , String.fromFloat p4.x
            , String.fromFloat -p4.y
            ]
    in
    unsafePath attributes (String.join " " pathComponents)


boundingBox2d : List (Svg.Attribute msg) -> BoundingBox2d units coordinates -> Svg msg
boundingBox2d attributes boundingBox =
    let
        extrema =
            BoundingBox2d.extrema boundingBox

        (Quantity minX) =
            extrema.minX

        (Quantity minY) =
            extrema.minY

        (Quantity maxX) =
            extrema.maxX

        (Quantity maxY) =
            extrema.maxY

        x =
            Svg.Attributes.x (String.fromFloat minX)

        y =
            Svg.Attributes.y (String.fromFloat -maxY)

        width =
            Svg.Attributes.width (String.fromFloat (maxX - minX))

        height =
            Svg.Attributes.height (String.fromFloat (maxY - minY))
    in
    Svg.rect (x :: y :: width :: height :: attributes) []
