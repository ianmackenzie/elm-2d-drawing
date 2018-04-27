module Drawing2d.Element exposing (Element, toSvgElement)

import Axis2d
import Circle2d
import Direction2d
import Drawing2d.Attribute as Attribute exposing (Attribute, Context)
import Drawing2d.Internal as Internal
import Frame2d
import Geometry.Svg as Svg
import LineSegment2d
import Point2d
import Rectangle2d
import Svg exposing (Svg)
import Svg.Attributes
import Triangle2d


type alias Element msg =
    Internal.Element msg


svgAttributes : List (Attribute msg) -> List (Svg.Attribute msg)
svgAttributes attributes =
    List.concat (List.map Attribute.toSvgAttributes attributes)


applyAttributes : List (Attribute msg) -> Context -> Context
applyAttributes attributes context =
    List.foldl Attribute.apply context attributes


toSvgElement : Internal.Context -> Element msg -> Svg msg
toSvgElement parentContext element =
    case element of
        Internal.Empty ->
            Svg.text ""

        Internal.Group attributes children ->
            let
                localContext =
                    parentContext |> applyAttributes attributes
            in
            Svg.g (svgAttributes attributes)
                (List.map (toSvgElement localContext) children)

        Internal.PlaceIn frame element ->
            Svg.placeIn frame (toSvgElement parentContext element)

        Internal.ScaleAbout point scale element ->
            Svg.scaleAbout point scale (toSvgElement parentContext element)

        Internal.Arrow attributes basePoint length direction ->
            let
                localContext =
                    parentContext |> applyAttributes attributes

                localFrame =
                    Frame2d.withXDirection direction basePoint

                (Internal.TriangularTip tipOptions) =
                    localContext.arrowTipStyle

                tipPoint =
                    Point2d.fromCoordinatesIn localFrame ( length, 0 )

                stemLength =
                    length - tipOptions.length

                tipBasePoint =
                    Point2d.fromCoordinatesIn localFrame ( stemLength, 0 )

                stem =
                    LineSegment2d.from basePoint tipBasePoint

                tipHalfWidth =
                    tipOptions.width / 2

                leftPoint =
                    Point2d.fromCoordinatesIn localFrame
                        ( stemLength, tipHalfWidth )

                rightPoint =
                    Point2d.fromCoordinatesIn localFrame
                        ( stemLength, -tipHalfWidth )

                tip =
                    Triangle2d.fromVertices ( rightPoint, tipPoint, leftPoint )
            in
            Svg.g (svgAttributes attributes)
                [ Svg.lineSegment2d [] stem, Svg.triangle2d [] tip ]

        Internal.LineSegment attributes lineSegment ->
            Svg.lineSegment2d (svgAttributes attributes) lineSegment

        Internal.Triangle attributes triangle ->
            Svg.triangle2d (svgAttributes attributes) triangle

        Internal.Dot attributes point ->
            let
                localContext =
                    parentContext |> applyAttributes attributes
            in
            Svg.circle2d (svgAttributes attributes)
                (Circle2d.withRadius localContext.dotRadius point)

        Internal.Arc attributes arc ->
            Svg.arc2d (svgAttributes attributes) arc

        Internal.QuadraticSpline attributes quadraticSpline ->
            Svg.quadraticSpline2d (svgAttributes attributes) quadraticSpline

        Internal.CubicSpline attributes cubicSpline ->
            Svg.cubicSpline2d (svgAttributes attributes) cubicSpline

        Internal.Circle attributes circle ->
            Svg.circle2d (svgAttributes attributes) circle

        Internal.Ellipse attributes ellipse ->
            Svg.ellipse2d (svgAttributes attributes) ellipse

        Internal.EllipticalArc attributes ellipticalArc ->
            Svg.ellipticalArc2d (svgAttributes attributes) ellipticalArc

        Internal.Polyline attributes polyline ->
            Svg.polyline2d (svgAttributes attributes) polyline

        Internal.Polygon attributes polygon ->
            Svg.polygon2d (svgAttributes attributes) polygon

        Internal.Text attributes point string ->
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

        Internal.TextShape attributes point string ->
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

        Internal.RoundedRectangle attributes radius rectangle ->
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
