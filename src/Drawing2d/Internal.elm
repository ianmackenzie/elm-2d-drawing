module Drawing2d.Internal exposing (..)

import Color exposing (Color)
import Direction2d as Direction2d exposing (Direction2d)
import Frame2d as Frame2d exposing (Frame2d)
import LineSegment2d exposing (LineSegment2d)
import Point2d as Point2d exposing (Point2d)
import Svg
import Svg.Attributes
import Triangle2d exposing (Triangle2d)


type FillStyle
    = FillColor Color
    | NoFill


type StrokeStyle
    = StrokeColor Color
    | NoStroke


type ArrowTipStyle
    = TriangularTip { length : Float, width : Float }


type Attribute msg
    = FillStyle FillStyle
    | StrokeStyle StrokeStyle
    | ArrowTipStyle ArrowTipStyle
    | PointRadius Float


type Element msg
    = Empty
    | Group (List (Attribute msg)) (List (Element msg))
    | PlaceIn Frame2d (Element msg)
    | Arrow (List (Attribute msg)) Point2d Float Direction2d
    | LineSegment (List (Attribute msg)) LineSegment2d
    | Triangle (List (Attribute msg)) Triangle2d
    | Point (List (Attribute msg)) Point2d


type alias Context =
    { pointRadius : Float
    , arrowTipStyle : ArrowTipStyle
    }


defaultContext : Context
defaultContext =
    { pointRadius = 3
    , arrowTipStyle = TriangularTip { length = 10, width = 8 }
    }


applyAttribute : Attribute msg -> Context -> Context
applyAttribute attribute context =
    case attribute of
        FillStyle _ ->
            context

        StrokeStyle _ ->
            context

        ArrowTipStyle arrowTipStyle ->
            { context | arrowTipStyle = arrowTipStyle }

        PointRadius pointRadius ->
            { context | pointRadius = pointRadius }


applyAttributes : List (Attribute msg) -> Context -> Context
applyAttributes attributes context =
    List.foldl applyAttribute context attributes


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

        ArrowTipStyle _ ->
            []

        PointRadius _ ->
            []


svgAttributes : List (Attribute msg) -> List (Svg.Attribute msg)
svgAttributes attributes =
    List.concat (List.map toSvgAttributes attributes)


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
