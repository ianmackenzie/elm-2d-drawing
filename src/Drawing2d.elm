module Drawing2d
    exposing
        ( Attribute
        , Element
          --, arrow
          --, arrowWith
        , arc
        , arcWith
        , circle
        , circleWith
        , cubicSpline
        , cubicSplineWith
        , dot
        , dotWith
        , ellipse
        , ellipseWith
        , ellipticalArc
        , ellipticalArcWith
        , empty
        , group
        , groupWith
        , lineSegment
        , lineSegmentWith
        , mirrorAcross
        , placeIn
        , polygon
        , polygonWith
        , polyline
        , polylineWith
        , quadraticSpline
        , quadraticSplineWith
        , relativeTo
        , scaleAbout
          --, text
        , toHtml
        , translateBy
        , translateIn
        , triangle
        , triangleWith
        )

import Arc2d exposing (Arc2d)
import Axis2d exposing (Axis2d)
import BoundingBox2d exposing (BoundingBox2d)
import Circle2d exposing (Circle2d)
import CubicSpline2d exposing (CubicSpline2d)
import Direction2d exposing (Direction2d)
import Drawing2d.Internal as Internal exposing (applyAttributes, defaultContext, svgAttributes)
import Ellipse2d exposing (Ellipse2d)
import EllipticalArc2d exposing (EllipticalArc2d)
import Frame2d exposing (Frame2d)
import Geometry.Svg as Svg
import Html exposing (Html)
import Html.Attributes
import LineSegment2d exposing (LineSegment2d)
import Point2d exposing (Point2d)
import Polygon2d exposing (Polygon2d)
import Polyline2d exposing (Polyline2d)
import QuadraticSpline2d exposing (QuadraticSpline2d)
import Svg exposing (Svg)
import Svg.Attributes
import Triangle2d exposing (Triangle2d)
import Vector2d exposing (Vector2d)


type alias Element msg =
    Internal.Element msg


type alias Attribute msg =
    Internal.Attribute msg


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


toHtml : BoundingBox2d -> List (Attribute msg) -> List (Element msg) -> Html msg
toHtml boundingBox attributes elements =
    let
        { minX, maxY } =
            BoundingBox2d.extrema boundingBox

        topLeftFrame =
            Frame2d.atPoint (Point2d.fromCoordinates ( minX, maxY ))
                |> Frame2d.flipY

        ( width, height ) =
            BoundingBox2d.dimensions boundingBox

        context =
            defaultContext |> applyAttributes attributes
    in
    Html.div
        [ Html.Attributes.style
            [ ( "border", "0" )
            , ( "padding", "0" )
            , ( "margin", "0" )
            , ( "display", "inline-block" )
            ]
        ]
        [ Svg.svg
            [ Svg.Attributes.width (toString width)
            , Svg.Attributes.height (toString height)
            , Html.Attributes.style [ ( "display", "block" ) ]
            ]
            [ groupWith attributes elements
                |> relativeTo topLeftFrame
                |> toSvgElement context
            ]
        ]


empty : Element msg
empty =
    Internal.Empty


arrow : Point2d -> Vector2d -> Element msg
arrow =
    arrowWith []


arrowWith : List (Attribute msg) -> Point2d -> Vector2d -> Element msg
arrowWith attributes basePoint vector =
    case Vector2d.lengthAndDirection vector of
        Just ( length, direction ) ->
            Internal.Arrow attributes basePoint length direction

        Nothing ->
            empty


lineSegment : LineSegment2d -> Element msg
lineSegment =
    lineSegmentWith []


lineSegmentWith : List (Attribute msg) -> LineSegment2d -> Element msg
lineSegmentWith attributes lineSegment =
    Internal.LineSegment attributes lineSegment


triangle : Triangle2d -> Element msg
triangle =
    triangleWith []


triangleWith : List (Attribute msg) -> Triangle2d -> Element msg
triangleWith attributes triangle =
    Internal.Triangle attributes triangle


group : List (Element msg) -> Element msg
group =
    groupWith []


groupWith : List (Attribute msg) -> List (Element msg) -> Element msg
groupWith attributes elements =
    Internal.Group attributes elements


placeIn : Frame2d -> Element msg -> Element msg
placeIn frame element =
    Internal.PlaceIn frame element


relativeTo : Frame2d -> Element msg -> Element msg
relativeTo frame element =
    placeIn (Frame2d.relativeTo frame Frame2d.xy) element


dot : Point2d -> Element msg
dot =
    dotWith []


dotWith : List (Attribute msg) -> Point2d -> Element msg
dotWith attributes point =
    Internal.Dot attributes point


translateBy : Vector2d -> Element msg -> Element msg
translateBy displacement element =
    placeIn (Frame2d.translateBy displacement Frame2d.xy) element


translateIn : Direction2d -> Float -> Element msg -> Element msg
translateIn direction distance element =
    translateBy (Vector2d.withLength distance direction) element


scaleAbout : Point2d -> Float -> Element msg -> Element msg
scaleAbout point scale element =
    Internal.ScaleAbout point scale element


mirrorAcross : Axis2d -> Element msg -> Element msg
mirrorAcross axis element =
    placeIn (Frame2d.mirrorAcross axis Frame2d.xy) element


arc : Arc2d -> Element msg
arc =
    arcWith []


arcWith : List (Attribute msg) -> Arc2d -> Element msg
arcWith attributes arc =
    Internal.Arc attributes arc


quadraticSpline : QuadraticSpline2d -> Element msg
quadraticSpline =
    quadraticSplineWith []


quadraticSplineWith : List (Attribute msg) -> QuadraticSpline2d -> Element msg
quadraticSplineWith attributes quadraticSpline =
    Internal.QuadraticSpline attributes quadraticSpline


cubicSpline : CubicSpline2d -> Element msg
cubicSpline =
    cubicSplineWith []


cubicSplineWith : List (Attribute msg) -> CubicSpline2d -> Element msg
cubicSplineWith attributes cubicSpline =
    Internal.CubicSpline attributes cubicSpline


polyline : Polyline2d -> Element msg
polyline =
    polylineWith []


polylineWith : List (Attribute msg) -> Polyline2d -> Element msg
polylineWith attributes polyline =
    Internal.Polyline attributes polyline


polygon : Polygon2d -> Element msg
polygon =
    polygonWith []


polygonWith : List (Attribute msg) -> Polygon2d -> Element msg
polygonWith attributes polygon =
    Internal.Polygon attributes polygon


circle : Circle2d -> Element msg
circle =
    circleWith []


circleWith : List (Attribute msg) -> Circle2d -> Element msg
circleWith attributes circle =
    Internal.Circle attributes circle


ellipticalArc : EllipticalArc2d -> Element msg
ellipticalArc =
    ellipticalArcWith []


ellipticalArcWith : List (Attribute msg) -> EllipticalArc2d -> Element msg
ellipticalArcWith attributes ellipticalArc =
    Internal.EllipticalArc attributes ellipticalArc


ellipse : Ellipse2d -> Element msg
ellipse =
    ellipseWith []


ellipseWith : List (Attribute msg) -> Ellipse2d -> Element msg
ellipseWith attributes ellipse =
    Internal.Ellipse attributes ellipse
