module Drawing2d.Element exposing (Element(..), map, toSvgElement)

import Arc2d exposing (Arc2d)
import Axis2d exposing (Axis2d)
import Circle2d exposing (Circle2d)
import CubicSpline2d exposing (CubicSpline2d)
import Direction2d exposing (Direction2d)
import Drawing2d.Attribute as Attribute exposing (Attribute, Context)
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
    | TextShape (List (Attribute msg)) Point2d String
    | RoundedRectangle (List (Attribute msg)) Float Rectangle2d


svgAttributes : List (Attribute msg) -> List (Svg.Attribute msg)
svgAttributes attributes =
    List.concat (List.map Attribute.toSvgAttributes attributes)


applyAttributes : List (Attribute msg) -> Context -> Context
applyAttributes attributes context =
    List.foldl Attribute.apply context attributes


toSvgElement : Context -> Element msg -> Svg msg
toSvgElement parentContext element =
    case element of
        Empty ->
            Svg.text ""

        Group attributes children ->
            let
                localContext =
                    parentContext |> applyAttributes attributes
            in
            Svg.g (svgAttributes attributes)
                (List.map (toSvgElement localContext) children)

        PlaceIn frame element ->
            Svg.placeIn frame (toSvgElement parentContext element)

        ScaleAbout point scale element ->
            Svg.scaleAbout point scale (toSvgElement parentContext element)

        LineSegment attributes lineSegment ->
            Svg.lineSegment2d (svgAttributes attributes) lineSegment

        Triangle attributes triangle ->
            Svg.triangle2d (svgAttributes attributes) triangle

        Dot attributes point ->
            let
                localContext =
                    parentContext |> applyAttributes attributes
            in
            Svg.circle2d (svgAttributes attributes)
                (Circle2d.withRadius localContext.dotRadius point)

        Arc attributes arc ->
            Svg.arc2d (svgAttributes attributes) arc

        QuadraticSpline attributes quadraticSpline ->
            Svg.quadraticSpline2d (svgAttributes attributes) quadraticSpline

        CubicSpline attributes cubicSpline ->
            Svg.cubicSpline2d (svgAttributes attributes) cubicSpline

        Circle attributes circle ->
            Svg.circle2d (svgAttributes attributes) circle

        Ellipse attributes ellipse ->
            Svg.ellipse2d (svgAttributes attributes) ellipse

        EllipticalArc attributes ellipticalArc ->
            Svg.ellipticalArc2d (svgAttributes attributes) ellipticalArc

        Polyline attributes polyline ->
            Svg.polyline2d (svgAttributes attributes) polyline

        Polygon attributes polygon ->
            Svg.polygon2d (svgAttributes attributes) polygon

        Text attributes point string ->
            let
                ( x, y ) =
                    Point2d.coordinates point

                mirrorAxis =
                    Axis2d.through point Direction2d.x

                xAttribute =
                    Svg.Attributes.x (toString x)

                yAttribute =
                    Svg.Attributes.y (toString y)

                fillAttribute =
                    Svg.Attributes.fill "currentColor"

                strokeAttribute =
                    Svg.Attributes.stroke "none"
            in
            Svg.text_
                (xAttribute
                    :: yAttribute
                    :: fillAttribute
                    :: strokeAttribute
                    :: svgAttributes attributes
                )
                [ Svg.text string ]
                |> Svg.mirrorAcross mirrorAxis

        TextShape attributes point string ->
            let
                ( x, y ) =
                    Point2d.coordinates point

                mirrorAxis =
                    Axis2d.through point Direction2d.x

                xAttribute =
                    Svg.Attributes.x (toString x)

                yAttribute =
                    Svg.Attributes.y (toString y)
            in
            Svg.text_ (xAttribute :: yAttribute :: svgAttributes attributes)
                [ Svg.text string ]
                |> Svg.mirrorAcross mirrorAxis

        RoundedRectangle attributes radius rectangle ->
            let
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
            Svg.rect
                (xAttribute
                    :: yAttribute
                    :: widthAttribute
                    :: heightAttribute
                    :: rxAttribute
                    :: ryAttribute
                    :: svgAttributes attributes
                )
                []
                |> Svg.placeIn (Rectangle2d.axes rectangle)


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

        TextShape attributes point string ->
            TextShape (mapAttributes attributes) point string

        RoundedRectangle attributes radius rectangle ->
            RoundedRectangle (mapAttributes attributes)
                radius
                rectangle
