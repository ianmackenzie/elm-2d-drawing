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
        , map
        , mirrorAcross
        , placeIn
        , polygon
        , polygonWith
        , polyline
        , polylineWith
        , quadraticSpline
        , quadraticSplineWith
        , rectangle
        , rectangleWith
        , relativeTo
        , roundedRectangle
        , roundedRectangleWith
        , scaleAbout
        , text
        , textShape
        , textShapeWith
        , textWith
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
import Color
import CubicSpline2d exposing (CubicSpline2d)
import Direction2d exposing (Direction2d)
import Drawing2d.Attribute as Attribute
import Drawing2d.Attributes as Attributes
import Drawing2d.Element as Element
import Drawing2d.Internal as Internal exposing (defaultContext)
import Drawing2d.Text as Text
import Ellipse2d exposing (Ellipse2d)
import EllipticalArc2d exposing (EllipticalArc2d)
import Frame2d exposing (Frame2d)
import Html exposing (Html)
import Html.Attributes
import LineSegment2d exposing (LineSegment2d)
import Point2d exposing (Point2d)
import Polygon2d exposing (Polygon2d)
import Polyline2d exposing (Polyline2d)
import QuadraticSpline2d exposing (QuadraticSpline2d)
import Rectangle2d exposing (Rectangle2d)
import Svg exposing (Svg)
import Svg.Attributes
import Triangle2d exposing (Triangle2d)
import Vector2d exposing (Vector2d)


type alias Element msg =
    Internal.Element msg


type alias Attribute msg =
    Internal.Attribute msg


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
            List.foldl Attribute.apply defaultContext attributes

        defaultAttributes =
            [ Attributes.textColor Color.black
            , Attributes.whiteFill
            , Attributes.blackStroke
            , Attributes.textAnchor Text.bottomLeft
            ]
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
            [ groupWith defaultAttributes [ groupWith attributes elements ]
                |> relativeTo topLeftFrame
                |> Element.toSvgElement context
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


rectangle : Rectangle2d -> Element msg
rectangle =
    rectangleWith []


rectangleWith : List (Attribute msg) -> Rectangle2d -> Element msg
rectangleWith attributes rectangle =
    polygonWith attributes (Rectangle2d.toPolygon rectangle)


roundedRectangle : Float -> Rectangle2d -> Element msg
roundedRectangle =
    roundedRectangleWith []


roundedRectangleWith : List (Attribute msg) -> Float -> Rectangle2d -> Element msg
roundedRectangleWith attributes radius rectangle =
    Internal.RoundedRectangle attributes radius rectangle


text : Point2d -> String -> Element msg
text =
    textWith []


textWith : List (Attribute msg) -> Point2d -> String -> Element msg
textWith attributes point string =
    Internal.Text attributes point string


textShape : Point2d -> String -> Element msg
textShape =
    textShapeWith []


textShapeWith : List (Attribute msg) -> Point2d -> String -> Element msg
textShapeWith attributes point string =
    Internal.TextShape attributes point string


mapAttribute : (a -> b) -> Attribute a -> Attribute b
mapAttribute function attribute =
    case attribute of
        Internal.FillStyle style ->
            Internal.FillStyle style

        Internal.StrokeStyle style ->
            Internal.StrokeStyle style

        Internal.StrokeWidth width ->
            Internal.StrokeWidth width

        Internal.ArrowTipStyle style ->
            Internal.ArrowTipStyle style

        Internal.DotRadius radius ->
            Internal.DotRadius radius

        Internal.TextAnchor anchor ->
            Internal.TextAnchor anchor

        Internal.TextColor color ->
            Internal.TextColor color

        Internal.FontSize px ->
            Internal.FontSize px

        Internal.FontFamily fonts ->
            Internal.FontFamily fonts

        Internal.OnClick message ->
            Internal.OnClick (function message)

        Internal.OnMouseDown handler ->
            Internal.OnMouseDown (handler >> function)


map : (a -> b) -> Element a -> Element b
map function element =
    let
        mapAttributes =
            List.map (mapAttribute function)

        mapElement =
            map function
    in
    case element of
        Internal.Empty ->
            Internal.Empty

        Internal.Group attributes elements ->
            Internal.Group (mapAttributes attributes)
                (List.map mapElement elements)

        Internal.PlaceIn frame element ->
            Internal.PlaceIn frame (mapElement element)

        Internal.ScaleAbout point scale element ->
            Internal.ScaleAbout point scale (mapElement element)

        Internal.Arrow attributes point length direction ->
            Internal.Arrow (mapAttributes attributes) point length direction

        Internal.LineSegment attributes lineSegment ->
            Internal.LineSegment (mapAttributes attributes) lineSegment

        Internal.Triangle attributes triangle ->
            Internal.Triangle (mapAttributes attributes) triangle

        Internal.Dot attributes point ->
            Internal.Dot (mapAttributes attributes) point

        Internal.Arc attributes arc ->
            Internal.Arc (mapAttributes attributes) arc

        Internal.CubicSpline attributes spline ->
            Internal.CubicSpline (mapAttributes attributes) spline

        Internal.QuadraticSpline attributes spline ->
            Internal.QuadraticSpline (mapAttributes attributes) spline

        Internal.Polyline attributes polyline ->
            Internal.Polyline (mapAttributes attributes) polyline

        Internal.Polygon attributes polygon ->
            Internal.Polygon (mapAttributes attributes) polygon

        Internal.Circle attributes circle ->
            Internal.Circle (mapAttributes attributes) circle

        Internal.Ellipse attributes ellipse ->
            Internal.Ellipse (mapAttributes attributes) ellipse

        Internal.EllipticalArc attributes arc ->
            Internal.EllipticalArc (mapAttributes attributes) arc

        Internal.Text attributes point string ->
            Internal.Text (mapAttributes attributes) point string

        Internal.TextShape attributes point string ->
            Internal.TextShape (mapAttributes attributes) point string

        Internal.RoundedRectangle attributes radius rectangle ->
            Internal.RoundedRectangle (mapAttributes attributes)
                radius
                rectangle
