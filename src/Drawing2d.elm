module Drawing2d exposing
    ( Attribute
    , Element
    , arc
    , arcWith
    , circle
    , circleWith
    , cubicSpline
    , cubicSplineWith
    , dot
    , dotWith
    , dots
    , dotsWith
    , ellipse
    , ellipseWith
    , ellipticalArc
    , ellipticalArcWith
    , empty
    , group
    , groupWith
    , image
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
    , rotateAround
    , roundedRectangle
    , roundedRectangleWith
    , text
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
import Drawing2d.Border as Border
import Drawing2d.Context as Context exposing (Context)
import Drawing2d.Defs as Defs exposing (Defs)
import Drawing2d.Element as Element
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
    Element.Element msg


type alias Attribute msg =
    Attribute.Attribute msg


toHtml : BoundingBox2d -> List (Attribute msg) -> List (Element msg) -> Html msg
toHtml boundingBox attributes elements =
    let
        ( width, height ) =
            BoundingBox2d.dimensions boundingBox

        defaultAttributes =
            [ Attributes.blackStroke
            , Attributes.strokeWidth 1
            , Attributes.whiteFill
            , Attributes.strokedBorder
            , Attributes.borderPosition Border.centered
            , Attributes.fontSize 20
            , Attributes.textColor Color.black
            , Attributes.textAnchor Text.bottomLeft
            , Attributes.dotRadius 3
            ]

        rootElement =
            groupWith (defaultAttributes ++ attributes) elements

        ( rootSvgElement, defs ) =
            Element.render (Context.init boundingBox) Defs.init rootElement
    in
    Html.div
        [ Html.Attributes.style "border" "0"
        , Html.Attributes.style "padding" "0"
        , Html.Attributes.style "margin" "0"
        , Html.Attributes.style "display" "inline-block"
        ]
        [ Svg.svg
            [ Svg.Attributes.width (String.fromFloat width)
            , Svg.Attributes.height (String.fromFloat height)
            , Html.Attributes.style "display" "block"
            ]
            [ Defs.toSvgElement defs, rootSvgElement ]
        ]


empty : Element msg
empty =
    Element.Empty


lineSegment : LineSegment2d -> Element msg
lineSegment =
    lineSegmentWith []


lineSegmentWith : List (Attribute msg) -> LineSegment2d -> Element msg
lineSegmentWith attributes givenLineSegment =
    Element.LineSegment attributes givenLineSegment


triangle : Triangle2d -> Element msg
triangle =
    triangleWith []


triangleWith : List (Attribute msg) -> Triangle2d -> Element msg
triangleWith attributes givenTriangle =
    Element.Triangle attributes givenTriangle


group : List (Element msg) -> Element msg
group =
    groupWith []


groupWith : List (Attribute msg) -> List (Element msg) -> Element msg
groupWith attributes elements =
    Element.Group attributes elements


placeIn : Frame2d -> Element msg -> Element msg
placeIn frame element =
    Element.PlaceIn frame element


relativeTo : Frame2d -> Element msg -> Element msg
relativeTo frame element =
    placeIn (Frame2d.relativeTo frame Frame2d.xy) element


dot : Point2d -> Element msg
dot =
    dotWith []


dotWith : List (Attribute msg) -> Point2d -> Element msg
dotWith attributes point =
    Element.Dot attributes point


dots : List Point2d -> Element msg
dots =
    dotsWith []


dotsWith : List (Attribute msg) -> List Point2d -> Element msg
dotsWith attributes points =
    groupWith attributes (List.map dot points)


translateBy : Vector2d -> Element msg -> Element msg
translateBy displacement element =
    placeIn (Frame2d.translateBy displacement Frame2d.xy) element


translateIn : Direction2d -> Float -> Element msg -> Element msg
translateIn direction distance element =
    translateBy (Vector2d.withLength distance direction) element


rotateAround : Point2d -> Float -> Element msg -> Element msg
rotateAround point angle element =
    placeIn (Frame2d.rotateAround point angle Frame2d.xy) element


mirrorAcross : Axis2d -> Element msg -> Element msg
mirrorAcross axis element =
    placeIn (Frame2d.mirrorAcross axis Frame2d.xy) element


arc : Arc2d -> Element msg
arc =
    arcWith []


arcWith : List (Attribute msg) -> Arc2d -> Element msg
arcWith attributes givenArc =
    Element.Arc attributes givenArc


quadraticSpline : QuadraticSpline2d -> Element msg
quadraticSpline =
    quadraticSplineWith []


quadraticSplineWith : List (Attribute msg) -> QuadraticSpline2d -> Element msg
quadraticSplineWith attributes givenSpline =
    Element.QuadraticSpline attributes givenSpline


cubicSpline : CubicSpline2d -> Element msg
cubicSpline =
    cubicSplineWith []


cubicSplineWith : List (Attribute msg) -> CubicSpline2d -> Element msg
cubicSplineWith attributes givenSpline =
    Element.CubicSpline attributes givenSpline


polyline : Polyline2d -> Element msg
polyline =
    polylineWith []


polylineWith : List (Attribute msg) -> Polyline2d -> Element msg
polylineWith attributes givenPolyline =
    Element.Polyline attributes givenPolyline


polygon : Polygon2d -> Element msg
polygon =
    polygonWith []


polygonWith : List (Attribute msg) -> Polygon2d -> Element msg
polygonWith attributes givenPolygon =
    Element.Polygon attributes givenPolygon


circle : Circle2d -> Element msg
circle =
    circleWith []


circleWith : List (Attribute msg) -> Circle2d -> Element msg
circleWith attributes givenCircle =
    Element.Circle attributes givenCircle


ellipticalArc : EllipticalArc2d -> Element msg
ellipticalArc =
    ellipticalArcWith []


ellipticalArcWith : List (Attribute msg) -> EllipticalArc2d -> Element msg
ellipticalArcWith attributes givenArc =
    Element.EllipticalArc attributes givenArc


ellipse : Ellipse2d -> Element msg
ellipse =
    ellipseWith []


ellipseWith : List (Attribute msg) -> Ellipse2d -> Element msg
ellipseWith attributes givenEllipse =
    Element.Ellipse attributes givenEllipse


rectangle : Rectangle2d -> Element msg
rectangle =
    rectangleWith []


rectangleWith : List (Attribute msg) -> Rectangle2d -> Element msg
rectangleWith attributes givenRectangle =
    polygonWith attributes (Rectangle2d.toPolygon givenRectangle)


roundedRectangle : Float -> Rectangle2d -> Element msg
roundedRectangle =
    roundedRectangleWith []


roundedRectangleWith : List (Attribute msg) -> Float -> Rectangle2d -> Element msg
roundedRectangleWith attributes radius givenRectangle =
    Element.RoundedRectangle attributes radius givenRectangle


text : Point2d -> String -> Element msg
text =
    textWith []


textWith : List (Attribute msg) -> Point2d -> String -> Element msg
textWith attributes point string =
    Element.Text attributes point string


image : String -> Rectangle2d -> Element msg
image url givenRectangle =
    Element.Image url givenRectangle


map : (a -> b) -> Element a -> Element b
map =
    Element.map
