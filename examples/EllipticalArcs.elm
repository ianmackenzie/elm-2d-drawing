module EllipticalArcs exposing (main)

import Angle exposing (Angle)
import BoundingBox2d exposing (BoundingBox2d)
import Color
import Common exposing (dot)
import Direction2d exposing (Direction2d)
import Drawing2d
import Drawing2d.Attributes as Attributes
import Drawing2d.Gradient as Gradient
import EllipticalArc2d
import Html exposing (Html)
import Pixels exposing (Pixels, inPixels, pixels)
import Point2d


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
            Gradient.from
                ( startPoint, Color.rgb 0 1 0 )
                ( endPoint, Color.rgb 0 0 1 )

        elements =
            [ Drawing2d.ellipticalArc
                [ Attributes.strokeGradient gradient
                , Attributes.strokeWidth (pixels 8)
                ]
                arc
            , dot centerPoint
            , dot startPoint
            , dot endPoint
            ]

        viewBox =
            BoundingBox2d.fromExtrema
                { minX = pixels 0
                , minY = pixels 0
                , maxX = pixels 600
                , maxY = pixels 600
                }
    in
    Drawing2d.toHtml { viewBox = viewBox, size = Drawing2d.fixed } [] elements
