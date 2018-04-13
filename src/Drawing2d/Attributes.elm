module Drawing2d.Attributes
    exposing
        ( blackFill
        , blackStroke
        , dotRadius
        , fillColor
        , noFill
        , noStroke
        , onClick
        , onMouseDown
        , strokeColor
        , strokeWidth
        , textAnchor
        , whiteFill
        , whiteStroke
        )

import Color exposing (Color)
import Drawing2d.Internal as Internal exposing (Attribute)
import Drawing2d.Text as Text
import Mouse


dotRadius : Float -> Attribute msg
dotRadius radius =
    Internal.DotRadius radius


fillColor : Color -> Attribute msg
fillColor color =
    Internal.FillStyle (Internal.FillColor color)


noFill : Attribute msg
noFill =
    Internal.FillStyle Internal.NoFill


blackFill : Attribute msg
blackFill =
    Internal.FillStyle (Internal.FillColor Color.black)


whiteFill : Attribute msg
whiteFill =
    Internal.FillStyle (Internal.FillColor Color.white)


strokeColor : Color -> Attribute msg
strokeColor color =
    Internal.StrokeStyle (Internal.StrokeColor color)


noStroke : Attribute msg
noStroke =
    Internal.StrokeStyle Internal.NoStroke


blackStroke : Attribute msg
blackStroke =
    Internal.StrokeStyle (Internal.StrokeColor Color.black)


whiteStroke : Attribute msg
whiteStroke =
    Internal.StrokeStyle (Internal.StrokeColor Color.white)


strokeWidth : Float -> Attribute msg
strokeWidth width =
    Internal.StrokeWidth width


onClick : msg -> Attribute msg
onClick message =
    Internal.OnClick message


onMouseDown : (Mouse.Position -> msg) -> Attribute msg
onMouseDown handler =
    Internal.OnMouseDown handler


textAnchor : Text.Anchor -> Attribute msg
textAnchor anchor =
    Internal.TextAnchor anchor
