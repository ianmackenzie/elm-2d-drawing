module Drawing2d.HatchPattern exposing
    ( Linked
    , Original
    , at
    , at_
    , linked
    , placeIn
    , relativeTo
    , renderLinked
    , renderOriginal
    , scaleAbout
    , with
    )

import Color exposing (Color)
import Direction2d
import Drawing2d.Event exposing (Event)
import Drawing2d.RenderedSvg as RenderedSvg exposing (RenderedSvg)
import Drawing2d.StrokeDashPattern as StrokeDashPattern
import Drawing2d.Svg as Svg
import Frame2d exposing (Frame2d)
import Json.Encode as Encode exposing (Value)
import LineSegment2d exposing (LineSegment2d)
import Murmur3
import Point2d exposing (Point2d)
import Quantity exposing (Quantity(..), Rate)
import Svg
import Svg.Attributes
import Vector2d exposing (Vector2d)


type alias Transformation units coordinates =
    { p : Point2d units coordinates
    , u : Vector2d units coordinates
    , v : Vector2d units coordinates
    }


type alias Properties units coordinates =
    { transformation : Transformation units coordinates
    , spacing : Quantity Float units
    , strokeWidth : Quantity Float units
    , strokeColor : Color
    , fillColor : Maybe Color
    , dashPattern : List (Quantity Float units)
    }


type Original units coordinates
    = Original String (Properties units coordinates)


type Linked units coordinates
    = Linked
        { originalId : String
        , transformation : Transformation units coordinates
        }


with :
    { frame : Frame2d units coordinates defines
    , spacing : Quantity Float units
    , strokeWidth : Quantity Float units
    , strokeColor : Color
    , fillColor : Maybe Color
    , dashPattern : List (Quantity Float units)
    }
    -> Original units coordinates
with arguments =
    let
        transformation =
            { p = Frame2d.originPoint arguments.frame
            , u = Vector2d.withLength (Quantity 1) (Frame2d.xDirection arguments.frame)
            , v = Vector2d.withLength (Quantity 1) (Frame2d.yDirection arguments.frame)
            }

        properties =
            { transformation = transformation
            , spacing = arguments.spacing
            , strokeWidth = arguments.strokeWidth
            , strokeColor = arguments.strokeColor
            , fillColor = arguments.fillColor
            , dashPattern = arguments.dashPattern
            }

        id =
            "hp" ++ hashJson (encodeOriginal properties)
    in
    Original id properties


linked : Original units coordinates -> Linked units coordinates
linked (Original originalId properties) =
    Linked
        { originalId = originalId
        , transformation = properties.transformation
        }


renderOriginal : Original units coordinates -> RenderedSvg units coordinates msg
renderOriginal (Original originalId properties) =
    let
        spacing =
            properties.spacing

        strokeDashPattern =
            StrokeDashPattern.fromList properties.dashPattern

        dashPeriod =
            StrokeDashPattern.period strokeDashPattern

        width =
            if dashPeriod |> Quantity.greaterThan Quantity.zero then
                dashPeriod

            else
                spacing

        spacingString =
            quantityString spacing

        widthString =
            quantityString width

        heightString =
            quantityString spacing

        lineElements =
            Svg.g
                [ Svg.Attributes.strokeWidth (quantityString properties.strokeWidth)
                , Svg.Attributes.stroke (Color.toCssString properties.strokeColor)
                , StrokeDashPattern.attribute strokeDashPattern
                ]
                [ Svg.line
                    [ Svg.Attributes.x1 "0"
                    , Svg.Attributes.y1 "0"
                    , Svg.Attributes.x2 widthString
                    , Svg.Attributes.y2 "0"
                    ]
                    []
                , Svg.line
                    [ Svg.Attributes.x1 "0"
                    , Svg.Attributes.y1 spacingString
                    , Svg.Attributes.x2 widthString
                    , Svg.Attributes.y2 spacingString
                    ]
                    []
                ]

        patternedElements =
            case properties.fillColor of
                Just fillColor ->
                    [ Svg.rect
                        [ Svg.Attributes.x "0"
                        , Svg.Attributes.y "0"
                        , Svg.Attributes.stroke "none"
                        , Svg.Attributes.width widthString
                        , Svg.Attributes.height heightString
                        , Svg.Attributes.fill (Color.toCssString fillColor)
                        ]
                        []
                    , lineElements
                    ]

                Nothing ->
                    [ lineElements ]

        patternElement =
            Svg.pattern
                [ Svg.Attributes.id originalId
                , Svg.Attributes.x "0"
                , Svg.Attributes.y "0"
                , transformAttribute properties.transformation
                , Svg.Attributes.width widthString
                , Svg.Attributes.height heightString
                , Svg.Attributes.patternUnits "userSpaceOnUse"
                ]
                patternedElements

        fillAttribute =
            Svg.Attributes.fill ("url(#" ++ originalId ++ ")")
    in
    RenderedSvg.with
        { attributes = [ fillAttribute ]
        , elements = [ patternElement ]
        }


