module PointInterpolation exposing (main)

import Circle2d
import Drawing2d
import Html exposing (Html)
import Parameter1d
import Pixels exposing (pixels)
import Point2d
import Quantity exposing (zero)
import Rectangle2d


main : Html msg
main =
    let
        viewBox =
            Rectangle2d.from Point2d.origin (Point2d.pixels 300 150)

        points =
            Parameter1d.steps 20 <|
                Point2d.interpolateFrom
                    (Point2d.pixels 20 20)
                    (Point2d.pixels 280 130)

        circles =
            List.map (Circle2d.withRadius (pixels 3)) points
    in
    Drawing2d.draw
        { viewBox = viewBox
        , entities = List.map (Drawing2d.circle []) circles
        }
