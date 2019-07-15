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


type alias Attribute units coordinates =
    Types.Attribute units coordinates


fillColor : Color -> Attribute units coordinates
fillColor color =
    FillStyle (FillColor (Color.toCssString color))


noFill : Attribute units coordinates
noFill =
    FillStyle (FillColor "none")


blackFill : Attribute units coordinates
blackFill =
    FillStyle (FillColor "black")


whiteFill : Attribute units coordinates
whiteFill =
    FillStyle (FillColor "white")


fillGradient : Gradient units coordinates -> Attribute units coordinates
fillGradient gradient =
    FillStyle (FillGradient gradient)


strokeColor : Color -> Attribute units coordinates
strokeColor color =
    StrokeStyle (StrokeColor (Color.toCssString color))


blackStroke : Attribute units coordinates
blackStroke =
    StrokeStyle (StrokeColor "black")


whiteStroke : Attribute units coordinates
whiteStroke =
    StrokeStyle (StrokeColor "white")


strokeGradient : Gradient units coordinates -> Attribute units coordinates
strokeGradient gradient =
    StrokeStyle (StrokeGradient gradient)


noBorder : Attribute units coordinates
noBorder =
    BorderVisibility False


strokedBorder : Attribute units coordinates
strokedBorder =
    BorderVisibility True


strokeWidth : Quantity Float units -> Attribute units coordinates
strokeWidth (Quantity size) =
    StrokeWidth size


textAnchor : Text.Anchor -> Attribute units coordinates
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


blackText : Attribute units coordinates
blackText =
    TextColor "black"


whiteText : Attribute units coordinates
whiteText =
    TextColor "white"


textColor : Color -> Attribute units coordinates
textColor color =
    TextColor (Color.toCssString color)


fontSize : Quantity Float units -> Attribute units coordinates
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


fontFamily : List String -> Attribute units coordinates
fontFamily fonts =
    FontFamily (fonts |> List.map normalizeFont |> String.join ",")
