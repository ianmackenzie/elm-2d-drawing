module Drawing2d.Attribute
    exposing
        ( Attribute(..)
        , FillStyle(..)
        , apply
        , map
        )

import Color exposing (Color)
import Drawing2d.Border as Border exposing (BorderPosition)
import Drawing2d.Color as Color
import Drawing2d.Context as Context exposing (Context)
import Drawing2d.Defs as Defs exposing (Defs)
import Drawing2d.Font as Font
import Drawing2d.GradientContext as GradientContext
import Drawing2d.LinearGradient as LinearGradient exposing (LinearGradient)
import Drawing2d.Text as Text
import Drawing2d.TextAnchor as TextAnchor
import Html.Events
import Json.Decode as Decode
import Mouse
import Svg
import Svg.Attributes


type FillStyle
    = NoFill
    | FillColor Color
    | LinearGradientFill LinearGradient


type Attribute msg
    = FillStyle FillStyle
    | StrokeColor Color
    | StrokeWidth Float
    | DotRadius Float
    | TextAnchor Text.Anchor
    | TextColor Color
    | FontSize Int
    | FontFamily (List String)
    | OnClick msg
    | OnMouseDown (Mouse.Position -> msg)
    | BordersEnabled Bool
    | BorderPosition BorderPosition


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


apply : Attribute msg -> Context -> Defs -> ( Context, Defs, List (Svg.Attribute msg) )
apply attribute context defs =
    case attribute of
        FillStyle (FillColor color) ->
            let
                ( rgbString, alphaString ) =
                    Color.strings color
            in
            ( { context | gradientContext = GradientContext.none }
            , defs
            , [ Svg.Attributes.fill rgbString
              , Svg.Attributes.fillOpacity alphaString
              ]
            )

        FillStyle NoFill ->
            ( { context | gradientContext = GradientContext.none }
            , defs
            , [ Svg.Attributes.fill "none" ]
            )

        FillStyle (LinearGradientFill gradient) ->
            let
                ( defId, updatedDefs ) =
                    Defs.addLinearGradientStops
                        (LinearGradient.stops gradient)
                        defs

                updatedContext =
                    { context
                        | gradientContext =
                            GradientContext.linear defId
                                (LinearGradient.startPoint gradient)
                                (LinearGradient.endPoint gradient)
                    }
            in
            ( updatedContext, updatedDefs, [] )

        StrokeColor color ->
            let
                ( rgbString, alphaString ) =
                    Color.strings color
            in
            ( context
            , defs
            , [ Svg.Attributes.stroke rgbString
              , Svg.Attributes.strokeOpacity alphaString
              ]
            )

        StrokeWidth width ->
            ( context
            , defs
            , [ Svg.Attributes.strokeWidth (toString width ++ "px") ]
            )

        BordersEnabled bordersEnabled ->
            ( { context | bordersEnabled = bordersEnabled }, defs, [] )

        BorderPosition position ->
            ( { context | borderPosition = position }, defs, [] )

        DotRadius radius ->
            ( { context | dotRadius = radius }, defs, [] )

        TextAnchor anchor ->
            ( context, defs, TextAnchor.toSvgAttributes anchor )

        TextColor color ->
            ( context
            , defs
            , [ Svg.Attributes.color (Tuple.first (Color.strings color)) ]
            )

        FontSize px ->
            ( { context | fontSize = toFloat px }, defs, [] )

        FontFamily fonts ->
            ( context
            , defs
            , [ Svg.Attributes.fontFamily
                    (fonts |> List.map normalizeFont |> String.join ",")
              ]
            )

        OnClick message ->
            ( context
            , defs
            , [ Html.Events.onWithOptions "click"
                    { preventDefault = True, stopPropagation = True }
                    (Decode.succeed message)
              ]
            )

        OnMouseDown handler ->
            ( context
            , defs
            , [ Html.Events.onWithOptions "mousedown"
                    { preventDefault = True, stopPropagation = True }
                    (Mouse.position |> Decode.map handler)
              ]
            )


map : (a -> b) -> Attribute a -> Attribute b
map function attribute =
    case attribute of
        FillStyle style ->
            FillStyle style

        StrokeColor color ->
            StrokeColor color

        StrokeWidth width ->
            StrokeWidth width

        BordersEnabled bordersEnabled ->
            BordersEnabled bordersEnabled

        BorderPosition position ->
            BorderPosition position

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
