module Drawing2d.Attributes exposing
    ( noFill, blackFill, whiteFill, fillColor, fillGradient
    , strokeWidth, blackStroke, whiteStroke, strokeColor, strokeGradient
    , noBorder, strokedBorder
    , fontSize, blackText, whiteText, textColor, fontFamily, textAnchor
    )

{-|


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
import Drawing2d.Attributes.Protected as Protected exposing (AttributeIn(..), Fill(..), Stroke(..))
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


fillColor : Color -> AttributeIn units coordinates drawingCoordinates msg
fillColor color =
    FillStyle (FillColor (Color.toCssString color))


noFill : AttributeIn units coordinates drawingCoordinates msg
noFill =
    FillStyle (FillColor "none")


blackFill : AttributeIn units coordinates drawingCoordinates msg
blackFill =
    FillStyle (FillColor "black")


whiteFill : AttributeIn units coordinates drawingCoordinates msg
whiteFill =
    FillStyle (FillColor "white")


fillGradient : Gradient units coordinates -> AttributeIn units coordinates drawingCoordinates msg
fillGradient gradient =
    FillStyle (FillGradient gradient)


strokeColor : Color -> AttributeIn units coordinates drawingCoordinates msg
strokeColor color =
    StrokeStyle (StrokeColor (Color.toCssString color))


blackStroke : AttributeIn units coordinates drawingCoordinates msg
blackStroke =
    StrokeStyle (StrokeColor "black")


whiteStroke : AttributeIn units coordinates drawingCoordinates msg
whiteStroke =
    StrokeStyle (StrokeColor "white")


strokeGradient : Gradient units coordinates -> AttributeIn units coordinates drawingCoordinates msg
strokeGradient gradient =
    StrokeStyle (StrokeGradient gradient)


noBorder : AttributeIn units coordinates drawingCoordinates msg
noBorder =
    BorderVisibility False


strokedBorder : AttributeIn units coordinates drawingCoordinates msg
strokedBorder =
    BorderVisibility True


strokeWidth : Quantity Float units -> AttributeIn units coordinates drawingCoordinates msg
strokeWidth (Quantity size) =
    StrokeWidth size


textAnchor : Text.Anchor -> AttributeIn units coordinates drawingCoordinates msg
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


blackText : AttributeIn units coordinates drawingCoordinates msg
blackText =
    TextColor "black"


whiteText : AttributeIn units coordinates drawingCoordinates msg
whiteText =
    TextColor "white"


textColor : Color -> AttributeIn units coordinates drawingCoordinates msg
textColor color =
    TextColor (Color.toCssString color)


fontSize : Quantity Float units -> AttributeIn units coordinates drawingCoordinates msg
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


fontFamily : List String -> AttributeIn units coordinates drawingCoordinates msg
fontFamily fonts =
    FontFamily (fonts |> List.map normalizeFont |> String.join ",")
