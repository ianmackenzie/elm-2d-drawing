module Drawing2d.FillStyle exposing
    ( FillStyle
    , black
    , color
    , gradient
    , hatchPattern
    , none
    , render
    , transparent
    , updateFillGradient
    , updateHatchPattern
    , white
    )

import BoundingBox2d exposing (BoundingBox2d)
import Color exposing (Color)
import Direction2d exposing (Direction2d)
import Drawing2d.Event exposing (Event)
import Drawing2d.Gradient as Gradient exposing (Gradient)
import Drawing2d.HatchPattern as HatchPattern
import Drawing2d.Render as Render
import Drawing2d.RenderedSvg as RenderedSvg exposing (RenderedSvg)
import Drawing2d.StrokeDashPattern as StrokeDashPattern exposing (StrokeDashPattern)
import Drawing2d.StrokeStyle as StrokeStyle exposing (StrokeStyle)
import Drawing2d.Svg as Svg
import Frame2d exposing (Frame2d)
import LineSegment2d exposing (LineSegment2d)
import Point2d exposing (Point2d)
import Quantity exposing (Quantity, Rate)
import Rectangle2d exposing (Rectangle2d)
import Svg exposing (Svg)
import Svg.Attributes


type FillStyle units coordinates
    = NoFill
    | TransparentFill
    | FillColor String
    | FillGradient (Gradient units coordinates)
    | HatchFill (HatchPattern.Original units coordinates)


none : FillStyle units coordinates
none =
    NoFill


transparent : FillStyle units coordinates
transparent =
    TransparentFill


black : FillStyle units coordinates
black =
    FillColor "black"


white : FillStyle units coordinates
white =
    FillColor "white"


color : Color -> FillStyle units coordinates
color givenColor =
    FillColor (Color.toCssString givenColor)


gradient : Gradient units coordinates -> FillStyle units coordinates
gradient givenGradient =
    FillGradient givenGradient


hatchPattern : HatchPattern.Original units coordinates -> FillStyle units coordinates
hatchPattern givenHatchPattern =
    HatchFill givenHatchPattern


updateFillGradient :
    Maybe (FillStyle units coordinates)
    -> Maybe (Gradient units coordinates)
    -> Maybe (Gradient units coordinates)
updateFillGradient maybeFillStyle current =
    case maybeFillStyle of
        Just NoFill ->
            Nothing

        Just TransparentFill ->
            Nothing

        Just (FillColor _) ->
            Nothing

        Just (FillGradient newGradient) ->
            Just newGradient

        Just (HatchFill _) ->
            Nothing

        Nothing ->
            current


updateHatchPattern :
    Maybe (FillStyle units coordinates)
    -> Maybe (HatchPattern.Linked units coordinates)
    -> Maybe (HatchPattern.Linked units coordinates)
updateHatchPattern maybeFillStyle current =
    case maybeFillStyle of
        Just NoFill ->
            Nothing

        Just TransparentFill ->
            Nothing

        Just (FillColor _) ->
            Nothing

        Just (FillGradient _) ->
            Nothing

        Just (HatchFill originalHatchPattern) ->
            Just (HatchPattern.linked originalHatchPattern)

        Nothing ->
            current


render : FillStyle units coordinates -> RenderedSvg units coordinates msg
render fillStyle =
    case fillStyle of
        NoFill ->
            noFill

        TransparentFill ->
            transparentFill

        FillColor string ->
            RenderedSvg.attributes [ Svg.Attributes.fill string ]

        FillGradient fillGradient ->
            Gradient.render Svg.Attributes.fill fillGradient

        HatchFill hatchFill ->
            HatchPattern.renderOriginal hatchFill


noFill : RenderedSvg units coordinates msg
noFill =
    RenderedSvg.attributes [ Svg.Attributes.fill "none" ]


transparentFill : RenderedSvg units coordinates msg
transparentFill =
    RenderedSvg.attributes
        [ Svg.Attributes.fill "black"
        , Svg.Attributes.fillOpacity "0"
        ]
