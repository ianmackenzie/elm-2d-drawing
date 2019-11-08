module Sketching exposing (main)

import Angle
import BoundingBox2d exposing (BoundingBox2d)
import Browser
import Browser.Events
import Color exposing (Color)
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
import Polyline2d exposing (Polyline2d)
import Rectangle2d
import Triangle2d
import Vector2d


type MouseButton
    = LeftButton
    | RightButton


type Msg
    = MouseDown MouseButton (Point2d Pixels DrawingCoordinates) (Decoder (Point2d Pixels DrawingCoordinates))
    | MouseMove (Point2d Pixels DrawingCoordinates)
    | MouseUp MouseButton (Point2d Pixels DrawingCoordinates)


type DrawState
    = Drawing
        { activeButton : MouseButton
        , lastPoint : Point2d Pixels DrawingCoordinates
        , accumulatedPoints : List (Point2d Pixels DrawingCoordinates)
        , pointDecoder : Decoder (Point2d Pixels DrawingCoordinates)
        }
    | NotDrawing


type alias Model =
    { drawState : DrawState
    , lines : List ( Color, Polyline2d Pixels DrawingCoordinates )
    }


drawPolyline : ( Color, Polyline2d Pixels DrawingCoordinates ) -> Drawing2d.Element Pixels DrawingCoordinates msg
drawPolyline ( color, polyline ) =
    Drawing2d.polyline [ Attributes.strokeColor color ] polyline


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

        allLines =
            case model.drawState of
                Drawing { activeButton, accumulatedPoints } ->
                    ( lineColor activeButton
                    , Polyline2d.fromVertices accumulatedPoints
                    )
                        :: model.lines

                NotDrawing ->
                    model.lines
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
                        [ Drawing2d.onLeftMouseDown (MouseDown LeftButton)
                        , Drawing2d.onRightMouseDown (MouseDown RightButton)
                        , Drawing2d.onLeftMouseUp (MouseUp LeftButton)
                        , Drawing2d.onRightMouseUp (MouseUp RightButton)
                        ]
                        []
                        (List.map drawPolyline allLines)
                )


lineColor : MouseButton -> Color
lineColor button =
    case button of
        LeftButton ->
            Color.blue

        RightButton ->
            Color.green


update : Msg -> Model -> Model
update message model =
    case message |> Debug.log "message" of
        MouseDown whichButton point decoder ->
            case model.drawState of
                Drawing _ ->
                    model

                NotDrawing ->
                    { model
                        | drawState =
                            Drawing
                                { activeButton = whichButton
                                , lastPoint = point
                                , accumulatedPoints = [ point ]
                                , pointDecoder = decoder
                                }
                    }

        MouseMove point ->
            case model.drawState of
                Drawing currentDraw ->
                    { model
                        | drawState =
                            Drawing
                                { activeButton = currentDraw.activeButton
                                , lastPoint = point
                                , accumulatedPoints = point :: currentDraw.accumulatedPoints
                                , pointDecoder = currentDraw.pointDecoder
                                }
                    }

                NotDrawing ->
                    model

        MouseUp whichButton point ->
            case model.drawState of
                Drawing { activeButton, accumulatedPoints } ->
                    if whichButton == activeButton then
                        { model
                            | lines =
                                ( lineColor activeButton
                                , Polyline2d.fromVertices accumulatedPoints
                                )
                                    :: model.lines
                            , drawState = NotDrawing
                        }

                    else
                        model

                NotDrawing ->
                    model


subscriptions : Model -> Sub Msg
subscriptions model =
    case model.drawState of
        Drawing { activeButton, pointDecoder } ->
            Sub.batch
                [ Browser.Events.onMouseMove (Decode.map MouseMove pointDecoder)
                , Browser.Events.onMouseUp
                    (Decode.map (MouseUp activeButton) pointDecoder)
                ]

        NotDrawing ->
            Sub.none


main : Program () Model Msg
main =
    Browser.document
        { init = always ( { drawState = NotDrawing, lines = [] }, Cmd.none )
        , update = \message model -> ( update message model, Cmd.none )
        , view =
            \model ->
                { title = "Sketching"
                , body = [ view model ]
                }
        , subscriptions = subscriptions
        }
