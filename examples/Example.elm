module Example exposing (main)

import Angle
import Arc2d
import Axis2d
import Color
import Common exposing (dot)
import Direction2d
import Drawing2d
import Html exposing (Html)
import LineSegment2d
import Parameter1d
import Pixels exposing (pixels)
import Point2d
import Rectangle2d


main : Html Never
main =
    let
        viewBox =
            Rectangle2d.from Point2d.origin (Point2d.pixels 800 800)

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
                [ Drawing2d.text [ Drawing2d.textAnchor anchor ]
                    position
                    string
                , dot position
                ]
    in
    Drawing2d.draw
        { viewBox = viewBox
        , attributes =
            [ Drawing2d.fillColor Color.orange
            , Drawing2d.strokeColor Color.blue
            , Drawing2d.fontSize (Pixels.float 20)
            ]
        , elements =
            [ Drawing2d.group [ Drawing2d.strokeWidth (pixels 2) ]
                (List.map (Drawing2d.lineSegment []) [ lineSegment, mirroredSegment ])
            , Drawing2d.group
                [ Drawing2d.whiteFill, Drawing2d.blackStroke ]
                (List.map dot arcPoints)
            , dot (Arc2d.centerPoint arc)
            , Drawing2d.group []
                [ text Drawing2d.topLeft (Point2d.pixels 300 200) "topLeft"
                , text Drawing2d.topCenter (Point2d.pixels 500 200) "topCenter"
                , text Drawing2d.topRight (Point2d.pixels 700 200) "topRight"
                , text Drawing2d.centerLeft (Point2d.pixels 300 150) "centerLeft"
                , text Drawing2d.center (Point2d.pixels 500 150) "center"
                , text Drawing2d.centerRight (Point2d.pixels 700 150) "centerRight"
                , text Drawing2d.bottomLeft (Point2d.pixels 300 100) "bottomLeft"
                , text Drawing2d.bottomCenter (Point2d.pixels 500 100) "bottomCenter"
                , text Drawing2d.bottomRight (Point2d.pixels 700 100) "bottomRight"
                ]
            ]
        }
