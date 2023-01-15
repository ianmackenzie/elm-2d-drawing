module Drawing2d.StrokeStyle exposing
    ( StrokeStyle
    , at
    , at_
    , black
    , color
    , gradient
    , placeIn
    , relativeTo
    , render
    , scaleAbout
    , updateStrokeGradient
    , white
    )

import Color exposing (Color)
import Drawing2d.Gradient as Gradient exposing (Gradient)
import Drawing2d.RenderedSvg as RenderedSvg exposing (RenderedSvg)
import Frame2d exposing (Frame2d)
import Point2d exposing (Point2d)
import Quantity exposing (Quantity, Rate)
import Svg exposing (Svg)
import Svg.Attributes


type StrokeStyle units coordinates
    = StrokeColor String
    | StrokeGradient (Gradient units coordinates)


black : StrokeStyle units coordinates
black =
    StrokeColor "black"


white : StrokeStyle units coordinates
white =
    StrokeColor "white"


color : Color -> StrokeStyle units coordinates
color givenColor =
    StrokeColor (Color.toCssString givenColor)


gradient : Gradient units coordinates -> StrokeStyle units coordinates
gradient givenGradient =
    StrokeGradient givenGradient


map :
    (Gradient units1 coordinates1 -> Gradient units2 coordinates2)
    -> StrokeStyle units1 coordinates1
    -> StrokeStyle units2 coordinates2
map gradientTransform strokeStyle =
    case strokeStyle of
        StrokeColor string ->
            StrokeColor string

        StrokeGradient strokeGradient ->
            StrokeGradient (gradientTransform strokeGradient)


at :
    Quantity Float (Rate units2 units1)
    -> StrokeStyle units1 coordinates
    -> StrokeStyle units2 coordinates
at rate strokeStyle =
    map (Gradient.at rate) strokeStyle


at_ :
    Quantity Float (Rate units1 units2)
    -> StrokeStyle units1 coordinates
    -> StrokeStyle units2 coordinates
at_ rate strokeStyle =
    map (Gradient.at_ rate) strokeStyle


scaleAbout :
    Point2d units coordinates
    -> Float
    -> StrokeStyle units coordinates
    -> StrokeStyle units coordinates
scaleAbout point scale strokeStyle =
    map (Gradient.scaleAbout point scale) strokeStyle


placeIn :
    Frame2d units globalCoordinates { defines : localCoordinates }
    -> StrokeStyle units localCoordinates
    -> StrokeStyle units globalCoordinates
placeIn frame strokeStyle =
    map (Gradient.placeIn frame) strokeStyle


relativeTo :
    Frame2d units globalCoordinates { defines : localCoordinates }
    -> StrokeStyle units globalCoordinates
    -> StrokeStyle units localCoordinates
relativeTo frame strokeStyle =
    map (Gradient.relativeTo frame) strokeStyle


render : StrokeStyle units coordinates -> RenderedSvg units coordinates msg
render strokeStyle =
    case strokeStyle of
        StrokeColor string ->
            RenderedSvg.attributes [ Svg.Attributes.stroke string ]

        StrokeGradient strokeGradient ->
            Gradient.render Svg.Attributes.stroke strokeGradient


updateStrokeGradient :
    Maybe (StrokeStyle units coordinates)
    -> Maybe (Gradient units coordinates)
    -> Maybe (Gradient units coordinates)
updateStrokeGradient maybeStrokeStyle current =
    case maybeStrokeStyle of
        Just (StrokeColor _) ->
            Nothing

        Just (StrokeGradient newGradient) ->
            Just newGradient

        Nothing ->
            current
