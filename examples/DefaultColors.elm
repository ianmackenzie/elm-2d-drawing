module DefaultColors exposing (main)

import Arc2d
import BoundingBox2d
import Circle2d
import Color
import Common exposing (dot)
import Drawing2d
import Drawing2d.Attributes as Attributes
import Drawing2d.Font as Font
import Html exposing (Html)
import Parameter1d
import Pixels exposing (pixels)
import Point2d
import Rectangle2d


main : Html Never
main =
    let
        renderBounds =
            BoundingBox2d.fromExtrema
                { minX = pixels 0
                , maxX = pixels 800
                , minY = pixels 0
                , maxY = pixels 800
                }
    in
    Drawing2d.toHtml renderBounds
        [ Attributes.fontFamily [ Font.sansSerif ] ]
        [ Drawing2d.rectangle [] <|
            Rectangle2d.fromExtrema
                { minX = pixels 50
                , minY = pixels 50
                , maxX = pixels 150
                , maxY = pixels 150
                }
        , Drawing2d.rectangle [] <|
            Rectangle2d.fromExtrema
                { minX = pixels 100
                , minY = pixels 100
                , maxX = pixels 200
                , maxY = pixels 200
                }
        , Drawing2d.group [] <|
            let
                circle =
                    Circle2d.withRadius (pixels 50)
                        (Point2d.pixels 200 200)
            in
            circle
                |> Circle2d.toArc
                |> Arc2d.pointOn
                |> Parameter1d.steps 32
                |> List.map dot
        , Drawing2d.text []
            (Point2d.pixels 50 750)
            "Test text"
        , Drawing2d.text
            [ Attributes.fontFamily [ Font.sansSerif ]
            , Attributes.fontSize (pixels 36)
            , Attributes.textColor Color.darkGrey
            , Attributes.fillColor Color.orange
            , Attributes.strokeColor Color.blue
            ]
            (Point2d.pixels 100 650)
            "Large colored text"
        ]
