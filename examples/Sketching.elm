module Sketching exposing (main)

import Angle
import BoundingBox2d exposing (BoundingBox2d)
import Browser
import Browser.Events
import Color exposing (Color)
import Dict exposing (Dict)
import Drawing2d
import Drawing2d.MouseInteraction as MouseInteraction exposing (MouseInteraction)
import Element
import Element.Border
import Html exposing (Html)
import Json.Decode as Decode exposing (Decoder)
import LineSegment2d exposing (LineSegment2d)
import Pixels exposing (Pixels, inPixels, pixels)
import Point2d exposing (Point2d)
import Polyline2d exposing (Polyline2d)
import Rectangle2d
import Triangle2d
import Vector2d


type DrawingCoordinates
    = DrawingCoordinates


type alias DrawingEvent =
    Drawing2d.Event DrawingCoordinates Msg


type LineColor
    = Blue
    | Green


type Msg
    = StartDrawing LineColor (Point2d Pixels DrawingCoordinates) (MouseInteraction DrawingCoordinates)
    | MouseMove (Point2d Pixels DrawingCoordinates)
    | MouseUp
    | DrawingRightClick
    | LineRightClick Int


type DrawState
    = Drawing
        { lineColor : LineColor
        , lastPoint : Point2d Pixels DrawingCoordinates
        , accumulatedPoints : List (Point2d Pixels DrawingCoordinates)
        , mouseInteraction : MouseInteraction DrawingCoordinates
        }
    | NotDrawing


type alias Model =
    { drawState : DrawState
    , nextLineId : Int
    , linesById : Dict Int ( LineColor, Polyline2d Pixels DrawingCoordinates )
    }


toColor : LineColor -> Color
toColor lineColor =
    case lineColor of
        Blue ->
            Color.blue

        Green ->
            Color.green


drawPolyline :
    List (Drawing2d.Attribute Pixels DrawingCoordinates DrawingEvent)
    -> ( LineColor, Polyline2d Pixels DrawingCoordinates )
    -> Drawing2d.Element Pixels DrawingCoordinates DrawingEvent
drawPolyline attributes ( lineColor, polyline ) =
    Drawing2d.polyline (Drawing2d.strokeColor (toColor lineColor) :: attributes) polyline


rightClickHandler : Int -> Drawing2d.Attribute Pixels DrawingCoordinates DrawingEvent
rightClickHandler id =
    Drawing2d.onRightClick (always (LineRightClick id))


view : Model -> Html Msg
view model =
    let
        viewBox =
            BoundingBox2d.from Point2d.origin (Point2d.pixels 800 400)

        activeLine =
            case model.drawState of
                Drawing { lineColor, accumulatedPoints } ->
                    drawPolyline [] ( lineColor, Polyline2d.fromVertices accumulatedPoints )

                NotDrawing ->
                    Drawing2d.empty

        existingLines =
            Dict.toList model.linesById
                |> List.map (\( id, line ) -> drawPolyline [ rightClickHandler id ] line)

        allLines =
            activeLine :: existingLines
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
                        [ Drawing2d.onLeftMouseDown (StartDrawing Blue)
                        , Drawing2d.onRightMouseDown (StartDrawing Green)
                        , Drawing2d.onRightClick (always DrawingRightClick)
                        , Drawing2d.strokeWidth (pixels 5)
                        ]
                        allLines
                )


toggleColor : LineColor -> LineColor
toggleColor lineColor =
    case lineColor of
        Blue ->
            Green

        Green ->
            Blue


update : Msg -> Model -> Model
update message model =
    case message of
        StartDrawing lineColor point mouseInteraction ->
            case model.drawState of
                Drawing _ ->
                    model

                NotDrawing ->
                    { model
                        | drawState =
                            Drawing
                                { lineColor = lineColor
                                , lastPoint = point
                                , accumulatedPoints = [ point ]
                                , mouseInteraction = mouseInteraction
                                }
                    }

        MouseMove point ->
            case model.drawState of
                Drawing currentDraw ->
                    { model
                        | drawState =
                            Drawing
                                { lineColor = currentDraw.lineColor
                                , lastPoint = point
                                , accumulatedPoints = point :: currentDraw.accumulatedPoints
                                , mouseInteraction = currentDraw.mouseInteraction
                                }
                    }

                NotDrawing ->
                    model

        MouseUp ->
            case model.drawState of
                Drawing { lineColor, accumulatedPoints } ->
                    { model
                        | linesById =
                            model.linesById
                                |> Dict.insert model.nextLineId
                                    ( lineColor, Polyline2d.fromVertices accumulatedPoints )
                        , nextLineId = model.nextLineId + 1
                        , drawState = NotDrawing
                    }

                NotDrawing ->
                    model

        DrawingRightClick ->
            model

        LineRightClick id ->
            { model
                | linesById =
                    model.linesById
                        |> Dict.update id
                            (\entry ->
                                case entry of
                                    Just ( lineColor, polyline ) ->
                                        Just ( toggleColor lineColor, polyline )

                                    Nothing ->
                                        Nothing
                            )
            }


subscriptions : Model -> Sub Msg
subscriptions model =
    case model.drawState of
        Drawing { lineColor, mouseInteraction } ->
            Sub.batch
                [ mouseInteraction |> MouseInteraction.onMove MouseMove
                , mouseInteraction |> MouseInteraction.onEnd MouseUp
                ]

        NotDrawing ->
            Sub.none


main : Program () Model Msg
main =
    Browser.document
        { init =
            always
                ( { drawState = NotDrawing
                  , linesById = Dict.empty
                  , nextLineId = 1
                  }
                , Cmd.none
                )
        , update = \message model -> ( update message model, Cmd.none )
        , view =
            \model ->
                { title = "Sketching"
                , body = [ view model ]
                }
        , subscriptions = subscriptions
        }
