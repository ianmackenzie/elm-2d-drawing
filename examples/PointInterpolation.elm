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
        renderBounds =
            BoundingBox2d.fromExtrema
                { minX = zero
                , maxX = pixels 300
                , minY = zero
                , maxY = pixels 150
                }

        points =
            Parameter1d.steps 20 <|
                Point2d.interpolateFrom
                    (Point2d.pixels 20 20)
                    (Point2d.pixels 280 130)

        circles =
            List.map (Circle2d.withRadius (pixels 3)) points
    in
    Drawing2d.toHtml renderBounds [] (List.map (Drawing2d.circle []) circles)