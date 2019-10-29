module Example exposing (main)

import Angle
import Arc2d
import Axis2d
import BoundingBox2d
import Color
import Common exposing (dot)
import Direction2d
import Drawing2d
import Drawing2d.Attributes as Attributes
import Drawing2d.Text as Text
import Html exposing (Html)
import LineSegment2d
import Parameter1d
import Pixels exposing (pixels)
import Point2d


main : Html Never
main =
    let
        viewBox =
            BoundingBox2d.fromExtrema
                { minX = pixels 0
                , maxX = pixels 800
                , minY = pixels 0
                , maxY = pixels 800
                }

        lineSegment =
            LineSegment2d.fromEndpoints
                ( Point2d.pixels 100 600
                , Point2d.pixels 400 700
                )

        mirrorAxis =
            Axis2d.through (Point2d.pixels 100 550) Direction2d.x

        mirroredSegment =
            lineSegment |> LineSegment2d.mirrorAcross mirrorAxis

        arc =
            Arc2d.from
                (LineSegment2d.endPoint mirroredSegment)
                (LineSegment2d.endPoint lineSegment)
                (Angle.degrees 90)

        arcPoints =
            Parameter1d.steps 16 (Arc2d.pointOn arc)

        text anchor position string =
            Drawing2d.group []
                [ Drawing2d.text [ Attributes.textAnchor anchor ]
                    position
                    string
                , dot position
                ]
    in
    Drawing2d.toHtml { viewBox = viewBox, size = Drawing2d.fixed }
        [ Attributes.fillColor Color.orange
        , Attributes.strokeColor Color.blue
        ]
        [ Drawing2d.group [ Attributes.strokeWidth (pixels 2) ]
            (List.map (Drawing2d.lineSegment []) [ lineSegment, mirroredSegment ])
        , Drawing2d.group
            [ Attributes.whiteFill, Attributes.blackStroke ]
            (List.map dot arcPoints)
        , dot (Arc2d.centerPoint arc)
        , Drawing2d.group []
            [ text Text.topLeft (Point2d.pixels 300 200) "topLeft"
            , text Text.topCenter (Point2d.pixels 500 200) "topCenter"
            , text Text.topRight (Point2d.pixels 700 200) "topRight"
            , text Text.centerLeft (Point2d.pixels 300 150) "centerLeft"
            , text Text.center (Point2d.pixels 500 150) "center"
            , text Text.centerRight (Point2d.pixels 700 150) "centerRight"
            , text Text.bottomLeft (Point2d.pixels 300 100) "bottomLeft"
            , text Text.bottomCenter (Point2d.pixels 500 100) "bottomCenter"
            , text Text.bottomRight (Point2d.pixels 700 100) "bottomRight"
            ]
        ]
