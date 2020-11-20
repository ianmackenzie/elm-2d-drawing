module DefaultColors exposing (main)

import Arc2d
import BoundingBox2d
import Circle2d
import Color
import Common exposing (dot)
import Drawing2d
import Html exposing (Html)
import Parameter1d
import Pixels exposing (pixels)
import Point2d
import Rectangle2d
import Vector2d


main : Html Never
main =
    let
        viewBox =
            Rectangle2d.from Point2d.origin (Point2d.pixels 800 800)
    in
    Drawing2d.toHtml
        { viewBox = viewBox
        , size = Drawing2d.fixed
        , strokeWidth = Pixels.float 1
        , fontSize = Pixels.float 16
        , attributes = []
        , elements =
            [ Drawing2d.rectangle [ Drawing2d.whiteFill ] <|
                Rectangle2d.with
                    { x1 = pixels 50
                    , y1 = pixels 50
                    , x2 = pixels 150
                    , y2 = pixels 150
                    }
            , Drawing2d.rectangle [ Drawing2d.whiteFill ] <|
                Rectangle2d.with
                    { x1 = pixels 100
                    , y1 = pixels 100
                    , x2 = pixels 200
                    , y2 = pixels 200
                    }
            , Drawing2d.boundingBox [ Drawing2d.fillColor Color.blue ] <|
                BoundingBox2d.withDimensions ( pixels 150, pixels 150 )
                    (Point2d.pixels 200 400)
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
            , Drawing2d.text
                [ Drawing2d.fontSize (pixels 20)
                , Drawing2d.dropShadow
                    { color = Color.darkGrey
                    , offset = Vector2d.pixels 1 -2
                    , radius = pixels 2
                    }
                ]
                (Point2d.pixels 50 750)
                "Test text"
            , Drawing2d.text
                [ Drawing2d.fontFamily [ "sans-serif" ]
                , Drawing2d.fontSize (pixels 36)
                , Drawing2d.textColor Color.darkGrey
                , Drawing2d.fillColor Color.orange
                , Drawing2d.strokeColor Color.blue
                , Drawing2d.dropShadow
                    { color = Color.blue
                    , offset = Vector2d.pixels -1 -2
                    , radius = pixels 4
                    }
                ]
                (Point2d.pixels 100 650)
                "Large colored text"
            ]
        }
