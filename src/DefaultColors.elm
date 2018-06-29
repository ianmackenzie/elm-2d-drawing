module Example exposing (..)

import Arc2d
import BoundingBox2d
import Circle2d
import Color
import Curve.ParameterValue as ParameterValue
import Drawing2d
import Drawing2d.Attributes as Attributes
import Drawing2d.Font as Font
import Html exposing (Html)
import Point2d
import Rectangle2d


main : Html Never
main =
    let
        renderBounds =
            BoundingBox2d.fromExtrema
                { minX = 0
                , maxX = 800
                , minY = 0
                , maxY = 800
                }
    in
    Drawing2d.toHtml renderBounds
        [ Attributes.fontFamily [ Font.sansSerif ] ]
        [ Drawing2d.rectangle <|
            Rectangle2d.fromExtrema
                { minX = 50
                , minY = 50
                , maxX = 150
                , maxY = 150
                }
        , Drawing2d.rectangle <|
            Rectangle2d.fromExtrema
                { minX = 100
                , minY = 100
                , maxX = 200
                , maxY = 200
                }
        , Drawing2d.dots
            (let
                circle =
                    Circle2d.withRadius 50
                        (Point2d.fromCoordinates ( 200, 200 ))
             in
             circle
                |> Circle2d.toArc
                |> Arc2d.pointsAt (ParameterValue.steps 32)
            )
        , Drawing2d.text (Point2d.fromCoordinates ( 50, 750 ))
            "Test text"
        , Drawing2d.textWith
            [ Attributes.fontFamily [ Font.sansSerif ]
            , Attributes.fontSize 36
            , Attributes.textColor Color.darkGrey
            , Attributes.fillColor Color.orange
            , Attributes.strokeColor Color.blue
            ]
            (Point2d.fromCoordinates ( 100, 650 ))
            "Large colored text"
        ]
