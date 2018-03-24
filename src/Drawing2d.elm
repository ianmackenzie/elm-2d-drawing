module Drawing2d
    exposing
        ( Attribute
        , Element
        , arrow
        , arrowWith
          --, circle
          --, cubicSpline
          --, ellipse
          --, ellipticalArc
        , dot
        , dotWith
          --, polygon
          --, polyline
          --, quadraticSpline
        , empty
          --, arc
        , group
        , groupWith
        , lineSegment
        , lineSegmentWith
        , mirrorAcross
        , placeIn
        , relativeTo
          --, scaleAbout
          --, text
        , toHtml
          --, translateBy
        , triangle
        , triangleWith
        )

import Axis2d exposing (Axis2d)
import BoundingBox2d exposing (BoundingBox2d)
import Circle2d exposing (Circle2d)
import Drawing2d.Internal as Internal exposing (applyAttributes, defaultContext, svgAttributes)
import Frame2d exposing (Frame2d)
import Geometry.Svg as Svg
import Html exposing (Html)
import Html.Attributes
import LineSegment2d exposing (LineSegment2d)
import Point2d exposing (Point2d)
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


mirrorAcross : Axis2d -> Element msg -> Element msg
mirrorAcross axis element =
    placeIn (Frame2d.mirrorAcross axis Frame2d.xy) element
