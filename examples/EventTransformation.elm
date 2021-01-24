module EventTransformation exposing (main)

import Angle exposing (Angle)
import Browser
import Circle2d exposing (Circle2d)
import Color
import Direction2d exposing (Direction2d)
import Drawing2d
import Drawing2d.MouseInteraction as MouseInteraction exposing (MouseInteraction)
import Frame2d exposing (Frame2d)
import Html exposing (Html)
import Length exposing (Length, Meters)
import LineSegment2d exposing (LineSegment2d)
import Pixels exposing (Pixels)
import Point2d exposing (Point2d)
import Quantity exposing (Quantity, Rate)
import Rectangle2d exposing (Rectangle2d)
import Vector2d exposing (Vector2d)


type DrawingCoordinates
    = DrawingCoordinates


type SurfaceCoordinates
    = SurfaceCoordinates


type alias DrawingPoint =
    Point2d Pixels DrawingCoordinates


type alias SurfacePoint =
    Point2d Meters SurfaceCoordinates


type alias DrawingInteraction =
    MouseInteraction Pixels DrawingCoordinates


type alias SurfaceInteraction =
    MouseInteraction Meters SurfaceCoordinates


type Drag
    = MoveScreen
        { lastPoint : DrawingPoint
        , interaction : DrawingInteraction
        }
    | ScaleRotateScreen
        { lastPoint : DrawingPoint
        , interaction : DrawingInteraction
        }
    | DrawLine
        { startPoint : SurfacePoint
        , currentPoint : SurfacePoint
        , interaction : SurfaceInteraction
        }


type alias Model =
    { currentDrag : Maybe Drag
    , surfaceFrame : Frame2d Pixels DrawingCoordinates { defines : SurfaceCoordinates }
    , surfaceScale : Quantity Float (Rate Pixels Meters)
    , lines : List (LineSegment2d Meters SurfaceCoordinates)
    }


type Msg
    = MoveScreenMouseDown DrawingPoint DrawingInteraction
    | ScaleRotateScreenMouseDown DrawingPoint DrawingInteraction
    | DrawLineMouseDown SurfacePoint SurfaceInteraction
    | DrawingMouseMove DrawingPoint
    | SurfaceMouseMove SurfacePoint
    | MouseUp


main : Program () Model Msg
main =
    Browser.element
        { init = \() -> ( init, Cmd.none )
        , update = \msg model -> ( update msg model, Cmd.none )
        , subscriptions = subscriptions
        , view = view
        }


init : Model
init =
    { currentDrag = Nothing
    , surfaceFrame = Frame2d.atPoint (Point2d.pixels 200 150)
    , surfaceScale = Pixels.float 100 |> Quantity.per Length.meter
    , lines = []
    }


update : Msg -> Model -> Model
update message model =
    case message of
        MoveScreenMouseDown startPoint interaction ->
            { model
                | currentDrag =
                    Just <|
                        MoveScreen
                            { lastPoint = startPoint
                            , interaction = interaction
                            }
            }

        ScaleRotateScreenMouseDown startPoint interaction ->
            { model
                | currentDrag =
                    Just <|
                        ScaleRotateScreen
                            { lastPoint = startPoint
                            , interaction = interaction
                            }
            }

        DrawLineMouseDown startPoint interaction ->
            { model
                | currentDrag =
                    Just <|
                        DrawLine
                            { startPoint = startPoint
                            , currentPoint = startPoint
                            , interaction = interaction
                            }
            }

        DrawingMouseMove newPoint ->
            case model.currentDrag of
                Just (MoveScreen { lastPoint, interaction }) ->
                    let
                        displacement =
                            Vector2d.from lastPoint newPoint

                        updatedFrame =
                            model.surfaceFrame |> Frame2d.translateBy displacement
                    in
                    { model
                        | surfaceFrame = updatedFrame
                        , currentDrag =
                            Just <|
                                MoveScreen
                                    { lastPoint = newPoint
                                    , interaction = interaction
                                    }
                    }

                Just (ScaleRotateScreen { lastPoint, interaction }) ->
                    let
                        originPoint =
                            Frame2d.originPoint model.surfaceFrame

                        scaleFactor =
                            Quantity.ratio
                                (Point2d.distanceFrom originPoint newPoint)
                                (Point2d.distanceFrom originPoint lastPoint)

                        rotationAngle =
                            Maybe.withDefault (Angle.degrees 0) <|
                                Maybe.map2 Direction2d.angleFrom
                                    (Direction2d.from originPoint lastPoint)
                                    (Direction2d.from originPoint newPoint)

                        updatedFrame =
                            model.surfaceFrame |> Frame2d.rotateBy rotationAngle

                        updatedScale =
                            model.surfaceScale |> Quantity.multiplyBy scaleFactor
                    in
                    { model
                        | surfaceFrame = updatedFrame
                        , surfaceScale = updatedScale
                        , currentDrag =
                            Just <|
                                ScaleRotateScreen
                                    { lastPoint = newPoint
                                    , interaction = interaction
                                    }
                    }

                Just (DrawLine _) ->
                    -- TODO
                    model

                Nothing ->
                    model

        SurfaceMouseMove newPoint ->
            case model.currentDrag of
                Just (MoveScreen _) ->
                    model

                Just (ScaleRotateScreen _) ->
                    model

                Just (DrawLine { startPoint, currentPoint, interaction }) ->
                    { model
                        | currentDrag =
                            Just <|
                                DrawLine
                                    { startPoint = startPoint
                                    , currentPoint = newPoint
                                    , interaction = interaction
                                    }
                    }

                Nothing ->
                    model

        MouseUp ->
            case model.currentDrag of
                Just (MoveScreen _) ->
                    { model | currentDrag = Nothing }

                Just (ScaleRotateScreen _) ->
                    { model | currentDrag = Nothing }

                Just (DrawLine { startPoint, currentPoint, interaction }) ->
                    { model
                        | currentDrag = Nothing
                        , lines = LineSegment2d.from startPoint currentPoint :: model.lines
                    }

                Nothing ->
                    model


