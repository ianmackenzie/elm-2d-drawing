module Drawing2d.Internal exposing (..)

import Arc2d exposing (Arc2d)
import Circle2d exposing (Circle2d)
import Color exposing (Color)
import CubicSpline2d exposing (CubicSpline2d)
import Direction2d as Direction2d exposing (Direction2d)
import Ellipse2d exposing (Ellipse2d)
import EllipticalArc2d exposing (EllipticalArc2d)
import Frame2d as Frame2d exposing (Frame2d)
import Html.Events
import Json.Decode as Decode
import LineSegment2d exposing (LineSegment2d)
import Point2d as Point2d exposing (Point2d)
import Polygon2d exposing (Polygon2d)
import Polyline2d exposing (Polyline2d)
import QuadraticSpline2d exposing (QuadraticSpline2d)
import Svg
import Svg.Attributes
import Svg.Events
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
    | StrokeWidth Float
    | ArrowTipStyle ArrowTipStyle
    | DotRadius Float
    | OnClick msg
    | OnMouseDown msg


type Element msg
    = Empty
    | Group (List (Attribute msg)) (List (Element msg))
    | PlaceIn Frame2d (Element msg)
    | ScaleAbout Point2d Float (Element msg)
    | Arrow (List (Attribute msg)) Point2d Float Direction2d
    | LineSegment (List (Attribute msg)) LineSegment2d
    | Triangle (List (Attribute msg)) Triangle2d
    | Dot (List (Attribute msg)) Point2d
    | Arc (List (Attribute msg)) Arc2d
    | CubicSpline (List (Attribute msg)) CubicSpline2d
    | QuadraticSpline (List (Attribute msg)) QuadraticSpline2d
    | Polyline (List (Attribute msg)) Polyline2d
    | Polygon (List (Attribute msg)) Polygon2d
    | Circle (List (Attribute msg)) Circle2d
    | Ellipse (List (Attribute msg)) Ellipse2d
    | EllipticalArc (List (Attribute msg)) EllipticalArc2d


type alias Context =
    { dotRadius : Float
    , arrowTipStyle : ArrowTipStyle
    }


defaultContext : Context
defaultContext =
    { dotRadius = 3
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

        DotRadius dotRadius ->
            { context | dotRadius = dotRadius }

        StrokeWidth _ ->
            context

        OnClick _ ->
            context

        OnMouseDown _ ->
            context


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

        StrokeWidth width ->
            [ Svg.Attributes.strokeWidth (toString width ++ "px") ]

        ArrowTipStyle _ ->
            []

        DotRadius _ ->
            []

        OnClick message ->
            [ Html.Events.onWithOptions "click"
                { preventDefault = True, stopPropagation = True }
                (Decode.succeed message)
            ]

        OnMouseDown message ->
            [ Html.Events.onWithOptions "mousedown"
                { preventDefault = True, stopPropagation = True }
                (Decode.succeed message)
            ]


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
