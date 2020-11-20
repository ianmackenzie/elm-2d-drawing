module FingerPainting exposing (main)

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
import Pixels exposing (Pixels, inPixels, pixels)
import Point2d exposing (Point2d)
import Polyline2d exposing (Polyline2d)
import Quantity exposing (Quantity)
import Random
import Rectangle2d exposing (Rectangle2d)


type DrawingCoordinates
    = DrawingCoordinates


type alias DrawingEvent =
    Drawing2d.Event Pixels DrawingCoordinates Msg


type alias Line =
    { index : Int
    , color : Color
    , width : Quantity Float Pixels
    , points : List (Point2d Pixels DrawingCoordinates)
    }


type alias Model =
    { currentTouchLines : Dict Int Line
    , currentTouchInteraction : Maybe (TouchInteraction Pixels DrawingCoordinates)
    , currentMouseSession :
        Maybe { line : Line, mouseInteraction : MouseInteraction Pixels DrawingCoordinates }
    , randomSeed : Random.Seed
    , lineIndex : Int
    , finishedLines : List Line
    }


type Msg
    = TouchStart (Dict Int (Point2d Pixels DrawingCoordinates)) (TouchInteraction Pixels DrawingCoordinates)
    | TouchChange (Dict Int (Point2d Pixels DrawingCoordinates))
    | TouchEnd
    | MouseDown (Point2d Pixels DrawingCoordinates) (MouseInteraction Pixels DrawingCoordinates)
    | MouseMove (Point2d Pixels DrawingCoordinates)
    | MouseUp


init : () -> ( Model, Cmd Msg )
init () =
    ( { currentTouchLines = Dict.empty
      , currentTouchInteraction = Nothing
      , currentMouseSession = Nothing
      , finishedLines = []
      , randomSeed = Random.initialSeed 1234 -- the one true random seed
      , lineIndex = 0
      }
    , Cmd.none
    )


update : Msg -> Model -> Model
update message model =
    case message of
        MouseDown point mouseInteraction ->
            { model
                | currentMouseSession =
                    Just
                        { line =
                            { index = model.lineIndex
                            , color = Color.rgb 0 0 1
                            , points = [ point ]
                            , width = pixels 4
                            }
                        , mouseInteraction = mouseInteraction
                        }
                , lineIndex = model.lineIndex + 1
                , finishedLines = []
            }

        MouseMove point ->
            case model.currentMouseSession of
                Just { line, mouseInteraction } ->
                    { model
                        | currentMouseSession =
                            Just
                                { line = { line | points = point :: line.points }
                                , mouseInteraction = mouseInteraction
                                }
                    }

                Nothing ->
                    -- shouldn't happen
                    model

        MouseUp ->
            case model.currentMouseSession of
                Just { line } ->
                    { model
                        | currentMouseSession = Nothing
                        , finishedLines = line :: model.finishedLines
                    }

                Nothing ->
                    -- shouldn't happen
                    model

        TouchStart points touchInteraction ->
            Dict.foldl startTouchLine model points
                |> startTouchInteraction touchInteraction

        TouchChange newPoints ->
            model
                |> Dict.merge
                    endTouchLine
                    extendTouchLine
                    startTouchLine
                    model.currentTouchLines
                    newPoints

        TouchEnd ->
            Dict.foldl endTouchLine model model.currentTouchLines
                |> endTouchInteraction


colorGenerator : Random.Generator Color
colorGenerator =
    Random.map4 Color.hsla
        (Random.float 0 1)
        (Random.float 0 1)
        (Random.float 0.25 0.75)
        (Random.constant 0.75)


startTouchLine : Int -> Point2d Pixels DrawingCoordinates -> Model -> Model
startTouchLine identifier point model =
    let
        ( randomColor, updatedSeed ) =
            Random.step colorGenerator model.randomSeed

        updatedLines =
            model.currentTouchLines
                |> Dict.insert identifier
                    { index = model.lineIndex
                    , color = randomColor
                    , points = [ point ]
                    , width = pixels 8
                    }
    in
    { model
        | randomSeed = updatedSeed
        , currentTouchLines = updatedLines
        , lineIndex = model.lineIndex + 1
    }


endTouchLine : Int -> Line -> Model -> Model
endTouchLine identifier line model =
    { model
        | currentTouchLines = Dict.remove identifier model.currentTouchLines
        , finishedLines = line :: model.finishedLines
    }


startTouchInteraction : TouchInteraction Pixels DrawingCoordinates -> Model -> Model
startTouchInteraction touchInteraction model =
    { model | currentTouchInteraction = Just touchInteraction, finishedLines = [] }


endTouchInteraction : Model -> Model
endTouchInteraction model =
    { model | currentTouchInteraction = Nothing }


