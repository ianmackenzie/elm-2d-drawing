module HatchPattern exposing (main)

import Angle
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

        hatchFill =
            Drawing2d.hatchFill
                { origin = p3
                , angle = Angle.degrees 135
                , strokeColor = Color.charcoal
                , fillColor = Just Color.lightGrey
                , strokeWidth = Pixels.float 0.5
                , dashPattern = [ Pixels.float 16, Pixels.float 4 ]
                , spacing = Pixels.float 12
                }
    in
    Drawing2d.draw
        { viewBox = Rectangle2d.from Point2d.origin (Point2d.pixels 500 500)
        , entities =
            [ Drawing2d.triangle
                [ hatchFill
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
        }
