module ImageCursor exposing (main)

import Color
import Drawing2d
import Html exposing (Html)
import Pixels
import Point2d
import Rectangle2d exposing (Rectangle2d)


main : Html Never
main =
    let
        rect1 =
            Rectangle2d.from (Point2d.pixels 100 400) (Point2d.pixels 700 600)

        rect2 =
            Rectangle2d.from (Point2d.pixels 100 100) (Point2d.pixels 700 300)
    in
    Drawing2d.draw
        { viewBox = Rectangle2d.from Point2d.origin (Point2d.pixels 800 700)
        , entities =
            [ Drawing2d.group
                [ Drawing2d.whiteText
                , Drawing2d.anchorAtCenter
                , Drawing2d.fontSize (Pixels.float 96)
                ]
                [ Drawing2d.group [ Drawing2d.crosshairCursor ]
                    [ Drawing2d.rectangle [ Drawing2d.fillColor Color.red ] rect1
                    , Drawing2d.text [] (Rectangle2d.centerPoint rect1) "BORING"
                    ]
                , Drawing2d.group [ Drawing2d.bestCursorEver ]
                    [ Drawing2d.rectangle [ Drawing2d.fillColor Color.green ] rect2
                    , Drawing2d.text [] (Rectangle2d.centerPoint rect2) "AWESOME"
                    ]
                ]
            ]
        }
