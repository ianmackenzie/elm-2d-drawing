module Common exposing (dot)

import Circle2d
import Color
import Drawing2d
import Drawing2d.Attributes as Attributes
import Pixels exposing (Pixels, pixels)
import Point2d exposing (Point2d)


dot : Point2d Pixels drawingCoordinates -> Drawing2d.Element drawingCoordinates msg
dot point =
    Drawing2d.circle
        [ Attributes.blackStroke
        , Attributes.whiteFill
        , Attributes.strokeWidth (pixels 1)
        ]
        (Circle2d.withRadius (pixels 4) point)
