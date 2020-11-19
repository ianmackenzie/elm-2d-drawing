module Images exposing (main)

import BoundingBox2d
import Color
import CubicSpline2d
import Drawing2d
import Frame2d
import Html exposing (Html)
import Pixels exposing (pixels)
import Point2d
import Quantity exposing (zero)
import Rectangle2d
import Vector2d


main : Html msg
main =
    let
        viewBox =
            Rectangle2d.from Point2d.origin (Point2d.pixels 800 600)

        spline =
            CubicSpline2d.fromControlPoints
                (Point2d.pixels 100 100)
                (Point2d.pixels 300 600)
                (Point2d.pixels 500 0)
                (Point2d.pixels 700 500)
    in
    case CubicSpline2d.nondegenerate spline of
        Ok nondegenerateSpline ->
            let
                parameterizedSpline =
                    nondegenerateSpline
                        |> CubicSpline2d.arcLengthParameterized
                            { maxError = pixels 0.5 }

                splineLength =
                    CubicSpline2d.arcLength parameterizedSpline

                imageUrl =
                    "https://upload.wikimedia.org/wikipedia/commons/thumb/f/f3/Elm_logo.svg/200px-Elm_logo.svg.png"

                imageWidth =
                    pixels 48

                spacing =
                    pixels 8

                stepSize =
                    imageWidth |> Quantity.plus spacing

                numSteps =
                    floor (Quantity.ratio splineLength stepSize)

                samples =
                    List.range 0 numSteps
                        |> List.map
                            (\i ->
                                Quantity.interpolateFrom
                                    zero
                                    splineLength
                                    (toFloat i / toFloat numSteps)
                            )
                        |> List.map (CubicSpline2d.sampleAlong parameterizedSpline)

                toImage ( point, direction ) =
                    let
                        rectangle =
                            Rectangle2d.centeredOn
                                (Frame2d.withXDirection direction point)
                                ( imageWidth, imageWidth )
                    in
                    Drawing2d.group []
                        [ Drawing2d.rectangle
                            [ Drawing2d.whiteFill, Drawing2d.noBorder ]
                            rectangle
                        , Drawing2d.image [] imageUrl rectangle
                        ]
            in
            Drawing2d.toHtml
                { viewBox = viewBox
                , size = Drawing2d.fixed
                , attributes =
                    [ Drawing2d.dropShadow
                        { radius = pixels 6
                        , offset = Vector2d.pixels 2 -4
                        , color = Color.darkGrey
                        }
                    ]
                , elements =
                    [ Drawing2d.cubicSpline
                        [ Drawing2d.strokeWidth (pixels 4)
                        , Drawing2d.strokeColor Color.charcoal
                        ]
                        spline
                    , Drawing2d.group [] (List.map toImage samples)
                    ]
                }

        Err _ ->
            Html.text "Spline is degenerate"
