module EventHandling exposing (main)

import Angle
import BoundingBox2d exposing (BoundingBox2d)
import Browser
import Color
import Dict exposing (Dict)
import Drawing2d
import Drawing2d.Attributes as Attributes
import Drawing2d.Events as Events
import Drawing2d.Gradient as Gradient
import Drawing2d.MouseInteraction exposing (MouseInteraction)
import Drawing2d.TouchInteraction as TouchInteraction exposing (TouchInteraction)
import Duration exposing (Duration)
import Html exposing (Html)
import Json.Decode as Decode
import LineSegment2d
import Pixels exposing (Pixels, inPixels, pixels)
import Point2d exposing (Point2d)
import Rectangle2d
import Triangle2d
import Vector2d


type DrawingCoordinates
    = DrawingCoordinates


type alias DrawingEvent =
    Drawing2d.Event DrawingCoordinates Msg


type alias Model =
    { messages : List String
    , touchInteraction : Maybe (TouchInteraction DrawingCoordinates)
    }


type Msg
    = LeftClick Int (Point2d Pixels DrawingCoordinates)
    | RightClick Int (Point2d Pixels DrawingCoordinates)
    | LeftMouseUp Int
    | RightMouseUp Int
    | LeftMouseDown Int (Point2d Pixels DrawingCoordinates)
    | RightMouseDown Int (Point2d Pixels DrawingCoordinates)
    | TouchStart Int (Dict Int (Point2d Pixels DrawingCoordinates)) (TouchInteraction DrawingCoordinates)
    | TouchEnd Int Duration
    | TouchChange Int (Dict Int (Point2d Pixels DrawingCoordinates))


logString : Msg -> String
logString message =
    case message of
        TouchStart id points _ ->
            "TouchStart " ++ String.fromInt id ++ " <" ++ String.fromInt (Dict.size points) ++ " point(s)>"

        TouchChange id points ->
            "TouchChange " ++ String.fromInt id ++ " <" ++ String.fromInt (Dict.size points) ++ " point(s)>"

        _ ->
            Debug.toString message


eventHandlers : Int -> Model -> List (Drawing2d.Attribute Pixels DrawingCoordinates DrawingEvent)
eventHandlers id model =
    let
        constantHandlers =
            [ Events.onLeftClick (LeftClick id)
            , Events.onRightClick (RightClick id)
            , Events.onLeftMouseUp (LeftMouseUp id)
            , Events.onRightMouseUp (RightMouseUp id)
            , Events.onLeftMouseDown (\point interaction -> LeftMouseDown id point)
            , Events.onRightMouseDown (\point interaction -> RightMouseDown id point)
            , Events.onTouchStart (TouchStart id)
            ]
    in
    case model.touchInteraction of
        Just interaction ->
            let
                touchMoveHandler =
                    interaction |> TouchInteraction.onChange (TouchChange id)

                touchEndHandler =
                    interaction |> TouchInteraction.onEnd (TouchEnd id)
            in
            touchMoveHandler :: touchEndHandler :: constantHandlers

        Nothing ->
            constantHandlers


view : Model -> Html Msg
view model =
    let
        rectangle =
            Rectangle2d.with
                { x1 = pixels 0
                , x2 = pixels 300
                , y1 = pixels 0
                , y2 = pixels 200
                }

        dropShadow =
            Attributes.dropShadow
                { radius = pixels 8
                , color = Color.darkGrey
                , offset = Vector2d.pixels 2 -4
                }

        rectangle1 =
            Drawing2d.rectangle [] rectangle

        centerPoint =
            Point2d.pixels 150 100

        rectangle2 =
            rectangle1
                |> Drawing2d.rotateAround centerPoint (Angle.degrees 30)
                |> Drawing2d.scaleAbout centerPoint (3 / 4)
                |> Drawing2d.translateBy (Vector2d.pixels 250 100)

        rectangle3 =
            rectangle2
                |> Drawing2d.rotateAround Point2d.origin (Angle.degrees 30)
                |> Drawing2d.scaleAbout Point2d.origin (2 / 3)

        viewBox =
            BoundingBox2d.fromExtrema
                { minX = pixels -10
                , minY = pixels -10
                , maxX = pixels 800
                , maxY = pixels 400
                }

        messageLine message =
            Html.div [] [ Html.text message ]
    in
    Html.div []
        [ Drawing2d.toHtml { viewBox = viewBox, size = Drawing2d.fixed }
            [ Attributes.strokeColor Color.black
            , Attributes.fillColor Color.white
            ]
            [ rectangle1 |> Drawing2d.addAttributes (dropShadow :: eventHandlers 1 model)
            , rectangle2 |> Drawing2d.addAttributes (dropShadow :: eventHandlers 2 model)
            , rectangle3 |> Drawing2d.addAttributes (dropShadow :: eventHandlers 3 model)
            ]
        , Html.div [] (List.map messageLine model.messages)
        ]


update : Msg -> Model -> ( Model, Cmd Msg )
update message model =
    let
        updatedModel =
            case message of
                TouchStart id points interaction ->
                    { model | touchInteraction = Just interaction }

                TouchEnd id duration ->
                    { model | touchInteraction = Nothing }

                _ ->
                    model
    in
    ( { updatedModel | messages = model.messages ++ [ logString message ] }
    , Cmd.none
    )


main : Program () Model Msg
main =
    Browser.document
        { init = always ( { messages = [], touchInteraction = Nothing }, Cmd.none )
        , update = update
        , view =
            \model ->
                { title = "EventHandling"
                , body = [ view model ]
                }
        , subscriptions = always Sub.none
        }
