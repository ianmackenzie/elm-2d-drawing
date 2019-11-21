module FingerTracking exposing (main)

import BoundingBox2d exposing (BoundingBox2d)
import Browser
import Color exposing (Color)
import Dict exposing (Dict)
import Drawing2d
import Drawing2d.Attributes as Attributes
import Drawing2d.Events as Events
import Drawing2d.MouseInteraction as MouseInteraction exposing (MouseInteraction)
import Drawing2d.TouchInteraction as TouchInteraction exposing (TouchInteraction)
import Element
import Element.Border
import Html exposing (Html)
import Html.Attributes
import LineSegment2d exposing (LineSegment2d)
import Pixels exposing (Pixels, inPixels, pixels)
import Point2d exposing (Point2d)
import Quantity exposing (Quantity)
import Random


type DrawingCoordinates
    = DrawingCoordinates


type alias DrawingEvent =
    Drawing2d.Event DrawingCoordinates Msg


type alias TouchPoint =
    { color : Color
    , position : Point2d Pixels DrawingCoordinates
    }


type alias Model =
    { touchPoints : Dict Int TouchPoint
    , touchInteraction : Maybe (TouchInteraction DrawingCoordinates)
    , randomSeed : Random.Seed
    }


type Msg
    = TouchStart (Dict Int (Point2d Pixels DrawingCoordinates)) (TouchInteraction DrawingCoordinates)
    | TouchChange (Dict Int (Point2d Pixels DrawingCoordinates))
    | TouchEnd


init : () -> ( Model, Cmd Msg )
init () =
    ( { touchPoints = Dict.empty
      , touchInteraction = Nothing
      , randomSeed = Random.initialSeed 1234 -- the one true random seed
      }
    , Cmd.none
    )


update : Msg -> Model -> Model
update message model =
    case message of
        TouchStart points touchInteraction ->
            Dict.foldl startTouch model points |> startInteraction touchInteraction

        TouchChange newPoints ->
            Dict.merge endTouch moveTouch startTouch model.touchPoints newPoints model

        TouchEnd ->
            Dict.foldl endTouch model model.touchPoints |> endInteraction


colorGenerator : Random.Generator Color
colorGenerator =
    Random.map3 Color.hsl (Random.float 0 1) (Random.float 0 1) (Random.float 0.25 0.75)


startTouch : Int -> Point2d Pixels DrawingCoordinates -> Model -> Model
startTouch identifier position model =
    let
        ( generatedColor, updatedSeed ) =
            Random.step colorGenerator model.randomSeed

        updatedTouchPoints =
            Dict.insert identifier { color = generatedColor, position = position } model.touchPoints
    in
    { model | randomSeed = updatedSeed, touchPoints = updatedTouchPoints }


moveTouch : Int -> TouchPoint -> Point2d Pixels DrawingCoordinates -> Model -> Model
moveTouch identifier currentPoint newPosition model =
    let
        updatedTouchPoints =
            model.touchPoints |> Dict.insert identifier { currentPoint | position = newPosition }
    in
    { model | touchPoints = updatedTouchPoints }


endTouch : Int -> TouchPoint -> Model -> Model
endTouch identifier touchPoint model =
    { model | touchPoints = Dict.remove identifier model.touchPoints }


startInteraction : TouchInteraction DrawingCoordinates -> Model -> Model
startInteraction touchInteraction model =
    { model | touchInteraction = Just touchInteraction }


endInteraction : Model -> Model
endInteraction model =
    { model | touchInteraction = Nothing, touchPoints = Dict.empty }


view : Model -> Html Msg
view model =
    let
        viewBox =
            BoundingBox2d.fromExtrema
                { minX = pixels 0
                , minY = pixels 0
                , maxX = pixels 800
                , maxY = pixels 600
                }

        attributes =
            case model.touchInteraction of
                Nothing ->
                    [ Events.onTouchStart TouchStart ]

                Just touchInteraction ->
                    [ touchInteraction |> TouchInteraction.onChange TouchChange
                    , touchInteraction |> TouchInteraction.onEnd (always TouchEnd)
                    ]
    in
    Element.layout [] <|
        Element.column [ Element.paddingXY 64 0 ] <|
            [ Element.html (Html.h1 [] [ Html.text "Elm finger tracking" ])
            , Element.el [ Element.Border.width 16 ] <|
                Element.html <|
                    Drawing2d.toHtml { size = Drawing2d.fixed, viewBox = viewBox } attributes <|
                        List.map drawPoint (Dict.values model.touchPoints)
            , Element.html <|
                Html.div [ Html.Attributes.style "max-width" "816px", Html.Attributes.style "overflow-wrap" "normal", Html.Attributes.style "white-space" "normal" ]
                    [ Html.h2 [] [ Html.text "What should work" ]
                    , Html.ul []
                        [ bullet "Track multiple touch points simultaneously"
                        , bullet "Each new touch point should get a new random color"
                        ]
                    , Html.h2 [] [ Html.text "Things to look out for" ]
                    , Html.ul []
                        [ bullet "Lines not appearing at touch points"
                        , bullet "Lines not following the center of your finger"
                        , bullet "Page panning/moving instead of lines being drawn (as long as fingers start inside the drawing)"
                        , bullet "Weird behavior if a finger moves out of the drawing and then back in (should continue showing lines of the same color, unless you lift your finger while outside the drawing)"
                        , bullet "Lines changing color mid-touch"
                        ]
                    , Html.h2 [] [ Html.text "Known issues" ]
                    , Html.ul []
                        [ bullet "Doesn't work on Internet Explorer - layout is messed up, but IE doesn't seem to send touch events at all anyways =("
                        , bullet "Microsoft Edge does not seem to send touch events by default - should be able to enable them by navingating to about:flags and setting \"Enable touch events\" to \"Only on when touchscreen is detected\""
                        , bullet "On iOS (at least iPad) only up to 3 fingers seem to be supported since there seems to be no way to disable the built-in 4- and 5-finger app switching gestures"
                        ]
                    , Html.p [] [ Html.text "Please report any issues to ", Html.b [] [ Html.text "@ianmackenzie" ], Html.text " on the Elm Slack!" ]
                    ]
            ]


bullet : String -> Html msg
bullet text =
    Html.li [] [ Html.text text ]


drawPoint : TouchPoint -> Drawing2d.Element Pixels DrawingCoordinates DrawingEvent
drawPoint point =
    let
        { x, y } =
            Point2d.toPixels point.position
    in
    Drawing2d.group [ Attributes.strokeColor point.color, Attributes.strokeWidth (pixels 4) ] <|
        List.map (Drawing2d.lineSegment []) <|
            [ LineSegment2d.from (Point2d.pixels x 0) (Point2d.pixels x 600)
            , LineSegment2d.from (Point2d.pixels 0 y) (Point2d.pixels 800 y)
            ]


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , update = \message model -> ( update message model, Cmd.none )
        , subscriptions = always Sub.none
        , view = view
        }
