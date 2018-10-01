module Example exposing (main)

import Arc2d
import Axis2d
import BoundingBox2d
import Color
import Curve.ParameterValue as ParameterValue
import Direction2d
import Drawing2d
import Drawing2d.Attributes as Attributes
import Drawing2d.Text as Text
import Html exposing (Html)
import LineSegment2d
import Point2d


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
            arc |> Arc2d.pointsAt (ParameterValue.steps 16)

        text anchor coordinates string =
            let
                point =
                    Point2d.fromCoordinates coordinates
            in
            Drawing2d.group
                [ Drawing2d.textWith
                    [ Attributes.textAnchor anchor ]
                    point
                    string
                , Drawing2d.dotWith
                    [ Attributes.dotRadius 2
                    , Attributes.blackFill
                    , Attributes.noBorder
                    ]
                    point
                ]
    in
    Drawing2d.toHtml renderBounds
        [ Attributes.dotRadius 5
        , Attributes.fillColor Color.orange
        , Attributes.strokeColor Color.blue
        ]
        [ Drawing2d.dot
            (Point2d.fromCoordinates ( 100, 100 ))
        , Drawing2d.dotWith
            [ Attributes.dotRadius 8, Attributes.fillColor Color.green ]
            (Point2d.fromCoordinates ( 700, 500 ))
        , Drawing2d.groupWith
            [ Attributes.strokeWidth 2 ]
            (List.map Drawing2d.lineSegment [ lineSegment, mirroredSegment ])
        , Drawing2d.dotsWith
            [ Attributes.whiteFill, Attributes.blackStroke ]
            arcPoints
        , Drawing2d.dotWith
            [ Attributes.blackFill, Attributes.dotRadius 3 ]
            (Arc2d.centerPoint arc)
        , Drawing2d.group
            [ text Text.topLeft ( 300, 200 ) "topLeft"
            , text Text.topCenter ( 500, 200 ) "topCenter"
            , text Text.topRight ( 700, 200 ) "topRight"
            , text Text.centerLeft ( 300, 150 ) "centerLeft"
            , text Text.center ( 500, 150 ) "center"
            , text Text.centerRight ( 700, 150 ) "centerRight"
            , text Text.bottomLeft ( 300, 100 ) "bottomLeft"
            , text Text.bottomCenter ( 500, 100 ) "bottomCenter"
            , text Text.bottomRight ( 700, 100 ) "bottomRight"
            ]
        ]
