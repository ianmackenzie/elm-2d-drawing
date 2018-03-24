module Example exposing (..)

import Arc2d
import Axis2d
import BoundingBox2d
import Color
import Direction2d
import Drawing2d
import Drawing2d.Attributes as Attributes
import Geometry.Parameter as Parameter
import Html exposing (Html)
import LineSegment2d
import Point2d
import Vector2d


main : Html Never
main =
    let
        renderBounds =
            BoundingBox2d.fromExtrema
                { minX = 0
                , maxX = 800
                , minY = 0
                , maxY = 800
                }

        lineSegment =
            LineSegment2d.fromEndpoints
                ( Point2d.fromCoordinates ( 100, 600 )
                , Point2d.fromCoordinates ( 400, 700 )
                )

        mirrorAxis =
            Axis2d.through (Point2d.fromCoordinates ( 100, 550 )) Direction2d.x

        mirroredSegment =
            lineSegment |> LineSegment2d.mirrorAcross mirrorAxis

        arc =
            Arc2d.from
                (LineSegment2d.endPoint mirroredSegment)
                (LineSegment2d.endPoint lineSegment)
                (degrees 90)

        arcPoints =
            List.map (Arc2d.pointOn arc)
                (Parameter.values (Parameter.numSteps 16))
    in
    Drawing2d.toHtml renderBounds
        [ Attributes.dotRadius 5
        , Attributes.fillColor Color.orange
        , Attributes.strokeColor Color.blue
        ]
        [ Drawing2d.dot (Point2d.fromCoordinates ( 100, 100 ))
        , Drawing2d.dotWith
            [ Attributes.dotRadius 8, Attributes.fillColor Color.green ]
            (Point2d.fromCoordinates ( 700, 500 ))
        , Drawing2d.lineSegment lineSegment
        , Drawing2d.lineSegment mirroredSegment
        , Drawing2d.groupWith
            [ Attributes.whiteFill, Attributes.blackStroke ]
            (List.map Drawing2d.dot arcPoints)
        , Drawing2d.dotWith
            [ Attributes.blackFill, Attributes.dotRadius 3 ]
            (Arc2d.centerPoint arc)
        ]
