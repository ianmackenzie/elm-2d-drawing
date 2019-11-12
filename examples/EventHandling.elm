module EventHandling exposing (main)

import Angle
import BoundingBox2d exposing (BoundingBox2d)
import Browser
import Color
import Drawing2d exposing (DrawingCoordinates)
import Drawing2d.Attributes as Attributes
import Drawing2d.Events as Events
import Drawing2d.Gradient as Gradient
import Html exposing (Html)
import LineSegment2d
import Pixels exposing (Pixels, inPixels, pixels)
import Point2d exposing (Point2d)
import Rectangle2d
import Triangle2d
import Vector2d


type RectangleCoordinates
    = RectangleCoordinates


type Msg
    = LeftClick Int (Point2d Pixels DrawingCoordinates)
    | LeftMouseUp Int (Point2d Pixels DrawingCoordinates)
    | RightClick Int (Point2d Pixels DrawingCoordinates)


view : Html Msg
view =
    let
        rectangle =
            Rectangle2d.with
                { x1 = pixels 0
                , x2 = pixels 300
                , y1 = pixels 0
                , y2 = pixels 200
                }

        rectangle1 =
            Drawing2d.rectangle [] rectangle

        centerPoint =
            Point2d.pixels 150 100

        rectangle2 =
            rectangle1
                |> Drawing2d.rotateAround centerPoint (Angle.degrees 30)
                |> Drawing2d.scaleAbout centerPoint (3 / 4)
                |> Drawing2d.translateBy (Vector2d.pixels 250 100)

        rectangle3 =
            rectangle2
                |> Drawing2d.rotateAround Point2d.origin (Angle.degrees 30)
                |> Drawing2d.scaleAbout Point2d.origin (2 / 3)

        viewBox =
            BoundingBox2d.fromExtrema
                { minX = pixels -10
                , minY = pixels -10
                , maxX = pixels 800
                , maxY = pixels 400
                }
    in
    Drawing2d.toHtml { viewBox = viewBox, size = Drawing2d.fixed }
        []
        [ Attributes.strokeColor Color.black
        , Attributes.fillColor Color.white
        ]
        [ rectangle1 |> Drawing2d.with [ Events.onLeftClick (LeftClick 1), Events.onLeftMouseUp (LeftMouseUp 1), Events.onRightMouseUp (RightClick 1) ]
        , rectangle2 |> Drawing2d.with [ Events.onLeftClick (LeftClick 2), Events.onLeftMouseUp (LeftMouseUp 2), Events.onRightMouseUp (RightClick 2) ]
        , rectangle3 |> Drawing2d.with [ Events.onLeftClick (LeftClick 3), Events.onLeftMouseUp (LeftMouseUp 3), Events.onRightMouseUp (RightClick 3) ]
        ]


update : Msg -> () -> ( (), Cmd Msg )
update message () =
    let
        _ =
            Debug.log "Message" message
    in
    ( (), Cmd.none )


main : Program () () Msg
main =
    Browser.document
        { init = always ( (), Cmd.none )
        , update = update
        , view =
            always
                { title = "EventHandling"
                , body = [ view ]
                }
        , subscriptions = always Sub.none
        }