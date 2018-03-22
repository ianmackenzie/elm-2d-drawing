module Example exposing (..)

import Axis2d
import BoundingBox2d
import Color
import Direction2d
import Drawing2d
import Drawing2d.Arrow as Arrow
import Drawing2d.Dot as Dot
import Drawing2d.Fill as Fill
import Drawing2d.Stroke as Stroke
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
            Drawing2d.lineSegment [] <|
                LineSegment2d.fromEndpoints
                    ( Point2d.fromCoordinates ( 100, 600 )
                    , Point2d.fromCoordinates ( 400, 700 )
                    )

        mirroredSegment =
            lineSegment
                |> Drawing2d.mirrorAcross
                    (Axis2d.withDirection Direction2d.x
                        (Point2d.fromCoordinates ( 100, 550 ))
                    )
    in
    Drawing2d.toHtml renderBounds
        [ Dot.radius 5
        , Fill.color Color.orange
        , Stroke.color Color.blue
        , Arrow.triangularTip { length = 9, width = 9 }
        ]
        [ Drawing2d.dot [] (Point2d.fromCoordinates ( 100, 100 ))
        , Drawing2d.arrow []
            (Point2d.fromCoordinates ( 200, 200 ))
            (Vector2d.fromComponents ( 200, 50 ))
        , Drawing2d.dot [ Dot.radius 8, Fill.color Color.green ]
            (Point2d.fromCoordinates ( 700, 500 ))
        , lineSegment
        , mirroredSegment
        ]
