module Drawing2d.Attribute
    exposing
        ( Attribute(..)
        , Context
        , FillStyle(..)
        , StrokeStyle(..)
        , apply
        , defaultContext
        , map
        , toSvgAttributes
        )

import Color exposing (Color)
import Drawing2d.Font as Font
import Drawing2d.Text as Text
import Drawing2d.TextAnchor as TextAnchor
import Html.Events
import Json.Decode as Decode
import Mouse
import Svg
import Svg.Attributes


type FillStyle
    = FillColor Color
    | NoFill


type StrokeStyle
    = StrokeColor Color
    | NoStroke


type Attribute msg
    = FillStyle FillStyle
    | StrokeStyle StrokeStyle
    | StrokeWidth Float
    | DotRadius Float
    | TextAnchor Text.Anchor
    | TextColor Color
    | FontSize Int
    | FontFamily (List String)
    | OnClick msg
    | OnMouseDown (Mouse.Position -> msg)


type alias Context =
    { dotRadius : Float
    }


defaultContext : Context
defaultContext =
    { dotRadius = 3
    }


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
        FillStyle (FillColor color) ->
            let
                ( rgbString, alphaString ) =
                    colorStrings color
            in
            [ Svg.Attributes.fill rgbString
            , Svg.Attributes.fillOpacity alphaString
            ]

        FillStyle NoFill ->
            [ Svg.Attributes.fill "none" ]

        StrokeStyle (StrokeColor color) ->
            let
                ( rgbString, alphaString ) =
                    colorStrings color
            in
            [ Svg.Attributes.stroke rgbString
            , Svg.Attributes.strokeOpacity alphaString
            ]

        StrokeStyle NoStroke ->
            [ Svg.Attributes.stroke "none" ]

        StrokeWidth width ->
            [ Svg.Attributes.strokeWidth (toString width ++ "px") ]

        DotRadius _ ->
            []

        TextAnchor anchor ->
            TextAnchor.toSvgAttributes anchor

        TextColor color ->
            [ Svg.Attributes.color (Tuple.first (colorStrings color)) ]

        FontSize px ->
            [ Svg.Attributes.fontSize (toString px ++ "px") ]

        FontFamily fonts ->
            [ Svg.Attributes.fontFamily
                (fonts |> List.map normalizeFont |> String.join ",")
            ]

        OnClick message ->
            [ Html.Events.onWithOptions "click"
                { preventDefault = True, stopPropagation = True }
                (Decode.succeed message)
            ]

        OnMouseDown handler ->
            [ Html.Events.onWithOptions "mousedown"
                { preventDefault = True, stopPropagation = True }
                (Mouse.position |> Decode.map handler)
            ]


apply : Attribute msg -> Context -> Context
apply attribute context =
    case attribute of
        FillStyle _ ->
            context

        StrokeStyle _ ->
            context

        DotRadius dotRadius ->
            { context | dotRadius = dotRadius }

        StrokeWidth _ ->
            context

        TextAnchor _ ->
            context

        TextColor _ ->
            context

        FontSize _ ->
            context

        FontFamily _ ->
            context

        OnClick _ ->
            context

        OnMouseDown _ ->
            context


map : (a -> b) -> Attribute a -> Attribute b
map function attribute =
    case attribute of
        FillStyle style ->
            FillStyle style

        StrokeStyle style ->
            StrokeStyle style

        StrokeWidth width ->
            StrokeWidth width

        DotRadius radius ->
            DotRadius radius

        TextAnchor anchor ->
            TextAnchor anchor

        TextColor color ->
            TextColor color

        FontSize px ->
            FontSize px

        FontFamily fonts ->
            FontFamily fonts

        OnClick message ->
            OnClick (function message)

        OnMouseDown handler ->
            OnMouseDown (handler >> function)
