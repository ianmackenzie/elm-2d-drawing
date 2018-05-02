module Gradients exposing (..)

import AnimationFrame
import Arc2d
import Axis2d exposing (Axis2d)
import BoundingBox2d exposing (BoundingBox2d)
import Circle2d
import Color
import Direction2d
import Drawing2d
import Drawing2d.Attributes as Attributes
import Geometry.Parameter as Parameter
import Html exposing (Html)
import Html.Events
import Point2d exposing (Point2d)
import Rectangle2d exposing (Rectangle2d)
import Time


type alias Model =
    { angle : Float
    , running : Bool
    }


type Msg
    = Tick Float
    | Toggle


rotationPerSecond : Float
rotationPerSecond =
    degrees 45


update : Msg -> Model -> ( Model, Cmd Msg )
update message model =
    case message of
        Tick time ->
            ( { model | angle = model.angle + rotationPerSecond * Time.inSeconds time }
            , Cmd.none
            )

        Toggle ->
            ( { model | running = not model.running }, Cmd.none )


renderBounds : BoundingBox2d
renderBounds =
    BoundingBox2d.fromExtrema
        { minX = 0
        , minY = 0
        , maxX = 500
        , maxY = 500
        }


square : Rectangle2d
square =
    Rectangle2d.fromExtrema
        { minX = 50
        , minY = 50
        , maxX = 450
        , maxY = 450
        }


centerPoint : Point2d
centerPoint =
    Rectangle2d.centerPoint square


diagonalAxis : Axis2d
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
            Circle2d.toArc (Circle2d.withRadius 120 centerPoint)

        points =
            Arc2d.pointsOn arc (Parameter.numSteps 12 |> List.drop 1)
    in
    Drawing2d.toHtml renderBounds
        []
        [ Drawing2d.rectangle square
        , Drawing2d.groupWith
            [ diagonalGradientAttribute
            , Attributes.dotRadius 50
            ]
            [ Drawing2d.dots points
                |> Drawing2d.rotateAround centerPoint angle
            ]
        ]


view : Model -> Html Msg
view model =
    Html.div []
        [ example1
        , example2
        , example3 model.angle
        , Html.button [ Html.Events.onClick Toggle ] [ Html.text "Toggle" ]
        ]


subscriptions : Model -> Sub Msg
subscriptions model =
    if model.running then
        AnimationFrame.diffs Tick
    else
        Sub.none


main : Program Never Model Msg
main =
    Html.program
        { init = ( { angle = 0, running = True }, Cmd.none )
        , update = update
        , view = view
        , subscriptions = subscriptions
        }
