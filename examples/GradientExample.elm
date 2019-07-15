module GradientExample exposing (main)

import Angle
import BoundingBox2d
import Browser
import Color
import Common exposing (dot)
import Drawing2d
import Drawing2d.Attributes as Attributes
import Drawing2d.Gradient as Gradient
import Drawing2d.Text as Text
import Html exposing (Html)
import Html.Events
import LineSegment2d
import Pixels exposing (pixels)
import Point2d
import Rectangle2d


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
        renderBounds =
            BoundingBox2d.fromExtrema
                { minX = pixels 0
                , maxX = pixels 800
                , minY = pixels 0
                , maxY = pixels 800
                }

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
                    [ Attributes.fillGradient <|
                        Gradient.from
                            ( gradientStartPoint, Color.red )
                            ( gradientEndPoint, Color.blue )
                    ]
                    (Rectangle2d.from lowerLeftCorner upperRightCorner)
                , Drawing2d.lineSegment [] gradientLine
                , dot gradientStartPoint
                , dot gradientEndPoint
                , Drawing2d.text [ Attributes.textAnchor Text.topLeft ]
                    lowerLeftCorner
                    "lower left"
                ]

        rendered =
            if model.transform then
                box
                    |> Drawing2d.scaleAbout lowerLeftCorner 0.5
                    |> Drawing2d.rotateAround lowerLeftCorner (Angle.degrees 30)

            else
                box
    in
    Html.div []
        [ Drawing2d.toHtml renderBounds
            [ Attributes.fontSize (pixels 20) ]
            [ rendered ]
        , Html.button [ Html.Events.onClick ToggleTransform ]
            [ Html.text "Toggle transform " ]
        ]


main : Program () Model Msg
main =
    Browser.sandbox
        { init = { transform = False }
        , update = update
        , view = view
        }
