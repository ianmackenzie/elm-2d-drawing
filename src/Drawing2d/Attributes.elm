module Drawing2d.Attributes exposing
    ( Attribute
    , noFill, blackFill, whiteFill, fillColor, fillGradient
    , strokeWidth, blackStroke, whiteStroke, strokeColor, strokeGradient
    , noBorder, strokedBorder
    , fontSize, blackText, whiteText, textColor, fontFamily, textAnchor
    )

{-|

@docs Attribute


# Fill

@docs noFill, blackFill, whiteFill, fillColor, fillGradient


# Stroke

@docs strokeWidth, blackStroke, whiteStroke, strokeColor, strokeGradient


# Borders

@docs noBorder, strokedBorder


# Text

@docs fontSize, blackText, whiteText, textColor, fontFamily, textAnchor

-}

import Axis2d exposing (Axis2d)
import Color exposing (Color)
import Drawing2d.Font as Font
import Drawing2d.Gradient as Gradient exposing (Gradient)
import Drawing2d.Text as Text
import Drawing2d.TextAnchor as TextAnchor
import Drawing2d.Types as Types exposing (Attribute(..), Fill(..), Stroke(..))
import Html.Events
import Pixels exposing (Pixels, inPixels)
import Point2d exposing (Point2d)
import Quantity exposing (Quantity(..))
import Svg exposing (Svg)
import Svg.Attributes


type alias Attribute units coordinates msg =
    Types.Attribute units coordinates msg


fillColor : Color -> Attribute units coordinates msg
fillColor color =
    FillStyle (FillColor (Color.toCssString color))


noFill : Attribute units coordinates msg
noFill =
    FillStyle (FillColor "none")


blackFill : Attribute units coordinates msg
blackFill =
    FillStyle (FillColor "black")


whiteFill : Attribute units coordinates msg
whiteFill =
    FillStyle (FillColor "white")


fillGradient : Gradient units coordinates -> Attribute units coordinates msg
fillGradient gradient =
    FillStyle (FillGradient gradient)


strokeColor : Color -> Attribute units coordinates msg
strokeColor color =
    StrokeStyle (StrokeColor (Color.toCssString color))


blackStroke : Attribute units coordinates msg
blackStroke =
    StrokeStyle (StrokeColor "black")


whiteStroke : Attribute units coordinates msg
whiteStroke =
    StrokeStyle (StrokeColor "white")


strokeGradient : Gradient units coordinates -> Attribute units coordinates msg
strokeGradient gradient =
    StrokeStyle (StrokeGradient gradient)


noBorder : Attribute units coordinates msg
noBorder =
    BorderVisibility False


strokedBorder : Attribute units coordinates msg
strokedBorder =
    BorderVisibility True


strokeWidth : Quantity Float units -> Attribute units coordinates msg
strokeWidth (Quantity size) =
    StrokeWidth size


textAnchor : Text.Anchor -> Attribute units coordinates msg
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


blackText : Attribute units coordinates msg
blackText =
    TextColor "black"


whiteText : Attribute units coordinates msg
whiteText =
    TextColor "white"


textColor : Color -> Attribute units coordinates msg
textColor color =
    TextColor (Color.toCssString color)


fontSize : Quantity Float units -> Attribute units coordinates msg
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


fontFamily : List String -> Attribute units coordinates msg
fontFamily fonts =
    FontFamily (fonts |> List.map normalizeFont |> String.join ",")