hashJson : Value -> String
hashJson json =
    String.fromInt (Murmur3.hashString 0 (Encode.encode 0 json))


renderLinked : Linked units coordinates -> RenderedSvg units coordinates msg
renderLinked (Linked pattern) =
    let
        encoded =
            Encode.list identity
                [ Encode.string pattern.originalId
                , encodeTransformation pattern.transformation
                ]

        id =
            "hp" ++ hashJson encoded

        patternElement =
            Svg.pattern
                [ Svg.Attributes.id id
                , transformAttribute pattern.transformation
                , Svg.Attributes.xlinkHref ("#" ++ pattern.originalId)
                ]
                []

        fillAttribute =
            Svg.Attributes.fill ("url(#" ++ id ++ ")")
    in
    RenderedSvg.with
        { attributes = [ fillAttribute ]
        , elements = [ patternElement ]
        }


quantityString : Quantity Float units -> String
quantityString (Quantity value) =
    String.fromFloat value


transformAttribute : Transformation units coordinates -> Svg.Attribute event
transformAttribute transformation =
    let
        p =
            Point2d.unwrap transformation.p

        u =
            Vector2d.unwrap transformation.u

        v =
            Vector2d.unwrap transformation.v

        matrixComponents =
            [ String.fromFloat u.x
            , String.fromFloat -u.y
            , String.fromFloat -v.x
            , String.fromFloat v.y
            , String.fromFloat p.x
            , String.fromFloat -p.y
            ]

        transform =
            "matrix(" ++ String.join " " matrixComponents ++ ")"
    in
    Svg.Attributes.patternTransform transform


at : Quantity Float (Rate units2 units1) -> Linked units1 coordinates -> Linked units2 coordinates
at rate (Linked pattern) =
    let
        originalTransformation =
            pattern.transformation
    in
    Linked
        { originalId = pattern.originalId
        , transformation =
            { p = Point2d.at rate originalTransformation.p
            , u = Vector2d.at rate originalTransformation.u
            , v = Vector2d.at rate originalTransformation.v
            }
        }


at_ : Quantity Float (Rate units1 units2) -> Linked units1 coordinates -> Linked units2 coordinates
at_ rate pattern =
    at (Quantity.inverse rate) pattern


scaleAbout : Point2d units coordinates -> Float -> Linked units coordinates -> Linked units coordinates
scaleAbout centerPoint scale (Linked pattern) =
    let
        originalTransformation =
            pattern.transformation
    in
    Linked
        { originalId = pattern.originalId
        , transformation =
            { p = Point2d.scaleAbout centerPoint scale originalTransformation.p
            , u = Vector2d.scaleBy scale originalTransformation.u
            , v = Vector2d.scaleBy scale originalTransformation.v
            }
        }


placeIn :
    Frame2d units globalCoordinates { defines : localCoordinates }
    -> Linked units localCoordinates
    -> Linked units globalCoordinates
placeIn frame (Linked pattern) =
    let
        originalTransformation =
            pattern.transformation
    in
    Linked
        { originalId = pattern.originalId
        , transformation =
            { p = Point2d.placeIn frame originalTransformation.p
            , u = Vector2d.placeIn frame originalTransformation.u
            , v = Vector2d.placeIn frame originalTransformation.v
            }
        }


relativeTo :
    Frame2d units globalCoordinates { defines : localCoordinates }
    -> Linked units globalCoordinates
    -> Linked units localCoordinates
relativeTo frame (Linked pattern) =
    let
        originalTransformation =
            pattern.transformation
    in
    Linked
        { originalId = pattern.originalId
        , transformation =
            { p = Point2d.relativeTo frame originalTransformation.p
            , u = Vector2d.relativeTo frame originalTransformation.u
            , v = Vector2d.relativeTo frame originalTransformation.v
            }
        }


encodeTransformation : Transformation units coordinates -> Value
encodeTransformation transformation =
    let
        p =
            Point2d.unwrap transformation.p

        u =
            Vector2d.unwrap transformation.u

        v =
            Vector2d.unwrap transformation.v
    in
    Encode.list Encode.float [ p.x, p.y, u.x, u.y, v.x, v.y ]


encodeQuantity : Quantity Float units -> Value
encodeQuantity (Quantity value) =
    Encode.float value


encodeColor : Color -> Value
encodeColor color =
    Encode.string (Color.toCssString color)


encodeMaybe : (a -> Value) -> Maybe a -> Value
encodeMaybe encode maybe =
    case maybe of
        Just value ->
            encode value

        Nothing ->
            Encode.null


encodeOriginal : Properties units coordinates -> Value
encodeOriginal properties =
    Encode.list identity
        [ encodeTransformation properties.transformation
        , encodeQuantity properties.spacing
        , encodeQuantity properties.strokeWidth
        , encodeColor properties.strokeColor
        , encodeMaybe encodeColor properties.fillColor
        , Encode.list encodeQuantity properties.dashPattern
        ]
