module SizeTesting exposing (main)

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


type alias DrawingEvent =
    Drawing2d.Event Pixels DrawingCoordinates Msg


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


scene : List (Point2d Pixels DrawingCoordinates) -> List (Drawing2d.Element Pixels DrawingCoordinates DrawingEvent)
scene points =
    [ Drawing2d.circle [] (Circle2d.atOrigin (Pixels.float 90))
    , Drawing2d.text [ Drawing2d.textAnchor Drawing2d.center ] Point2d.origin "Text"
    , Drawing2d.group [] <|
        (points |> List.map (\point -> Drawing2d.circle [ Drawing2d.fillColor Color.blue ] (Circle2d.atPoint point (Pixels.float 3))))
    ]


onClick : Drawing2d.Attribute Pixels DrawingCoordinates DrawingEvent
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

                Fit ->
                    Element.px 400

                FitWidth ->
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
    | Fit
    | FitWidth


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

        Fit ->
            Drawing2d.fit

        FitWidth ->
            Drawing2d.fitWidth


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
                , Fit
                , FitWidth
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

                                    Fit ->
                                        "Drawing2d.fit"

                                    FitWidth ->
                                        "Drawing2d.fitWidth"
                  }
                , { header = Element.text "Small"
                  , width = Element.px 500
                  , view =
                        \size ->
                            cell size <|
                                Drawing2d.toHtml
                                    { size = toDrawingSize size
                                    , strokeWidth = Pixels.float 1
                                    , fontSize = Pixels.float 16
                                    , viewBox = viewBox
                                    , attributes = [ onClick ]
                                    , elements = scene model.points
                                    }
                  }
                , { header = Element.text "Large"
                  , width = Element.px 500
                  , view =
                        \size ->
                            cell size <|
                                Drawing2d.toHtml
                                    { size = toDrawingSize size
                                    , viewBox = viewBox
                                    , strokeWidth = Pixels.float 5
                                    , fontSize = Pixels.float 32
                                    , attributes = [ onClick ]
                                    , elements = scene model.points
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
