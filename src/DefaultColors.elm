module Example exposing (..)

import BoundingBox2d
import Color
import Drawing2d
import Drawing2d.Attributes as Attributes
import Drawing2d.Font as Font
import Frame2d
import Geometry.Parameter as Parameter
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
        , Drawing2d.group
            (Parameter.numSteps 32
                |> List.map
                    (\t ->
                        Point2d.fromPolarCoordinatesIn
                            (Frame2d.atPoint
                                (Point2d.fromCoordinates ( 200, 200 ))
                            )
                            ( 50, t * turns 1 )
                    )
                |> List.map Drawing2d.dot
            )
        , Drawing2d.text (Point2d.fromCoordinates ( 50, 750 ))
            "Test text"
        , Drawing2d.groupWith
            [ Attributes.fontFamily [ Font.sansSerif ]
            , Attributes.fontSize 36
            , Attributes.textColor Color.darkGrey
            , Attributes.fillColor Color.orange
            , Attributes.strokeColor Color.blue
            ]
            [ Drawing2d.textShape (Point2d.fromCoordinates ( 100, 700 )) "Large styled text"
            , Drawing2d.text (Point2d.fromCoordinates ( 100, 650 )) "Large colored text"
            ]
        ]
