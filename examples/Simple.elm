module Simple exposing (main)

import BoundingBox2d exposing (BoundingBox2d)
import Color
import Drawing2d
import Drawing2d.Attributes as Attributes
import Drawing2d.Gradient as Gradient
import Html exposing (Html)
import LineSegment2d
import Pixels exposing (Pixels, inPixels, pixels)
import Point2d
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
            Gradient.from ( p1, Color.rgb 0 0 0.75 ) ( p2, Color.rgb 0 0.75 1 )

        elements =
            [ Drawing2d.triangle
                [ Attributes.fillGradient gradient
                , Attributes.strokeWidth (pixels 4)
                , Attributes.dropShadow
                    { radius = pixels 8
                    , offset = Vector2d.pixels 4 -4
                    , color = Color.darkGrey
                    }
                , Attributes.roundJoins
                ]
                (Triangle2d.from p1 p2 p3)
            ]

        viewBox =
            BoundingBox2d.fromExtrema
                { minX = pixels 0
                , minY = pixels 0
                , maxX = pixels 500
                , maxY = pixels 500
                }
    in
    Drawing2d.toHtml { viewBox = viewBox, size = Drawing2d.fixed } [] elements
