module DashedStroke exposing (main)

import Circle2d
import Drawing2d
import Html exposing (Html)
import Pixels
import Point2d
import Quantity
import Rectangle2d


main : Html Never
main =
    let
        p1 =
            Point2d.pixels 200 200

        p2 =
            Point2d.pixels 600 200

        p3 =
            Point2d.pixels 200 600

        p4 =
            Point2d.pixels 600 600

        p5 =
            Point2d.pixels 400 400

        r =
            Pixels.float 100

        dashedStroke =
            Drawing2d.dashedStroke [ Pixels.float 8, Pixels.float 4 ]
    in
    Drawing2d.draw
        { viewBox = Rectangle2d.from Point2d.origin (Point2d.pixels 800 800)
        , background = Drawing2d.noBackground
        , attributes = []
        , entities =
            [ Drawing2d.circle [ dashedStroke ] (Circle2d.atPoint p1 r)
            , Drawing2d.scaleAbout p1 0.5 <|
                Drawing2d.circle [ dashedStroke ] (Circle2d.atPoint p1 r)
            , Drawing2d.group [ dashedStroke ] <|
                [ Drawing2d.circle [] (Circle2d.atPoint p2 r)
                , Drawing2d.scaleAbout p2 0.5 <|
                    Drawing2d.circle [] (Circle2d.atPoint p2 r)
                ]
            , Drawing2d.group [ dashedStroke ] <|
                [ Drawing2d.circle [] (Circle2d.atPoint p3 r)
                , Drawing2d.scaleAbout p3 0.5 <|
                    Drawing2d.circle [ Drawing2d.solidStroke ]
                        (Circle2d.atPoint p3 r)
                ]
            , Drawing2d.group [ dashedStroke ] <|
                [ Drawing2d.circle [] (Circle2d.atPoint p4 r)
                , Drawing2d.group [ Drawing2d.solidStroke ]
                    [ Drawing2d.scaleAbout p4 0.5 <|
                        Drawing2d.circle []
                            (Circle2d.atPoint p4 r)
                    ]
                ]
            , Drawing2d.group [ dashedStroke ] <|
                [ Drawing2d.circle [] (Circle2d.atPoint p5 r)
                , Drawing2d.group [ Drawing2d.solidStroke ]
                    [ Drawing2d.circle []
                        (Circle2d.atPoint p5 (Quantity.half r))
                    ]
                ]
            ]
        }
