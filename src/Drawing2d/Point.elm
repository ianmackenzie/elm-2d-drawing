module Drawing2d.Point exposing (radius)

import Drawing2d.Internal as Internal exposing (Attribute)


radius : Float -> Attribute msg
radius radius_ =
    Internal.PointRadius radius_
