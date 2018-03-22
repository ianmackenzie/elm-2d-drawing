module Drawing2d.Arrow exposing (triangularTip)

import Drawing2d.Internal as Internal exposing (Attribute)


triangularTip : { length : Float, width : Float } -> Attribute msg
triangularTip properties =
    Internal.ArrowTipStyle (Internal.TriangularTip properties)
