module Drawing2d.Attributes exposing
    ( noFill, blackFill, whiteFill, fillColor, fillGradient
    , strokeWidth, blackStroke, whiteStroke, strokeColor, strokeGradient
    , roundJoins, bevelJoins, miterJoins
    , roundCaps, buttCaps, squareCaps
    , noBorder, strokedBorder
    , fontSize, blackText, whiteText, textColor, fontFamily, textAnchor
    )

{-|


# Fill

@docs noFill, blackFill, whiteFill, fillColor, fillGradient


# Stroke

@docs strokeWidth, blackStroke, whiteStroke, strokeColor, strokeGradient


## Line joins

@docs roundJoins, bevelJoins, miterJoins


## Line caps

@docs roundCaps, buttCaps, squareCaps


# Borders

@docs noBorder, strokedBorder


# Text

@docs fontSize, blackText, whiteText, textColor, fontFamily, textAnchor

-}

import Axis2d exposing (Axis2d)
import Color exposing (Color)
import Drawing2d.Attributes.Protected as Protected exposing (Attribute(..), Event(..), Fill(..), LineCap(..), LineJoin(..), Stroke(..))
import Drawing2d.Font as Font
import Drawing2d.Gradient as Gradient exposing (Gradient)
import Drawing2d.Text as Text
import Drawing2d.TextAnchor as TextAnchor
import Html.Events
import Pixels exposing (Pixels, inPixels)
import Point2d exposing (Point2d)
import Quantity exposing (Quantity(..))
import Svg exposing (Svg)
import Svg.Attributes


fillColor : Color -> Attribute units coordinates event
fillColor color =
    FillStyle (FillColor (Color.toCssString color))


noFill : Attribute units coordinates event
noFill =
    FillStyle (FillColor "none")


blackFill : Attribute units coordinates event
blackFill =
    FillStyle (FillColor "black")


whiteFill : Attribute units coordinates event
whiteFill =
    FillStyle (FillColor "white")


fillGradient : Gradient units coordinates -> Attribute units coordinates event
fillGradient gradient =
    FillStyle (FillGradient gradient)


strokeColor : Color -> Attribute units coordinates event
strokeColor color =
    StrokeStyle (StrokeColor (Color.toCssString color))


blackStroke : Attribute units coordinates event
blackStroke =
    StrokeStyle (StrokeColor "black")


whiteStroke : Attribute units coordinates event
whiteStroke =
    StrokeStyle (StrokeColor "white")


strokeGradient : Gradient units coordinates -> Attribute units coordinates event
strokeGradient gradient =
    StrokeStyle (StrokeGradient gradient)


noBorder : Attribute units coordinates event
noBorder =
    BorderVisibility False


strokedBorder : Attribute units coordinates event
strokedBorder =
    BorderVisibility True


strokeWidth : Quantity Float units -> Attribute units coordinates event
strokeWidth (Quantity size) =
    StrokeWidth size


roundJoins : Attribute units coordinates event
roundJoins =
    StrokeLineJoin RoundJoin


bevelJoins : Attribute units coordinates event
bevelJoins =
    StrokeLineJoin BevelJoin


miterJoins : Attribute units coordinates event
miterJoins =
    StrokeLineJoin MiterJoin


roundCaps : Attribute units coordinates event
roundCaps =
    StrokeLineCap RoundCap


buttCaps : Attribute units coordinates event
buttCaps =
    StrokeLineCap ButtCap


squareCaps : Attribute units coordinates event
squareCaps =
    StrokeLineCap SquareCap


textAnchor : Text.Anchor -> Attribute units coordinates event
textAnchor anchor =
    case anchor of
        TextAnchor.TopLeft ->
            TextAnchor { x = "start", y = "hanging" }

        TextAnchor.TopCenter ->
            TextAnchor { x = "middle", y = "hanging" }

        TextAnchor.TopRight ->
            TextAnchor { x = "end", y = "hanging" }

        TextAnchor.CenterLeft ->
            TextAnchor { x = "start", y = "middle" }

        TextAnchor.Center ->
            TextAnchor { x = "middle", y = "middle" }

        TextAnchor.CenterRight ->
            TextAnchor { x = "end", y = "middle" }

        TextAnchor.BottomLeft ->
            TextAnchor { x = "start", y = "alphabetic" }

        TextAnchor.BottomCenter ->
            TextAnchor { x = "middle", y = "alphabetic" }

        TextAnchor.BottomRight ->
            TextAnchor { x = "end", y = "alphabetic" }


blackText : Attribute units coordinates event
blackText =
    TextColor "black"


whiteText : Attribute units coordinates event
whiteText =
    TextColor "white"


textColor : Color -> Attribute units coordinates event
textColor color =
    TextColor (Color.toCssString color)


fontSize : Quantity Float units -> Attribute units coordinates event
fontSize (Quantity size) =
    FontSize size


normalizeFont : String -> String
normalizeFont font =
    if font == Font.serif then
        font

    else if font == Font.sansSerif then
        font

    else if font == Font.monospace then
        font

    else
        "\"" ++ font ++ "\""


fontFamily : List String -> Attribute units coordinates event
fontFamily fonts =
    FontFamily (fonts |> List.map normalizeFont |> String.join ",")
