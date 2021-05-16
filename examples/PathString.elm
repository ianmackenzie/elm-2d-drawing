module PathString exposing (main)

import Angle
import Axis2d
import Circle2d
import Color
import Drawing2d
import Html exposing (Html)
import Pixels
import Point2d
import Rectangle2d


main : Html Never
main =
    Drawing2d.draw
        { viewBox = Rectangle2d.from Point2d.origin (Point2d.pixels 600 600)
        , entities =
            [ Drawing2d.group
                [ Drawing2d.fillGradient <|
                    Drawing2d.gradientAlong Axis2d.x
                        [ ( Pixels.float 300, Color.lightBlue )
                        , ( Pixels.float 400, Color.green )
                        ]
                ]
                [ Drawing2d.unsafeRegion [] "M 100 300 H 500 V 600 Z"
                    |> Drawing2d.rotateAround (Point2d.pixels 100 300) (Angle.degrees -30)
                ]
            , Drawing2d.circle [ Drawing2d.whiteFill ] <|
                Circle2d.atPoint (Point2d.pixels 100 300) (Pixels.float 5)
            ]
        }
