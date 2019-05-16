module Drawing2d.Attributes exposing
    ( blackFill
    , blackStroke
    , blackText
    , borderPosition
    , dotRadius
    , fillColor
    , fontFamily
    , fontSize
    , gradientFillAlong
    , gradientFillFrom
    , map
    , noBorder
    , noFill
    , onClick
    , onMouseDown
    , strokeColor
    , strokeWidth
    , strokedBorder
    , textAnchor
    , textColor
    , whiteFill
    , whiteStroke
    , whiteText
    )

import Axis2d exposing (Axis2d)
import Color exposing (Color)
import Drawing2d.Attribute as Attribute
import Drawing2d.Border as Border exposing (BorderPosition)
import Drawing2d.LinearGradient as LinearGradient
import Drawing2d.Text as Text
import Html.Events.Extra.Mouse as Mouse
import Point2d exposing (Point2d)


type alias Attribute units coordinates msg =
    Attribute.Attribute units coordinates msg


dotRadius : Float -> Attribute msg
dotRadius radius =
    Attribute.DotRadius radius


fillColor : Color -> Attribute msg
fillColor color =
    Attribute.FillStyle (Attribute.FillColor color)


noFill : Attribute msg
noFill =
    Attribute.FillStyle Attribute.NoFill


blackFill : Attribute msg
blackFill =
    fillColor Color.black


whiteFill : Attribute msg
whiteFill =
    fillColor Color.white


gradientFillAlong : Axis2d -> List ( Float, Color ) -> Attribute msg
gradientFillAlong axis distanceStops =
    Attribute.FillStyle <|
        Attribute.LinearGradientFill <|
            LinearGradient.along axis distanceStops


gradientFillFrom : ( Point2d, Color ) -> ( Point2d, Color ) -> Attribute msg
gradientFillFrom start end =
    Attribute.FillStyle <|
        Attribute.LinearGradientFill <|
            LinearGradient.from start end


strokeColor : Color -> Attribute msg
strokeColor color =
    Attribute.StrokeColor color


noBorder : Attribute msg
noBorder =
    Attribute.BordersEnabled False


strokedBorder : Attribute msg
strokedBorder =
    Attribute.BordersEnabled True


borderPosition : BorderPosition -> Attribute msg
borderPosition position =
    Attribute.BorderPosition position


blackStroke : Attribute msg
blackStroke =
    strokeColor Color.black


whiteStroke : Attribute msg
whiteStroke =
    strokeColor Color.white


strokeWidth : Float -> Attribute msg
strokeWidth width =
    Attribute.StrokeWidth width


onClick : msg -> Attribute msg
onClick message =
    Attribute.OnClick message


onMouseDown : (Mouse.Position -> msg) -> Attribute msg
onMouseDown handler =
    Attribute.OnMouseDown handler


textAnchor : Text.Anchor -> Attribute msg
textAnchor anchor =
    Attribute.TextAnchor anchor


blackText : Attribute msg
blackText =
    textColor Color.black


whiteText : Attribute msg
whiteText =
    textColor Color.white


textColor : Color -> Attribute msg
textColor color =
    Attribute.TextColor color


fontSize : Int -> Attribute msg
fontSize px =
    Attribute.FontSize px


fontFamily : List String -> Attribute msg
fontFamily fonts =
    Attribute.FontFamily fonts


map : (a -> b) -> Attribute a -> Attribute b
map =
    Attribute.map
