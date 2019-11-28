module PointInterpolation exposing (main)

import BoundingBox2d
import Circle2d
import Drawing2d
import Html exposing (Html)
import Parameter1d
import Pixels exposing (pixels)
import Point2d
import Quantity exposing (zero)


main : Html msg
main =
    let
        viewBox =
            BoundingBox2d.from (Point2d.pixels 0 0) (Point2d.pixels 300 150)

        points =
            Parameter1d.steps 20 <|
                Point2d.interpolateFrom
                    (Point2d.pixels 20 20)
                    (Point2d.pixels 280 130)

        circles =
            List.map (Circle2d.withRadius (pixels 3)) points
    in
    Drawing2d.toHtml { viewBox = viewBox, size = Drawing2d.fixed } [] <|
        List.map (Drawing2d.circle []) circles
