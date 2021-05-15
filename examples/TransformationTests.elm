module TransformationTests exposing (main)

import Angle
import Browser
import Circle2d
import Color
import Drawing2d
import Frame2d exposing (Frame2d)
import Html exposing (Html)
import Length exposing (Meters)
import Pixels exposing (Pixels)
import Point2d exposing (Point2d)
import Quantity
import Rectangle2d exposing (Rectangle2d)
import Svg exposing (rect)
import Vector2d


type DrawingCoordinates
    = DrawingCoordinates


type LocalCoordinates
    = LocalCoordinates


type alias Model =
    List (Point2d Meters LocalCoordinates)


type alias Msg =
    Point2d Meters LocalCoordinates


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = always Sub.none
        , view = view
        }


init : () -> ( Model, Cmd Msg )
init () =
    ( [], Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update point points =
    ( point :: points, Cmd.none )


view : Model -> Html Msg
view points =
    let
        viewBox : Rectangle2d Pixels DrawingCoordinates
        viewBox =
            Rectangle2d.from (Point2d.pixels -50 -50) (Point2d.pixels 350 350)

        globalGradient =
            Drawing2d.gradientFrom
                ( Rectangle2d.interpolate viewBox 0 0, Color.lightBlue )
                ( Rectangle2d.interpolate viewBox 1 1, Color.green )

        drawPoint position =
            Drawing2d.circle [ Drawing2d.fillColor Color.orange ]
                (Circle2d.atPoint position (Length.centimeters 3))

        resolution =
            Pixels.float 100 |> Quantity.per Length.meter

        rectangle : Rectangle2d Meters LocalCoordinates
        rectangle =
            Rectangle2d.from
                (Point2d.meters 0.5 0.5)
                (Point2d.meters 1.5 1.5)

        frame : Frame2d Pixels DrawingCoordinates { defines : LocalCoordinates }
        frame =
            Frame2d.atPoint (Point2d.pixels -50 50)
                |> Frame2d.rotateBy (Angle.degrees -10)
    in
    Drawing2d.draw
        { viewBox = viewBox
        , entities =
            [ Drawing2d.group [ Drawing2d.fillGradient globalGradient ]
                [ Drawing2d.rectangle [ Drawing2d.noBorder ] viewBox
                , Drawing2d.placeIn frame <|
                    Drawing2d.at resolution <|
                        Drawing2d.group []
                            [ Drawing2d.rectangle [ Drawing2d.onLeftClick identity ] rectangle
                                |> Drawing2d.scaleAbout (Point2d.meters 1 1) 1.5
                                |> Drawing2d.rotateAround (Point2d.meters 1 1) (Angle.degrees 30)
                                |> Drawing2d.translateBy (Vector2d.meters 0.5 0)
                            , Drawing2d.group [] (List.map drawPoint points)
                            ]
                ]
            ]
        }
