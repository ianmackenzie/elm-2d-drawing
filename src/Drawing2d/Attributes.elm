module Drawing2d.Attributes
    exposing
        ( blackFill
        , blackStroke
        , dotRadius
        , fillColor
        , fontFamily
        , fontSize
        , linearGradientFill
        , map
        , noFill
        , noStroke
        , onClick
        , onMouseDown
        , strokeColor
        , strokeWidth
        , textAnchor
        , textColor
        , whiteFill
        , whiteStroke
        )

import Color exposing (Color)
import Drawing2d.Attribute as Attribute
import Drawing2d.Text as Text
import LineSegment2d exposing (LineSegment2d)
import Mouse


type alias Attribute msg =
    Attribute.Attribute msg


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
    Attribute.FillStyle (Attribute.FillColor Color.black)


whiteFill : Attribute msg
whiteFill =
    Attribute.FillStyle (Attribute.FillColor Color.white)


linearGradientFill : LineSegment2d -> List ( Float, Color ) -> Attribute msg
linearGradientFill lineSegment stops =
    Attribute.FillStyle (Attribute.LinearGradientFill lineSegment stops)


strokeColor : Color -> Attribute msg
strokeColor color =
    Attribute.StrokeStyle (Attribute.StrokeColor color)


noStroke : Attribute msg
noStroke =
    Attribute.StrokeStyle Attribute.NoStroke


blackStroke : Attribute msg
blackStroke =
    Attribute.StrokeStyle (Attribute.StrokeColor Color.black)


whiteStroke : Attribute msg
whiteStroke =
    Attribute.StrokeStyle (Attribute.StrokeColor Color.white)


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
