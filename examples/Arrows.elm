module Arrows exposing (main)

import Angle exposing (Angle)
import Color
import Drawing2d
import Html exposing (Html)
import Parameter1d
import Pixels exposing (Pixels)
import Point2d
import Quantity
import Rectangle2d


main : Html Never
main =
    Drawing2d.draw
        { viewBox = Rectangle2d.from (Point2d.pixels -100 -100) (Point2d.pixels 400 400)
        , entities =
            List.map drawArrow <|
                Parameter1d.steps 6 (Quantity.interpolateFrom Quantity.zero (Angle.degrees 90))
        }


drawArrow : Angle -> Drawing2d.Entity Pixels coordinates Never
drawArrow angle =
    Drawing2d.arrow
        [ Drawing2d.strokeColor Color.darkBlue
        , Drawing2d.fillColor Color.orange
        , Drawing2d.strokeWidth (Pixels.float 2)
        ]
        { base = Point2d.origin
        , tip = Point2d.rTheta (Pixels.float 300) angle
        , headWidth = Pixels.float 20
        , headLength = Pixels.float 30
        }
