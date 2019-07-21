module Gradients exposing (main)

import Angle exposing (Angle)
import AngularSpeed exposing (AngularSpeed)
import Arc2d
import Axis2d exposing (Axis2d)
import BoundingBox2d exposing (BoundingBox2d)
import Browser
import Browser.Events
import Circle2d
import Color
import Common exposing (dot)
import Direction2d
import Drawing2d
import Drawing2d.Attributes as Attributes
import Drawing2d.Gradient as Gradient
import Duration exposing (Duration, milliseconds, seconds)
import Html exposing (Html)
import Html.Events
import Json.Decode exposing (Value)
import Parameter1d
import Pixels exposing (Pixels, pixels)
import Point2d exposing (Point2d)
import Quantity exposing (Quantity)
import Rectangle2d exposing (Rectangle2d)


degrees =
    Angle.degrees


type Drawing
    = Drawing


type alias Model =
    { angle : Angle
    , running : Bool
    }


type Msg
    = Tick Duration
    | Toggle


angularSpeed : AngularSpeed
angularSpeed =
    degrees 45 |> Quantity.per (seconds 1)


update : Msg -> Model -> ( Model, Cmd Msg )
update message model =
    case message of
        Tick duration ->
            let
                updatedAngle =
                    model.angle |> Quantity.plus (duration |> Quantity.at angularSpeed)
            in
            ( { model | angle = updatedAngle }, Cmd.none )

        Toggle ->
            ( { model | running = not model.running }, Cmd.none )


renderBounds : BoundingBox2d Pixels Drawing
renderBounds =
    BoundingBox2d.fromExtrema
        { minX = pixels 0
        , minY = pixels 0
        , maxX = pixels 500
        , maxY = pixels 500
        }


square : Rectangle2d Pixels Drawing
square =
    Rectangle2d.fromExtrema
        { minX = pixels 50
        , minY = pixels 50
        , maxX = pixels 450
        , maxY = pixels 450
        }


centerPoint : Point2d Pixels Drawing
centerPoint =
    Rectangle2d.centerPoint square


diagonalAxis : Axis2d Pixels Drawing
diagonalAxis =
    Axis2d.through centerPoint (Direction2d.fromAngle (degrees 45))


diagonalGradientAttribute : Drawing2d.Attribute Pixels Drawing
diagonalGradientAttribute =
    Attributes.fillGradient <|
        Gradient.along diagonalAxis
            [ ( pixels -101, Color.darkBlue )
            , ( pixels -100, Color.blue )
            , ( pixels 100, Color.green )
            , ( pixels 101, Color.darkGreen )
            ]


example1 : Html Msg
example1 =
    Drawing2d.toHtml renderBounds
        []
        [ Drawing2d.rectangle [ diagonalGradientAttribute ] square ]


example2 : Html Msg
example2 =
    Drawing2d.toHtml renderBounds
        [ diagonalGradientAttribute ]
        [ Drawing2d.rectangle [] square ]


fillableCircle : Point2d Pixels coordinates -> Drawing2d.Element Pixels coordinates
fillableCircle point =
    Drawing2d.circle
        [ Attributes.blackStroke
        , Attributes.strokeWidth (pixels 1)
        ]
        (Circle2d.withRadius (pixels 64) point)


example3 : Angle -> Html Msg
example3 angle =
    let
        arc =
            Circle2d.toArc (Circle2d.withRadius (pixels 150) centerPoint)

        points =
            Parameter1d.trailing 12 (Arc2d.pointOn arc)
    in
    Drawing2d.toHtml renderBounds
        []
        [ Drawing2d.rectangle [] square
        , Drawing2d.group [ diagonalGradientAttribute ]
            [ Drawing2d.group [] (List.map fillableCircle points)
                |> Drawing2d.rotateAround centerPoint angle
            ]
        ]


view : Model -> Browser.Document Msg
view model =
    { title = "Gradients"
    , body =
        [ Html.div []
            [ example1
            , Html.div [ Html.Events.onClick Toggle ] [ example3 model.angle ]
            ]
        ]
    }


subscriptions : Model -> Sub Msg
subscriptions model =
    if model.running then
        Browser.Events.onAnimationFrameDelta (milliseconds >> Tick)

    else
        Sub.none


main : Program Value Model Msg
main =
    Browser.document
        { init = always ( { angle = Angle.degrees 0, running = True }, Cmd.none )
        , update = update
        , view = view
        , subscriptions = subscriptions
        }
