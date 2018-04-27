module GradientExample exposing (..)

import BoundingBox2d
import Color
import Drawing2d
import Drawing2d.Attributes as Attributes
import Html exposing (Html)
import LineSegment2d
import Point2d
import Rectangle2d


main : Html msg
main =
    let
        renderBounds =
            BoundingBox2d.fromExtrema
                { minX = 0
                , maxX = 800
                , minY = 0
                , maxY = 800
                }

        rectangle =
            Rectangle2d.fromExtrema
                { minX = 100
                , maxX = 700
                , minY = 100
                , maxY = 700
                }

        lowerLeftCorner =
            Point2d.fromCoordinates ( 100, 100 )

        p1 =
            Point2d.fromCoordinates ( 300, 300 )

        p2 =
            Point2d.fromCoordinates ( 500, 500 )

        gradientLine =
            LineSegment2d.from p1 p2

        stops =
            [ ( 0, Color.red )
            , ( 1, Color.blue )
            ]

        box =
            Drawing2d.group
                [ Drawing2d.rectangleWith
                    [ Attributes.linearGradientFill gradientLine stops ]
                    rectangle
                , Drawing2d.lineSegment gradientLine
                , Drawing2d.dot p1
                , Drawing2d.dot p2
                ]
                |> Drawing2d.scaleAbout lowerLeftCorner 0.5
                |> Drawing2d.rotateAround lowerLeftCorner (degrees 30)
    in
    Drawing2d.toHtml renderBounds [] [ box ]
