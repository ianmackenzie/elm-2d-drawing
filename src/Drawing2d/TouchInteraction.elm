module Drawing2d.TouchInteraction exposing
    ( TouchInteraction
    , decodeChange
    , decodeEnd
    , onChange
    , onEnd
    )

import BoundingBox2d exposing (BoundingBox2d)
import Dict exposing (Dict)
import Drawing2d.Attributes as Attributes exposing (Attribute, Event(..))
import Drawing2d.InteractionPoint as InteractionPoint exposing (ReferencePoint)
import Drawing2d.TouchChangeEvent as TouchChangeEvent exposing (TouchChangeEvent)
import Drawing2d.TouchEndEvent as TouchEndEvent exposing (TouchEndEvent)
import Drawing2d.TouchInteraction.Protected as Protected exposing (TouchInteraction(..))
import Duration exposing (Duration)
import Json.Decode as Decode exposing (Decoder)
import Pixels exposing (Pixels)
import Point2d exposing (Point2d)
import Quantity


type alias TouchInteraction drawingUnits drawingCoordinates =
    Protected.TouchInteraction drawingUnits drawingCoordinates


decodeChange :
    Decoder (Dict Int (Point2d drawingUnits drawingCoordinates) -> msg)
    -> TouchInteraction drawingUnits drawingCoordinates
    -> Attribute units coordinates (Event drawingUnits drawingCoordinates msg)
decodeChange decoder touchInteraction =
    let
        touchChangeDecoder =
            decodeTouchChange decoder touchInteraction
    in
    Attributes.EventHandlers
        [ ( "touchstart", touchChangeDecoder )
        , ( "touchmove", touchChangeDecoder )
        , ( "touchend", touchChangeDecoder )
        , ( "touchcancel", touchChangeDecoder )
        ]


decodeTouchChange :
    Decoder (Dict Int (Point2d drawingUnits drawingCoordinates) -> msg)
    -> TouchInteraction drawingUnits drawingCoordinates
    -> Decoder (Event drawingUnits drawingCoordinates msg)
decodeTouchChange givenDecoder touchInteraction =
    Decode.map2 (handleTouchChange touchInteraction) TouchChangeEvent.decoder givenDecoder


handleTouchChange :
    TouchInteraction drawingUnits drawingCoordinates
    -> TouchChangeEvent
    -> (Dict Int (Point2d drawingUnits drawingCoordinates) -> msg)
    -> Event drawingUnits drawingCoordinates msg
handleTouchChange touchInteraction touchChangeEvent userCallback =
    Event
        (\viewBox ->
            let
                updatedPoints =
                    touchChangeEvent.targetTouches
                        |> List.map (updatedPoint touchInteraction)
                        |> Dict.fromList
            in
            userCallback updatedPoints
        )


decodeEnd :
    Decoder (Duration -> msg)
    -> TouchInteraction drawingUnits drawingCoordinates
    -> Attribute units coordinates (Event drawingUnits drawingCoordinates msg)
decodeEnd decoder touchInteraction =
    let
        touchEndDecoder =
            decodeTouchEnd decoder touchInteraction
    in
    Attributes.EventHandlers
        [ ( "touchend", touchEndDecoder )
        , ( "touchcancel", touchEndDecoder )
        ]


decodeTouchEnd :
    Decoder (Duration -> msg)
    -> TouchInteraction drawingUnits drawingCoordinates
    -> Decoder (Event drawingUnits drawingCoordinates msg)
decodeTouchEnd givenDecoder touchInteraction =
    Decode.map2 (handleTouchEnd touchInteraction) TouchEndEvent.decoder givenDecoder


handleTouchEnd :
    TouchInteraction drawingUnits drawingCoordinates
    -> TouchEndEvent
    -> (Duration -> msg)
    -> Event drawingUnits drawingCoordinates msg
handleTouchEnd touchInteraction touchEndEvent userCallback =
    Event (always (userCallback (duration touchInteraction touchEndEvent)))


onChange :
    (Dict Int (Point2d drawingUnits drawingCoordinates) -> msg)
    -> TouchInteraction drawingUnits drawingCoordinates
    -> Attribute units coordinates (Event drawingUnits drawingCoordinates msg)
onChange callback touchInteraction =
    decodeChange (Decode.succeed callback) touchInteraction


onEnd :
    (Duration -> msg)
    -> TouchInteraction drawingUnits drawingCoordinates
    -> Attribute units coordinates (Event drawingUnits drawingCoordinates msg)
onEnd callback touchInteraction =
    decodeEnd (Decode.succeed callback) touchInteraction


updatedPoint :
    TouchInteraction drawingUnits drawingCoordinates
    -> { a | identifier : Int, pageX : Float, pageY : Float }
    -> ( Int, Point2d drawingUnits drawingCoordinates )
updatedPoint (TouchInteraction interaction) touch =
    ( touch.identifier, InteractionPoint.updatedPosition interaction.referencePoint touch )


duration : TouchInteraction drawingUnits drawingCoordinates -> TouchEndEvent -> Duration
duration (TouchInteraction interaction) touchEndEvent =
    touchEndEvent.timeStamp |> Quantity.minus interaction.startTimeStamp
