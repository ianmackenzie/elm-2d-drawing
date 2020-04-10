module Simple exposing (main)

import Color
import Drawing2d
import Html exposing (Html)
import LineSegment2d
import Pixels exposing (Pixels, inPixels, pixels)
import Point2d
import Rectangle2d exposing (Rectangle2d)
import Triangle2d
import Vector2d


main : Html msg
main =
    let
        p1 =
            Point2d.pixels 100 100

        p2 =
            Point2d.pixels 400 400

        p3 =
            Point2d.pixels 400 100

        gradient =
            Drawing2d.gradientFrom ( p1, Color.rgb 0 0 0.75 ) ( p2, Color.rgb 0 0.75 1 )

        elements =
            [ Drawing2d.triangle
                [ Drawing2d.fillGradient gradient
                , Drawing2d.strokeWidth (pixels 4)
                , Drawing2d.dropShadow
                    { radius = pixels 8
                    , offset = Vector2d.pixels 4 -4
                    , color = Color.darkGrey
                    }
                , Drawing2d.roundStrokeJoins
                ]
                (Triangle2d.from p1 p2 p3)
            ]

        viewBox =
            Rectangle2d.from Point2d.origin (Point2d.pixels 500 500)
    in
    Drawing2d.toHtml { viewBox = viewBox, size = Drawing2d.fixed } [] elements