extendTouchLine : Int -> Line -> Point2d Pixels DrawingCoordinates -> Model -> Model
extendTouchLine identifier currentLine newPoint model =
    let
        extendedLine =
            { currentLine | points = newPoint :: currentLine.points }
    in
    { model | currentTouchLines = Dict.insert identifier extendedLine model.currentTouchLines }


view : Model -> Html Msg
view model =
    let
        viewBox =
            Rectangle2d.from Point2d.origin (Point2d.pixels 800 600)

        currentMouseLine =
            case model.currentMouseSession of
                Just { line } ->
                    [ line ]

                Nothing ->
                    []

        allLines =
            List.sortBy .index
                (model.finishedLines
                    ++ Dict.values model.currentTouchLines
                    ++ currentMouseLine
                )

        commonAttributes =
            [ Drawing2d.roundStrokeJoins
            , Drawing2d.roundStrokeCaps
            , Drawing2d.onTouchStart TouchStart
            , Drawing2d.onLeftMouseDown MouseDown
            ]

        touchInteractionAttributes =
            case model.currentTouchInteraction of
                Nothing ->
                    []

                Just touchInteraction ->
                    [ TouchInteraction.onChange TouchChange touchInteraction
                    , TouchInteraction.onEnd (always TouchEnd) touchInteraction
                    ]
    in
    Element.layout [] <|
        Element.column [ Element.paddingXY 64 0 ] <|
            [ Element.html (Html.h1 [] [ Html.text "Elm finger painting" ])
            , Element.el [ Element.Border.width 16 ] <|
                Element.html <|
                    Drawing2d.draw
                        { viewBox = viewBox
                        , background = Drawing2d.noBackground
                        , attributes = commonAttributes ++ touchInteractionAttributes
                        , entities = List.map drawLine allLines
                        }
            , Element.html <|
                Html.div [ Html.Attributes.style "max-width" "816px", Html.Attributes.style "overflow-wrap" "normal", Html.Attributes.style "white-space" "normal" ]
                    [ Html.h2 [] [ Html.text "What should work" ]
                    , Html.ul []
                        [ bullet "Draw multiple lines simultaneously with different fingers"
                        , bullet "Each line should get a new random color"
                        , bullet "Touch down a new finger to start drawing a new line while still drawing existing lines"
                        , bullet "Lift a finger to stop drawing its line while still drawing lines for any other fingers still in contact with the screen"
                        , bullet "Draw with the left mouse button for a thinner blue solid line"
                        , bullet "Starting to draw a new line (or set of lines) will erase all existing lines"
                        ]
                    , Html.h2 [] [ Html.text "Things to look out for" ]
                    , Html.ul []
                        [ bullet "Lines not appearing at all"
                        , bullet "Lines not following the center of your finger/tip of the mouse (try vertical and horizontal lines)"
                        , bullet "Page panning/moving instead of lines being drawn (as long as fingers start inside the drawing)"
                        , bullet "Breaks in lines (although could be a physical touchscreen issue - if possible, try to see if it's browser-specific or hardware-specific)"
                        , bullet "Weird behavior if a finger moves out of the drawing and then back in (should continue drawing in the same color, unless you lift your finger while outside the drawing)"
                        , bullet "Lines changing color mid-draw"
                        ]
                    , Html.h2 [] [ Html.text "Known issues" ]
                    , Html.ul []
                        [ bullet "Doesn't work on Internet Explorer - layout is messed up, but IE doesn't seem to send touch events at all anyways =("
                        , bullet "Microsoft Edge does not seem to send touch events by default - should be able to enable them by navingating to about:flags and setting \"Enable touch events\" to \"Only on when touchscreen is detected\""
                        , bullet "Performance is not great, especially if you draw a bunch of long lines - this isn't really the right way to use SVG =)"
                        , bullet "On iOS only up to 3 fingers are supported since there seems to be no way to disable the built-in 4- and 5-finger app switching gestures"
                        ]
                    , Html.text "Please report any issues to @ianmackenzie on the Elm Slack!"
                    ]
            ]


bullet : String -> Html msg
bullet text =
    Html.li [] [ Html.text text ]


drawLine : Line -> Drawing2d.Entity Pixels DrawingCoordinates DrawingEvent
drawLine line =
    Drawing2d.polyline
        [ Drawing2d.strokeColor line.color, Drawing2d.strokeWidth line.width ]
        (Polyline2d.fromVertices line.points)


subscriptions : Model -> Sub Msg
subscriptions model =
    case model.currentMouseSession of
        Just { mouseInteraction } ->
            Sub.batch
                [ mouseInteraction |> MouseInteraction.onMove MouseMove
                , mouseInteraction |> MouseInteraction.onEnd MouseUp
                ]

        Nothing ->
            Sub.none


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , update = \message model -> ( update message model, Cmd.none )
        , subscriptions = subscriptions
        , view = view
        }
