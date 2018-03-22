module Drawing2d.Fill exposing (black, color, none, white)

import Color exposing (Color)
import Drawing2d.Internal as Internal exposing (Attribute)


color : Color -> Attribute msg
color color_ =
    Internal.FillStyle (Internal.FillColor color_)


none : Attribute msg
none =
    Internal.FillStyle Internal.NoFill


black : Attribute msg
black =
    Internal.FillStyle (Internal.FillColor Color.black)


white : Attribute msg
white =
    Internal.FillStyle (Internal.FillColor Color.white)
