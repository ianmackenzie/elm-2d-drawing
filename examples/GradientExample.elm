module GradientExample exposing (main)

import Angle
import BoundingBox2d
import Browser
import Color
import Common exposing (dot)
import Drawing2d
import Html exposing (Html)
import Html.Events
import LineSegment2d
import Pixels exposing (pixels)
import Point2d
import Rectangle2d
import Vector2d


type alias Model =
    { transform : Bool
    }


type Msg
    = ToggleTransform


update : Msg -> Model -> Model
update ToggleTransform model =
    { model | transform = not model.transform }


view : Model -> Html Msg
view model =
    let
        viewBox =
            Rectangle2d.from Point2d.origin (Point2d.pixels 800 800)

        lowerLeftCorner =
            Point2d.pixels 100 100

        upperRightCorner =
            Point2d.pixels 700 700

        gradientStartPoint =
            Point2d.pixels 300 300

        gradientEndPoint =
            Point2d.pixels 500 500

        gradientLine =
            LineSegment2d.from gradientStartPoint gradientEndPoint

        box =
            Drawing2d.group []
                [ Drawing2d.rectangle
                    [ Drawing2d.fillGradient <|
                        Drawing2d.gradientFrom
                            ( gradientStartPoint, Color.red )
                            ( gradientEndPoint, Color.blue )
                    , Drawing2d.dropShadow
                        { radius = pixels 12
                        , offset = Vector2d.pixels 6 -6
                        , color = Color.black
                        }
                    ]
                    (Rectangle2d.from lowerLeftCorner upperRightCorner)
                , Drawing2d.lineSegment [] gradientLine
                , dot gradientStartPoint
                , dot gradientEndPoint
                , Drawing2d.text [ Drawing2d.anchorAtTopLeft ]
                    lowerLeftCorner
                    "Click to toggle transform"
                ]

        rendered =
            if model.transform then
                box
                    |> Drawing2d.scaleAbout lowerLeftCorner 0.5
                    |> Drawing2d.rotateAround lowerLeftCorner (Angle.degrees 30)

            else
                box

        backgroundGradient =
            Drawing2d.gradientFrom
                ( Point2d.origin, Color.green )
                ( Point2d.pixels 0 800, Color.blue )
    in
    Html.div [ Html.Events.onClick ToggleTransform ]
        [ Drawing2d.draw
            { viewBox = viewBox
            , entities =
                [ Drawing2d.rectangle [ Drawing2d.fillGradient backgroundGradient ] viewBox
                , Drawing2d.group [ Drawing2d.fontSize (Pixels.float 20) ] [ rendered ]
                ]
            }
        ]


main : Program () Model Msg
main =
    Browser.sandbox
        { init = { transform = False }
        , update = update
        , view = view
        }
