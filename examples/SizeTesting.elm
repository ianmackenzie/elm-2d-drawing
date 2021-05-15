module SizeTesting exposing (main)

import Axis2d
import Browser
import Circle2d
import Color
import Drawing2d
import Element exposing (Element)
import Element.Border
import Html exposing (Html)
import Pixels exposing (Pixels)
import Point2d exposing (Point2d)
import Quantity
import Rectangle2d exposing (Rectangle2d)


type DrawingCoordinates
    = DrawingCoordinates


type alias Model =
    { points : List (Point2d Pixels DrawingCoordinates)
    }


type Msg
    = NewPoint (Point2d Pixels DrawingCoordinates)


init : () -> ( Model, Cmd Msg )
init () =
    ( { points = [] }, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update (NewPoint point) { points } =
    ( { points = point :: points }, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


viewBox : Rectangle2d Pixels DrawingCoordinates
viewBox =
    Rectangle2d.from
        (Point2d.pixels -100 -100)
        (Point2d.pixels 100 100)


scene : List (Point2d Pixels DrawingCoordinates) -> List (Drawing2d.Entity Pixels DrawingCoordinates Msg)
scene points =
    [ Drawing2d.circle [] (Circle2d.atOrigin (Pixels.float 90))
    , Drawing2d.text [ Drawing2d.anchorAtMiddle, Drawing2d.centralBaseline ] Point2d.origin "Text"
    , Drawing2d.group [] <|
        (points |> List.map (\point -> Drawing2d.circle [ Drawing2d.fillColor Color.blue ] (Circle2d.atPoint point (Pixels.float 3))))
    ]


background : Drawing2d.Entity Pixels DrawingCoordinates Msg
background =
    Drawing2d.rectangle
        [ Drawing2d.noBorder
        , Drawing2d.fillGradient <|
            Drawing2d.gradientAlong Axis2d.x <|
                [ ( Pixels.float -51, Color.orange )
                , ( Pixels.float -50, Color.lightBlue )
                , ( Pixels.float 50, Color.lightGreen )
                , ( Pixels.float 51, Color.yellow )
                ]
        ]
        viewBox


onClick : Drawing2d.Attribute Pixels DrawingCoordinates Msg
onClick =
    Drawing2d.onLeftClick NewPoint


cell : Size -> Html msg -> Element msg
cell size html =
    Element.el
        [ Element.height <|
            case size of
                ScaleHalf ->
                    Element.shrink

                Fixed ->
                    Element.shrink

                ScaleTwo ->
                    Element.shrink

                Width100 ->
                    Element.shrink

                Width200 ->
                    Element.shrink

                Width400 ->
                    Element.shrink
        , Element.Border.width 1
        , Element.Border.color (Element.rgb255 192 192 192)
        ]
        (Element.html html)


type Size
    = ScaleHalf
    | Fixed
    | ScaleTwo
    | Width100
    | Width200
    | Width400


toDrawingSize : Size -> Drawing2d.Size Pixels
toDrawingSize size =
    case size of
        ScaleHalf ->
            Drawing2d.scale (Pixels.float 0.5 |> Quantity.per Pixels.pixel)

        Fixed ->
            Drawing2d.fixed

        ScaleTwo ->
            Drawing2d.scale (Pixels.float 2 |> Quantity.per Pixels.pixel)

        Width100 ->
            Drawing2d.width (Pixels.float 100)

        Width200 ->
            Drawing2d.width (Pixels.float 200)

        Width400 ->
            Drawing2d.width (Pixels.float 400)


view : Model -> Html Msg
view model =
    Element.layout [] <|
        Element.table []
            { data =
                [ ScaleHalf
                , Fixed
                , ScaleTwo
                , Width100
                , Width200
                , Width400
                ]
            , columns =
                [ { header = Element.none
                  , width = Element.shrink
                  , view =
                        \size ->
                            Element.text <|
                                case size of
                                    ScaleHalf ->
                                        "Drawing2d.scale 0.5"

                                    Fixed ->
                                        "Drawing2d.fixed"

                                    ScaleTwo ->
                                        "Drawing2d.scale 2"

                                    Width100 ->
                                        "Drawing2d.width (Pixels.float 100)"

                                    Width200 ->
                                        "Drawing2d.width (Pixels.float 200)"

                                    Width400 ->
                                        "Drawing2d.width (Pixels.float 400)"
                  }
                , { header = Element.text "Small"
                  , width = Element.px 500
                  , view =
                        \size ->
                            cell size <|
                                Drawing2d.custom
                                    { size = toDrawingSize size
                                    , strokeWidth = Pixels.float 1
                                    , fontSize = Pixels.float 16
                                    , viewBox = viewBox
                                    , entities =
                                        [ Drawing2d.group [ onClick ]
                                            (background :: scene model.points)
                                        ]
                                    }
                  }
                , { header = Element.text "Large"
                  , width = Element.px 500
                  , view =
                        \size ->
                            cell size <|
                                Drawing2d.custom
                                    { size = toDrawingSize size
                                    , viewBox = viewBox
                                    , strokeWidth = Pixels.float 5
                                    , fontSize = Pixels.float 32
                                    , entities =
                                        [ Drawing2d.group [ onClick ]
                                            (background :: scene model.points)
                                        ]
                                    }
                  }
                ]
            }


main : Program () Model Msg
main =
    Browser.document
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view =
            \model ->
                { title = "SizeTesting"
                , body = [ view model ]
                }
        }
