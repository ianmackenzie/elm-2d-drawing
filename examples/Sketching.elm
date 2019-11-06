module Sketching exposing (main)

import Angle
import BoundingBox2d exposing (BoundingBox2d)
import Browser
import Browser.Events
import Color
import Drawing2d exposing (DrawingCoordinates)
import Drawing2d.Attributes as Attributes
import Drawing2d.Events as Events
import Drawing2d.Gradient as Gradient
import Element
import Element.Border
import Html exposing (Html)
import Json.Decode as Decode exposing (Decoder)
import LineSegment2d exposing (LineSegment2d)
import Pixels exposing (Pixels, inPixels, pixels)
import Point2d exposing (Point2d)
import Rectangle2d
import Triangle2d
import Vector2d


type Msg
    = MouseDown (Point2d Pixels DrawingCoordinates) (Decoder (Point2d Pixels DrawingCoordinates))
    | MouseMove (Point2d Pixels DrawingCoordinates)
    | MouseUp (Point2d Pixels DrawingCoordinates)


type DrawState
    = Drawing (Point2d Pixels DrawingCoordinates) (Decoder (Point2d Pixels DrawingCoordinates))
    | NotDrawing


type alias Model =
    { drawState : DrawState
    , lines : List (LineSegment2d Pixels DrawingCoordinates)
    }


view : Model -> Html Msg
view model =
    let
        viewBox =
            BoundingBox2d.fromExtrema
                { minX = pixels 0
                , minY = pixels 0
                , maxX = pixels 800
                , maxY = pixels 400
                }
    in
    Element.layout [ Element.width Element.fill ] <|
        Element.el [ Element.padding 20 ] <|
            Element.el
                [ Element.Border.width 1
                , Element.Border.color (Element.rgb 0 0 0)
                , Element.width (Element.px 1200)
                , Element.height (Element.px 300)
                ]
                (Element.html <|
                    Drawing2d.toHtml
                        { viewBox = viewBox
                        , size = Drawing2d.fit
                        }
                        [ Drawing2d.onMouseDown MouseDown ]
                        [ Attributes.strokeColor Color.black ]
                        (List.map (Drawing2d.lineSegment []) model.lines)
                )


update : Msg -> Model -> ( Model, Cmd Msg )
update message model =
    case message of
        MouseDown point decoder ->
            ( { model | drawState = Drawing point decoder }, Cmd.none )

        MouseMove point ->
            case model.drawState of
                Drawing lastPoint decoder ->
                    ( { model
                        | drawState = Drawing point decoder
                        , lines =
                            LineSegment2d.from lastPoint point
                                :: model.lines
                      }
                    , Cmd.none
                    )

                NotDrawing ->
                    ( model, Cmd.none )

        MouseUp point ->
            case model.drawState of
                Drawing lastPoint _ ->
                    ( { model
                        | drawState = NotDrawing
                        , lines =
                            LineSegment2d.from lastPoint point
                                :: model.lines
                      }
                    , Cmd.none
                    )

                NotDrawing ->
                    ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    case model.drawState of
        Drawing lastPoint decoder ->
            Sub.batch
                [ Browser.Events.onMouseMove (Decode.map MouseMove decoder)
                , Browser.Events.onMouseUp (Decode.map MouseUp decoder)
                ]

        NotDrawing ->
            Sub.none


main : Program () Model Msg
main =
    Browser.document
        { init = always ( { drawState = NotDrawing, lines = [] }, Cmd.none )
        , update = update
        , view =
            \model ->
                { title = "Sketching"
                , body = [ view model ]
                }
        , subscriptions = subscriptions
        }
