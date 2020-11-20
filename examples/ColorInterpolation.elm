module ColorInterpolation exposing (main)

import BoundingBox2d
import Color
import Color.Interpolate
import Drawing2d
import Element
import Element.Border
import Frame2d
import Html exposing (Html)
import Html.Attributes
import List.Extra
import Parameter1d
import Pixels exposing (pixels)
import Point2d
import Quantity exposing (zero)
import Rectangle2d


main : Html msg
main =
    let
        swatchSize =
            pixels 32

        numSteps =
            10

        colors =
            Parameter1d.steps numSteps <|
                Color.Interpolate.interpolate Color.Interpolate.RGB
                    Color.red
                    Color.blue

        rectangles =
            List.Extra.initialize (numSteps + 1)
                (\i ->
                    let
                        x =
                            swatchSize |> Quantity.multiplyBy (toFloat i)
                    in
                    Rectangle2d.centeredOn (Frame2d.atPoint (Point2d.xy x zero))
                        ( swatchSize, swatchSize )
                )

        aggregate =
            BoundingBox2d.aggregateN
                (List.map Rectangle2d.boundingBox rectangles)
    in
    case aggregate of
        Nothing ->
            Html.text ""

        Just overallBounds ->
            let
                viewBox =
                    overallBounds
                        |> BoundingBox2d.expandBy (pixels 0.5)
                        |> Rectangle2d.fromBoundingBox

                elements =
                    List.map2
                        (\color rectangle ->
                            Drawing2d.rectangle [ Drawing2d.fillColor color ]
                                rectangle
                        )
                        colors
                        rectangles
            in
            Drawing2d.draw
                { viewBox = viewBox
                , attributes = []
                , elements = elements
                }