subscriptions : Model -> Sub Msg
subscriptions model =
    case model.currentDrag of
        Nothing ->
            Sub.none

        Just (MoveScreen { interaction }) ->
            Sub.batch
                [ MouseInteraction.onMove DrawingMouseMove interaction
                , MouseInteraction.onEnd MouseUp interaction
                ]

        Just (ScaleRotateScreen { interaction }) ->
            Sub.batch
                [ MouseInteraction.onMove DrawingMouseMove interaction
                , MouseInteraction.onEnd MouseUp interaction
                ]

        Just (DrawLine { interaction }) ->
            Sub.batch
                [ MouseInteraction.onMove SurfaceMouseMove interaction
                , MouseInteraction.onEnd MouseUp interaction
                ]


view : Model -> Html Msg
view model =
    Html.div []
        [ Drawing2d.draw
            { viewBox = Rectangle2d.from Point2d.origin (Point2d.pixels 800 600)
            , entities =
                [ drawLines model
                    |> Drawing2d.at model.surfaceScale
                    |> Drawing2d.placeIn model.surfaceFrame
                , drawOutline model
                ]
            }
        , Html.ul []
            [ Html.li [] [ Html.text "Drag blue circle to move" ]
            , Html.li [] [ Html.text "Drag orange circle to scale/rotate" ]
            , Html.li [] [ Html.text "Drag within grey rectangle to draw lines" ]
            ]
        ]


surfaceRectangle : Rectangle2d Meters SurfaceCoordinates
surfaceRectangle =
    Rectangle2d.from Point2d.origin (Point2d.meters 4 3)


drawOutline : Model -> Drawing2d.Entity Pixels DrawingCoordinates Msg
drawOutline model =
    let
        cornerPoint =
            Rectangle2d.interpolate surfaceRectangle 1 1
                |> Point2d.at model.surfaceScale
                |> Point2d.placeIn model.surfaceFrame
    in
    Drawing2d.group []
        [ Drawing2d.rectangle [ Drawing2d.blackStroke, Drawing2d.noFill ] surfaceRectangle
            |> Drawing2d.at model.surfaceScale
            |> Drawing2d.placeIn model.surfaceFrame
        , Drawing2d.circle
            [ Drawing2d.blackStroke
            , Drawing2d.fillColor Color.blue
            , Drawing2d.onLeftMouseDown MoveScreenMouseDown
            ]
            (Circle2d.atPoint (Frame2d.originPoint model.surfaceFrame) (Pixels.float 8))
        , Drawing2d.circle
            [ Drawing2d.blackStroke
            , Drawing2d.fillColor Color.orange
            , Drawing2d.onLeftMouseDown ScaleRotateScreenMouseDown
            ]
            (Circle2d.atPoint cornerPoint (Pixels.float 8))
        ]


drawLines : Model -> Drawing2d.Entity Meters SurfaceCoordinates Msg
drawLines model =
    let
        allLines =
            case model.currentDrag of
                Just (DrawLine { startPoint, currentPoint }) ->
                    LineSegment2d.from startPoint currentPoint :: model.lines

                _ ->
                    model.lines
    in
    Drawing2d.group [ Drawing2d.onLeftMouseDown DrawLineMouseDown ]
        [ Drawing2d.rectangle
            [ Drawing2d.noBorder
            , Drawing2d.fillColor Color.lightGrey
            ]
            surfaceRectangle
        , Drawing2d.group
            [ Drawing2d.strokeColor Color.darkGreen
            , Drawing2d.strokeWidth (Length.centimeters 4)
            , Drawing2d.roundStrokeCaps
            ]
            (List.map (Drawing2d.lineSegment []) allLines)
        ]
