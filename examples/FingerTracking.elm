module FingerTracking exposing (main)

import Browser
import Color exposing (Color)
import Dict exposing (Dict)
import Drawing2d
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
import Rectangle2d exposing (Rectangle2d)


type DrawingCoordinates
    = DrawingCoordinates


type alias TouchPoint =
    { color : Color
    , position : Point2d Pixels DrawingCoordinates
    }


type alias Model =
    { touchPoints : Dict Int TouchPoint
    , touchInteraction : Maybe (TouchInteraction Pixels DrawingCoordinates)
    , randomSeed : Random.Seed
    }


type Msg
    = TouchStart (Dict Int (Point2d Pixels DrawingCoordinates)) (TouchInteraction Pixels DrawingCoordinates)
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
            { model | touchInteraction = Nothing, touchPoints = Dict.empty }


startInteraction : TouchInteraction Pixels DrawingCoordinates -> Model -> Model
startInteraction touchInteraction model =
    { model | touchInteraction = Just touchInteraction }


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


view : Model -> Html Msg
view model =
    let
        viewBox =
            Rectangle2d.from Point2d.origin (Point2d.pixels 800 600)

        attributes =
            case model.touchInteraction of
                Nothing ->
                    [ Drawing2d.onTouchStart TouchStart ]

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
                    Drawing2d.draw
                        { viewBox = viewBox
                        , entities =
                            [ Drawing2d.group attributes
                                (List.map drawPoint (Dict.values model.touchPoints))
                            ]
                        }
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


drawPoint : TouchPoint -> Drawing2d.Entity Pixels DrawingCoordinates Msg
drawPoint point =
    let
        { x, y } =
            Point2d.toPixels point.position
    in
    Drawing2d.group [ Drawing2d.strokeColor point.color, Drawing2d.strokeWidth (pixels 4) ] <|
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
