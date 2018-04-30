module GradientExample exposing (..)

import BoundingBox2d
import Color
import Drawing2d
import Drawing2d.Attributes as Attributes
import Drawing2d.Text as Text
import Html exposing (Html)
import Html.Events
import LineSegment2d
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
                { minX = 0
                , maxX = 800
                , minY = 0
                , maxY = 800
                }

        rectangle =
            Rectangle2d.fromExtrema
                { minX = 100
                , maxX = 700
                , minY = 100
                , maxY = 700
                }

        lowerLeftCorner =
            Point2d.fromCoordinates ( 100, 100 )

        p1 =
            Point2d.fromCoordinates ( 300, 300 )

        p2 =
            Point2d.fromCoordinates ( 500, 500 )

        gradientLine =
            LineSegment2d.from p1 p2

        box =
            Drawing2d.group
                [ Drawing2d.rectangleWith
                    [ Attributes.gradientFillFrom
                        ( p1, Color.red )
                        ( p2, Color.blue )
                    ]
                    rectangle
                , Drawing2d.lineSegment gradientLine
                , Drawing2d.dot p1
                , Drawing2d.dot p2
                , Drawing2d.textWith
                    [ Attributes.textAnchor Text.topLeft
                    , Attributes.fontSize 20
                    ]
                    lowerLeftCorner
                    "lower left"
                ]

        rendered =
            if model.transform then
                box
                    |> Drawing2d.scaleAbout lowerLeftCorner 0.5
                    |> Drawing2d.rotateAround lowerLeftCorner (degrees 30)
            else
                box
    in
    Html.div []
        [ Drawing2d.toHtml renderBounds [] [ rendered ]
        , Html.button [ Html.Events.onClick ToggleTransform ]
            [ Html.text "Toggle transform " ]
        ]


main : Program Never Model Msg
main =
    Html.beginnerProgram
        { model = { transform = False }
        , update = update
        , view = view
        }