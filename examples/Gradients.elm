module Gradients exposing (main)

import Angle exposing (Angle)
import AngularSpeed
import Arc2d
import Axis2d exposing (Axis2d)
import BoundingBox2d exposing (BoundingBox2d)
import Browser.Events
import Circle2d
import Color
import Curve.ParameterValue as ParameterValue
import Direction2d
import Drawing2d
import Drawing2d.Attributes as Attributes
import Duration exposing (Duration, milliseconds, seconds)
import Html exposing (Html)
import Html.Events
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


diagonalGradientAttribute : Drawing2d.Attribute msg
diagonalGradientAttribute =
    Attributes.gradientFillAlong diagonalAxis
        [ ( -101, Color.darkBlue )
        , ( -100, Color.blue )
        , ( 100, Color.green )
        , ( 101, Color.darkGreen )
        ]


example1 : Html Msg
example1 =
    Drawing2d.toHtml renderBounds
        []
        [ Drawing2d.rectangleWith [ diagonalGradientAttribute ] square ]


example2 : Html Msg
example2 =
    Drawing2d.toHtml renderBounds
        [ diagonalGradientAttribute ]
        [ Drawing2d.rectangle square ]


example3 : Float -> Html Msg
example3 angle =
    let
        arc =
            Circle2d.toArc (Circle2d.withRadius (pixels 120) centerPoint)

        points =
            Arc2d.pointsOn arc (ParameterValue.trailing 12)
    in
    Drawing2d.toHtml renderBounds
        []
        [ Drawing2d.rectangle square
        , Drawing2d.groupWith
            [ diagonalGradientAttribute, Attributes.dotRadius (pixels 50) ]
            [ Drawing2d.dots points
                |> Drawing2d.rotateAround centerPoint angle
            ]
        ]


view : Model -> Html Msg
view model =
    Html.div []
        [ example1
        , Html.div [ Html.Events.onClick Toggle ] [ example3 model.angle ]
        ]


subscriptions : Model -> Sub Msg
subscriptions model =
    if model.running then
        Browser.Events.onAnimationFrameDelta (milliseconds >> Tick)

    else
        Sub.none


main : Program Never Model Msg
main =
    Html.program
        { init = ( { angle = degrees 0, running = True }, Cmd.none )
        , update = update
        , view = view
        , subscriptions = subscriptions
        }
