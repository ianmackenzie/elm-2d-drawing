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

        text attributes position string =
            Drawing2d.group []
                [ Drawing2d.text attributes position string
                , dot position
                ]
    in
    Drawing2d.draw
        { viewBox = viewBox
        , entities =
            [ Drawing2d.group
                [ Drawing2d.fillColor Color.orange
                , Drawing2d.strokeColor Color.blue
                , Drawing2d.fontSize (Pixels.float 20)
                ]
                [ Drawing2d.group [ Drawing2d.strokeWidth (pixels 2) ]
                    (List.map (Drawing2d.lineSegment []) [ lineSegment, mirroredSegment ])
                , Drawing2d.group
                    [ Drawing2d.whiteFill, Drawing2d.blackStroke ]
                    (List.map dot arcPoints)
                , dot (Arc2d.centerPoint arc)
                , Drawing2d.group []
                    [ text [ Drawing2d.anchorAtStart, Drawing2d.hangingBaseline ] (Point2d.pixels 300 200) "top left"
                    , text [ Drawing2d.anchorAtMiddle, Drawing2d.hangingBaseline ] (Point2d.pixels 500 200) "top center"
                    , text [ Drawing2d.anchorAtEnd, Drawing2d.hangingBaseline ] (Point2d.pixels 700 200) "top right"
                    , text [ Drawing2d.anchorAtStart, Drawing2d.middleBaseline ] (Point2d.pixels 300 150) "center left"
                    , text [ Drawing2d.anchorAtMiddle, Drawing2d.middleBaseline, Drawing2d.boldFont ] (Point2d.pixels 500 150) "center"
                    , text [ Drawing2d.anchorAtEnd, Drawing2d.middleBaseline ] (Point2d.pixels 700 150) "center right"
                    , text [ Drawing2d.anchorAtStart, Drawing2d.alphabeticBaseline ] (Point2d.pixels 300 100) "bottom left"
                    , text [ Drawing2d.anchorAtMiddle, Drawing2d.alphabeticBaseline ] (Point2d.pixels 500 100) "bottom center"
                    , text [ Drawing2d.anchorAtEnd, Drawing2d.alphabeticBaseline ] (Point2d.pixels 700 100) "bottom right"
                    ]
                ]
            ]
        }
