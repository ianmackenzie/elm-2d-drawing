module Drawing2d.Attribute exposing (Attribute, Context, apply, toSvgAttributes)

import Color exposing (Color)
import Drawing2d.Font as Font
import Drawing2d.Internal as Internal
import Html.Events
import Json.Decode as Decode
import Mouse
import Svg
import Svg.Attributes


type alias Attribute msg =
    Internal.Attribute msg


type alias Context =
    Internal.Context


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


colorStrings : Color -> ( String, String )
colorStrings color =
    let
        { red, green, blue, alpha } =
            Color.toRgb color

        rgbString =
            "rgb("
                ++ toString red
                ++ ","
                ++ toString green
                ++ ","
                ++ toString blue
                ++ ")"
    in
    ( rgbString, toString alpha )


toSvgAttributes : Attribute msg -> List (Svg.Attribute msg)
toSvgAttributes attribute =
    case attribute of
        Internal.FillStyle (Internal.FillColor color) ->
            let
                ( rgbString, alphaString ) =
                    colorStrings color
            in
            [ Svg.Attributes.fill rgbString
            , Svg.Attributes.fillOpacity alphaString
            ]

        Internal.FillStyle Internal.NoFill ->
            [ Svg.Attributes.fill "none" ]

        Internal.StrokeStyle (Internal.StrokeColor color) ->
            let
                ( rgbString, alphaString ) =
                    colorStrings color
            in
            [ Svg.Attributes.stroke rgbString
            , Svg.Attributes.strokeOpacity alphaString
            ]

        Internal.StrokeStyle Internal.NoStroke ->
            [ Svg.Attributes.stroke "none" ]

        Internal.StrokeWidth width ->
            [ Svg.Attributes.strokeWidth (toString width ++ "px") ]

        Internal.ArrowTipStyle _ ->
            []

        Internal.DotRadius _ ->
            []

        Internal.TextAnchor anchor ->
            case anchor of
                Internal.TopLeft ->
                    [ Svg.Attributes.textAnchor "start"
                    , Svg.Attributes.dominantBaseline "hanging"
                    ]

                Internal.TopCenter ->
                    [ Svg.Attributes.textAnchor "middle"
                    , Svg.Attributes.dominantBaseline "hanging"
                    ]

                Internal.TopRight ->
                    [ Svg.Attributes.textAnchor "end"
                    , Svg.Attributes.dominantBaseline "hanging"
                    ]

                Internal.CenterLeft ->
                    [ Svg.Attributes.textAnchor "start"
                    , Svg.Attributes.dominantBaseline "middle"
                    ]

                Internal.Center ->
                    [ Svg.Attributes.textAnchor "middle"
                    , Svg.Attributes.dominantBaseline "middle"
                    ]

                Internal.CenterRight ->
                    [ Svg.Attributes.textAnchor "end"
                    , Svg.Attributes.dominantBaseline "middle"
                    ]

                Internal.BottomLeft ->
                    [ Svg.Attributes.textAnchor "start"
                    , Svg.Attributes.dominantBaseline "alphabetic"
                    ]

                Internal.BottomCenter ->
                    [ Svg.Attributes.textAnchor "middle"
                    , Svg.Attributes.alignmentBaseline "alphabetic"
                    ]

                Internal.BottomRight ->
                    [ Svg.Attributes.textAnchor "end"
                    , Svg.Attributes.alignmentBaseline "alphabetic"
                    ]

        Internal.TextColor color ->
            [ Svg.Attributes.color (Tuple.first (colorStrings color)) ]

        Internal.FontSize px ->
            [ Svg.Attributes.fontSize (toString px ++ "px") ]

        Internal.FontFamily fonts ->
            [ Svg.Attributes.fontFamily
                (fonts |> List.map normalizeFont |> String.join ",")
            ]

        Internal.OnClick message ->
            [ Html.Events.onWithOptions "click"
                { preventDefault = True, stopPropagation = True }
                (Decode.succeed message)
            ]

        Internal.OnMouseDown handler ->
            [ Html.Events.onWithOptions "mousedown"
                { preventDefault = True, stopPropagation = True }
                (Mouse.position |> Decode.map handler)
            ]


apply : Attribute msg -> Context -> Context
apply attribute context =
    case attribute of
        Internal.FillStyle _ ->
            context

        Internal.StrokeStyle _ ->
            context

        Internal.ArrowTipStyle arrowTipStyle ->
            { context | arrowTipStyle = arrowTipStyle }

        Internal.DotRadius dotRadius ->
            { context | dotRadius = dotRadius }

        Internal.StrokeWidth _ ->
            context

        Internal.TextAnchor _ ->
            context

        Internal.TextColor _ ->
            context

        Internal.FontSize _ ->
            context

        Internal.FontFamily _ ->
            context

        Internal.OnClick _ ->
            context

        Internal.OnMouseDown _ ->
            context
