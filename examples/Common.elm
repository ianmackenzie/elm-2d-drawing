module Common exposing (dot)

import Circle2d
import Color
import Drawing2d
import Pixels exposing (Pixels, pixels)
import Point2d exposing (Point2d)


dot : Point2d Pixels coordinates -> Drawing2d.Entity Pixels coordinates msg
dot point =
    Drawing2d.circle
        [ Drawing2d.blackStroke
        , Drawing2d.whiteFill
        , Drawing2d.strokeWidth (pixels 1)
        ]
        (Circle2d.withRadius (pixels 4) point)
