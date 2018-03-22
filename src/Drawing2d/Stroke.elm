module Drawing2d.Stroke exposing (black, color, none, white)

import Color exposing (Color)
import Drawing2d.Internal as Internal exposing (Attribute)


color : Color -> Attribute msg
color color_ =
    Internal.StrokeStyle (Internal.StrokeColor color_)


none : Attribute msg
none =
    Internal.StrokeStyle Internal.NoStroke


black : Attribute msg
black =
    Internal.StrokeStyle (Internal.StrokeColor Color.black)


white : Attribute msg
white =
    Internal.StrokeStyle (Internal.StrokeColor Color.white)
