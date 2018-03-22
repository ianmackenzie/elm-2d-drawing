module Drawing2d.Dot exposing (radius)

import Drawing2d.Internal as Internal exposing (Attribute)


radius : Float -> Attribute msg
radius radius_ =
    Internal.DotRadius radius_
