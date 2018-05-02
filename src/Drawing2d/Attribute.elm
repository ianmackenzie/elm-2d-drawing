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

                newAttributes =
                    [ Svg.Attributes.fill rgbString
                    , Svg.Attributes.fillOpacity alphaString
                    ]
            in
            ( context, defs, newAttributes )

        FillStyle NoFill ->
            let
                newAttributes =
                    [ Svg.Attributes.fill "none" ]
            in
            ( context, defs, newAttributes )

        FillStyle (LinearGradientFill gradient) ->
            let
                placedGradient =
                    LinearGradient.placeIn context.placementFrame gradient

                ( id, updatedDefs ) =
                    Defs.addLinearGradient placedGradient defs

                newAttributes =
                    [ Svg.Attributes.fill ("url(#" ++ id ++ ")") ]
            in
            ( context, updatedDefs, newAttributes )

        StrokeColor color ->
            let
                ( rgbString, alphaString ) =
                    Color.strings color

                newAttributes =
                    [ Svg.Attributes.stroke rgbString
                    , Svg.Attributes.strokeOpacity alphaString
                    ]
            in
            ( context, defs, newAttributes )

        StrokeWidth width ->
            let
                newAttributes =
                    [ Svg.Attributes.strokeWidth (toString width ++ "px") ]
            in
            ( context, defs, newAttributes )

        BordersEnabled bordersEnabled ->
            let
                updatedContext =
                    { context | bordersEnabled = bordersEnabled }
            in
            ( updatedContext, defs, [] )

        BorderPosition position ->
            let
                updatedContext =
                    { context | borderPosition = position }
            in
            ( updatedContext, defs, [] )

        DotRadius radius ->
            let
                updatedContext =
                    { context | dotRadius = radius }
            in
            ( updatedContext, defs, [] )

        TextAnchor anchor ->
            let
                newAttributes =
                    TextAnchor.toSvgAttributes anchor
            in
            ( context, defs, newAttributes )

        TextColor color ->
            let
                textColor =
                    Tuple.first (Color.strings color)

                newAttributes =
                    [ Svg.Attributes.color textColor ]
            in
            ( context, defs, newAttributes )

        FontSize px ->
            let
                newAttributes =
                    [ Svg.Attributes.fontSize (toString px) ]
            in
            ( context, defs, newAttributes )

        FontFamily fonts ->
            let
                fontFamily =
                    fonts |> List.map normalizeFont |> String.join ","

                newAttributes =
                    [ Svg.Attributes.fontFamily fontFamily ]
            in
            ( context, defs, newAttributes )

        OnClick message ->
            let
                newAttributes =
                    [ Html.Events.onWithOptions "click"
                        { preventDefault = True, stopPropagation = True }
                        (Decode.succeed message)
                    ]
            in
            ( context, defs, newAttributes )

        OnMouseDown handler ->
            let
                newAttributes =
                    [ Html.Events.onWithOptions "mousedown"
                        { preventDefault = True, stopPropagation = True }
                        (Mouse.position |> Decode.map handler)
                    ]
            in
            ( context, defs, newAttributes )


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
