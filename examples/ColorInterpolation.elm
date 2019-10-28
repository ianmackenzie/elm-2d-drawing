module ColorInterpolation exposing (main)

import BoundingBox2d
import Color
import Color.Interpolate
import Drawing2d
import Drawing2d.Attributes as Attributes
import Frame2d
import Html exposing (Html)
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
                    Rectangle2d.withAxes (Frame2d.atPoint (Point2d.xy x zero))
                        ( swatchSize, swatchSize )
                )

        aggregate =
            BoundingBox2d.hullN
                (List.map Rectangle2d.boundingBox rectangles)
    in
    case aggregate of
        Nothing ->
            Html.text ""

        Just overallBounds ->
            let
                renderBounds =
                    overallBounds
                        |> BoundingBox2d.expandBy (pixels 0.5)

                elements =
                    List.map2
                        (\color rectangle ->
                            Drawing2d.rectangle [ Attributes.fillColor color ]
                                rectangle
                        )
                        colors
                        rectangles
            in
            Drawing2d.toHtml renderBounds [] elements