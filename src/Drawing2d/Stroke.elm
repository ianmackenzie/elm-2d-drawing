module Drawing2d.Stroke exposing (color, none)

import Color exposing (Color)
import Drawing2d.Internal as Internal exposing (Attribute)


color : Color -> Attribute msg
color color_ =
    Internal.StrokeStyle (Internal.StrokeColor color_)


none : Attribute msg
none =
    Internal.StrokeStyle Internal.NoStroke
