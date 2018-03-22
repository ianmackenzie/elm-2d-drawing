module Drawing2d.Fill exposing (color, none)

import Color exposing (Color)
import Drawing2d.Internal as Internal exposing (Attribute)


color : Color -> Attribute msg
color color_ =
    Internal.FillStyle (Internal.FillColor color_)


none : Attribute msg
none =
    Internal.FillStyle Internal.NoFill
