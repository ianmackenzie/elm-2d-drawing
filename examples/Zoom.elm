module Zoom exposing (main)

import Browser
import Browser.Events
import Circle2d exposing (Circle2d)
import Color
import Drawing2d
import Drawing2d.Wheel as Wheel
import Html exposing (Html)
import Json.Decode as Decode
import Pixels exposing (Pixels)
import Point2d exposing (Point2d)
import Rectangle2d exposing (Rectangle2d)
import Vector2d


type DrawingCoordinates
    = DrawingCoordinates


type alias Model =
    { center : Point2d Pixels DrawingCoordinates
    , scale : Float
    }


viewBox : Rectangle2d Pixels DrawingCoordinates
viewBox =
    Rectangle2d.from Point2d.origin (Point2d.pixels 600 600)


type Msg
    = WheelEvent (Point2d Pixels DrawingCoordinates) Wheel.Delta
    | KeyDown String


init : () -> ( Model, Cmd Msg )
init () =
    ( { center = Rectangle2d.centerPoint viewBox
      , scale = 1
      }
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        WheelEvent point wheelDelta ->
            let
                deltaY =
                    Wheel.inPixels wheelDelta

                zoomScale =
                    1.05 ^ (-deltaY / 100)
            in
            ( { model
                | center = Point2d.scaleAbout point zoomScale model.center
                , scale = zoomScale * model.scale
              }
            , Cmd.none
            )

        KeyDown "f" ->
            ( { model | center = Rectangle2d.centerPoint viewBox, scale = 1 }, Cmd.none )

        KeyDown _ ->
            ( model, Cmd.none )


view : Model -> Html Msg
view { center, scale } =
    Drawing2d.draw
        { viewBox = viewBox
        , entities =
            [ Drawing2d.group [ Drawing2d.crosshairCursor, Drawing2d.onWheel WheelEvent ]
                [ Drawing2d.rectangle [ Drawing2d.noBorder, Drawing2d.whiteFill ] viewBox
                , Drawing2d.group [ Drawing2d.strokedBorder ]
                    [ Drawing2d.circle [ Drawing2d.strokeColor Color.darkBlue, Drawing2d.fillColor Color.blue ] (Circle2d.atPoint (Point2d.pixels 200 200) (Pixels.float 50))
                    , Drawing2d.circle [ Drawing2d.strokeColor Color.darkOrange, Drawing2d.fillColor Color.orange ] (Circle2d.atPoint (Point2d.pixels 400 200) (Pixels.float 50))
                    , Drawing2d.circle [ Drawing2d.strokeColor Color.darkGreen, Drawing2d.fillColor Color.green ] (Circle2d.atPoint (Point2d.pixels 200 400) (Pixels.float 50))
                    , Drawing2d.circle [ Drawing2d.strokeColor Color.darkPurple, Drawing2d.fillColor Color.purple ] (Circle2d.atPoint (Point2d.pixels 400 400) (Pixels.float 50))
                    ]
                    |> Drawing2d.translateBy (Vector2d.from (Rectangle2d.centerPoint viewBox) center)
                    |> Drawing2d.scaleAbout center scale
                , Drawing2d.rectangle
                    [ Drawing2d.noFill
                    , Drawing2d.strokedBorder
                    , Drawing2d.blackStroke
                    , Drawing2d.strokeWidth (Pixels.float 2)
                    ]
                    viewBox
                ]
            ]
        }


subscriptions : Model -> Sub Msg
subscriptions model =
    Browser.Events.onKeyDown (Decode.map KeyDown (Decode.field "key" Decode.string))


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }
