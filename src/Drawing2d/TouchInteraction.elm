module Drawing2d.TouchInteraction exposing
    ( TouchInteraction
    , decodeChange
    , decodeEnd
    , onChange
    , onEnd
    )

import BoundingBox2d exposing (BoundingBox2d)
import Dict exposing (Dict)
import Drawing2d.Attributes exposing (Attribute(..))
import Drawing2d.Event exposing (Event)
import Drawing2d.InteractionPoint as InteractionPoint exposing (ReferencePoint)
import Drawing2d.TouchChangeEvent as TouchChangeEvent exposing (TouchChangeEvent)
import Drawing2d.TouchEndEvent as TouchEndEvent exposing (TouchEndEvent)
import Drawing2d.TouchInteraction.Protected as Protected exposing (TouchInteraction(..))
import Duration exposing (Duration)
import Json.Decode as Decode exposing (Decoder)
import Pixels exposing (Pixels)
import Point2d exposing (Point2d)
import Quantity


type alias TouchInteraction units coordinates =
    Protected.TouchInteraction units coordinates


decodeChange :
    Decoder (Dict Int (Point2d units coordinates) -> msg)
    -> TouchInteraction units coordinates
    -> Attribute units coordinates msg
decodeChange decoder touchInteraction =
    let
        touchChangeDecoder =
            decodeTouchChange decoder touchInteraction
    in
    EventHandlers
        [ ( "touchstart", touchChangeDecoder )
        , ( "touchmove", touchChangeDecoder )
        , ( "touchend", touchChangeDecoder )
        , ( "touchcancel", touchChangeDecoder )
        ]


decodeTouchChange :
    Decoder (Dict Int (Point2d units coordinates) -> msg)
    -> TouchInteraction units coordinates
    -> Decoder (Event units coordinates msg)
decodeTouchChange givenDecoder touchInteraction =
    Decode.map2 (handleTouchChange touchInteraction) TouchChangeEvent.decoder givenDecoder


handleTouchChange :
    TouchInteraction units coordinates
    -> TouchChangeEvent
    -> (Dict Int (Point2d units coordinates) -> msg)
    -> Event units coordinates msg
handleTouchChange touchInteraction touchChangeEvent userCallback =
    \viewBox ->
        let
            updatedPoints =
                touchChangeEvent.targetTouches
                    |> List.map (updatedPoint touchInteraction)
                    |> Dict.fromList
        in
        userCallback updatedPoints


decodeEnd :
    Decoder (Duration -> msg)
    -> TouchInteraction units coordinates
    -> Attribute units coordinates msg
decodeEnd decoder touchInteraction =
    let
        touchEndDecoder =
            decodeTouchEnd decoder touchInteraction
    in
    EventHandlers
        [ ( "touchend", touchEndDecoder )
        , ( "touchcancel", touchEndDecoder )
        ]


decodeTouchEnd :
    Decoder (Duration -> msg)
    -> TouchInteraction units coordinates
    -> Decoder (Event units coordinates msg)
decodeTouchEnd givenDecoder touchInteraction =
    Decode.map2 (handleTouchEnd touchInteraction) TouchEndEvent.decoder givenDecoder


handleTouchEnd :
    TouchInteraction units coordinates
    -> TouchEndEvent
    -> (Duration -> msg)
    -> Event units coordinates msg
handleTouchEnd touchInteraction touchEndEvent userCallback =
    always (userCallback (duration touchInteraction touchEndEvent))


onChange :
    (Dict Int (Point2d units coordinates) -> msg)
    -> TouchInteraction units coordinates
    -> Attribute units coordinates msg
onChange callback touchInteraction =
    decodeChange (Decode.succeed callback) touchInteraction


onEnd :
    (Duration -> msg)
    -> TouchInteraction units coordinates
    -> Attribute units coordinates msg
onEnd callback touchInteraction =
    decodeEnd (Decode.succeed callback) touchInteraction


updatedPoint :
    TouchInteraction units coordinates
    -> { a | identifier : Int, pageX : Float, pageY : Float }
    -> ( Int, Point2d units coordinates )
updatedPoint (TouchInteraction interaction) touch =
    ( touch.identifier, InteractionPoint.updatedPosition interaction.referencePoint touch )


duration : TouchInteraction units coordinates -> TouchEndEvent -> Duration
duration (TouchInteraction interaction) touchEndEvent =
    touchEndEvent.timeStamp |> Quantity.minus interaction.startTimeStamp
