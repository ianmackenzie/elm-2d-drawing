module Drawing2d.TextAnchor exposing (Anchor(..), toSvgAttributes)

import Svg
import Svg.Attributes


type Anchor
    = TopLeft
    | TopCenter
    | TopRight
    | CenterLeft
    | Center
    | CenterRight
    | BottomLeft
    | BottomCenter
    | BottomRight


toSvgAttributes : Anchor -> List (Svg.Attribute msg)
toSvgAttributes anchor =
    case anchor of
        TopLeft ->
            [ Svg.Attributes.textAnchor "start"
            , Svg.Attributes.dominantBaseline "hanging"
            ]

        TopCenter ->
            [ Svg.Attributes.textAnchor "middle"
            , Svg.Attributes.dominantBaseline "hanging"
            ]

        TopRight ->
            [ Svg.Attributes.textAnchor "end"
            , Svg.Attributes.dominantBaseline "hanging"
            ]

        CenterLeft ->
            [ Svg.Attributes.textAnchor "start"
            , Svg.Attributes.dominantBaseline "middle"
            ]

        Center ->
            [ Svg.Attributes.textAnchor "middle"
            , Svg.Attributes.dominantBaseline "middle"
            ]

        CenterRight ->
            [ Svg.Attributes.textAnchor "end"
            , Svg.Attributes.dominantBaseline "middle"
            ]

        BottomLeft ->
            [ Svg.Attributes.textAnchor "start"
            , Svg.Attributes.dominantBaseline "alphabetic"
            ]

        BottomCenter ->
            [ Svg.Attributes.textAnchor "middle"
            , Svg.Attributes.alignmentBaseline "alphabetic"
            ]

        BottomRight ->
            [ Svg.Attributes.textAnchor "end"
            , Svg.Attributes.alignmentBaseline "alphabetic"
            ]
