module EllipticalArcs exposing (main)

import Angle exposing (Angle)
import Color
import Common exposing (dot)
import Direction2d exposing (Direction2d)
import Drawing2d
import EllipticalArc2d
import Html exposing (Html)
import Pixels exposing (Pixels, inPixels, pixels)
import Point2d
import Rectangle2d exposing (Rectangle2d)


degrees : Float -> Angle
degrees =
    Angle.degrees


main : Html msg
main =
    let
        centerPoint =
            Point2d.pixels 300 300

        arc =
            EllipticalArc2d.with
                { centerPoint = centerPoint
                , xDirection = Direction2d.fromAngle (degrees 45)
                , xRadius = pixels 100
                , yRadius = pixels 50
                , startAngle = degrees 45
                , sweptAngle = degrees -270
                }

        startPoint =
            EllipticalArc2d.startPoint arc

        endPoint =
            EllipticalArc2d.endPoint arc

        gradient =
            Drawing2d.gradientFrom
                ( startPoint, Color.rgb 0 1 0 )
                ( endPoint, Color.rgb 0 0 1 )
    in
    Drawing2d.draw
        { viewBox = Rectangle2d.from Point2d.origin (Point2d.pixels 600 600)
        , background = Drawing2d.noBackground
        , attributes = []
        , entities =
            [ Drawing2d.ellipticalArc
                [ Drawing2d.strokeGradient gradient
                , Drawing2d.strokeWidth (pixels 8)
                ]
                arc
            , dot centerPoint
            , dot startPoint
            , dot endPoint
            ]
        }
