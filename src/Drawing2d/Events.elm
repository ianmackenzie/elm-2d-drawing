module Drawing2d.Events exposing
    ( decodeLeftClick
    , decodeLeftMouseDown
    , decodeLeftMouseUp
    , decodeMiddleMouseDown
    , decodeMiddleMouseUp
    , decodeRightClick
    , decodeRightMouseDown
    , decodeRightMouseUp
    , decodeTouchStart
    , onLeftClick
    , onLeftMouseDown
    , onLeftMouseUp
    , onMiddleMouseDown
    , onMiddleMouseUp
    , onRightClick
    , onRightMouseDown
    , onRightMouseUp
    , onTouchStart
    )

import BoundingBox2d exposing (BoundingBox2d)
import Dict exposing (Dict)
import Drawing2d.Attributes.Protected as Attributes exposing (Attribute, Event(..))
import Drawing2d.Decode as Decode
import Drawing2d.InteractionPoint as InteractionPoint
import Drawing2d.MouseInteraction.Protected as MouseInteraction exposing (MouseInteraction(..))
import Drawing2d.MouseStartEvent as MouseStartEvent exposing (MouseStartEvent)
import Drawing2d.TouchInteraction.Protected as TouchInteraction exposing (TouchInteraction(..))
import Drawing2d.TouchStartEvent as TouchStartEvent exposing (TouchStartEvent)
import Json.Decode as Decode exposing (Decoder)
import Pixels exposing (Pixels)
import Point2d exposing (Point2d)


leftButton : Int
leftButton =
    0


middleButton : Int
middleButton =
    1


rightButton : Int
rightButton =
    2


onLeftClick : (Point2d Pixels drawingCoordinates -> msg) -> Attribute units coordinates (Event drawingCoordinates msg)
onLeftClick callback =
    decodeLeftClick (Decode.succeed callback)


onRightClick : (Point2d Pixels drawingCoordinates -> msg) -> Attribute units coordinates (Event drawingCoordinates msg)
onRightClick callback =
    decodeRightClick (Decode.succeed callback)


onLeftMouseDown : (Point2d Pixels drawingCoordinates -> MouseInteraction drawingCoordinates -> msg) -> Attribute units coordinates (Event drawingCoordinates msg)
onLeftMouseDown callback =
    decodeLeftMouseDown (Decode.succeed callback)


onRightMouseDown : (Point2d Pixels drawingCoordinates -> MouseInteraction drawingCoordinates -> msg) -> Attribute units coordinates (Event drawingCoordinates msg)
onRightMouseDown callback =
    decodeRightMouseDown (Decode.succeed callback)


onMiddleMouseDown : (Point2d Pixels drawingCoordinates -> MouseInteraction drawingCoordinates -> msg) -> Attribute units coordinates (Event drawingCoordinates msg)
onMiddleMouseDown callback =
    decodeMiddleMouseDown (Decode.succeed callback)


onLeftMouseUp : msg -> Attribute units coordinates (Event drawingCoordinates msg)
onLeftMouseUp message =
    decodeLeftMouseUp (Decode.succeed message)


onRightMouseUp : msg -> Attribute units coordinates (Event drawingCoordinates msg)
onRightMouseUp message =
    decodeRightMouseUp (Decode.succeed message)


onMiddleMouseUp : msg -> Attribute units coordinates (Event drawingCoordinates msg)
onMiddleMouseUp message =
    decodeMiddleMouseUp (Decode.succeed message)


onTouchStart : (Dict Int (Point2d Pixels drawingCoordinates) -> TouchInteraction drawingCoordinates -> msg) -> Attribute units coordinates (Event drawingCoordinates msg)
onTouchStart callback =
    decodeTouchStart (Decode.succeed callback)


decodeLeftClick : Decoder (Point2d Pixels drawingCoordinates -> msg) -> Attribute units coordinates (Event drawingCoordinates msg)
decodeLeftClick decoder =
    Attributes.EventHandlers [ ( "click", clickDecoder decoder ) ]


decodeRightClick : Decoder (Point2d Pixels drawingCoordinates -> msg) -> Attribute units coordinates (Event drawingCoordinates msg)
decodeRightClick decoder =
    Attributes.EventHandlers [ ( "contextmenu", clickDecoder decoder ) ]


decodeLeftMouseDown : Decoder (Point2d Pixels drawingCoordinates -> MouseInteraction drawingCoordinates -> msg) -> Attribute units coordinates (Event drawingCoordinates msg)
decodeLeftMouseDown decoder =
    Attributes.EventHandlers [ ( "mousedown", mouseDownDecoder leftButton decoder ) ]


decodeMiddleMouseDown : Decoder (Point2d Pixels drawingCoordinates -> MouseInteraction drawingCoordinates -> msg) -> Attribute units coordinates (Event drawingCoordinates msg)
decodeMiddleMouseDown decoder =
    Attributes.EventHandlers [ ( "mousedown", mouseDownDecoder middleButton decoder ) ]


decodeRightMouseDown : Decoder (Point2d Pixels drawingCoordinates -> MouseInteraction drawingCoordinates -> msg) -> Attribute units coordinates (Event drawingCoordinates msg)
decodeRightMouseDown decoder =
    Attributes.EventHandlers [ ( "mousedown", mouseDownDecoder rightButton decoder ) ]


decodeLeftMouseUp : Decoder msg -> Attribute units coordinates (Event drawingCoordinates msg)
decodeLeftMouseUp decoder =
    Attributes.EventHandlers [ ( "mouseup", mouseUpDecoder leftButton decoder ) ]


decodeMiddleMouseUp : Decoder msg -> Attribute units coordinates (Event drawingCoordinates msg)
decodeMiddleMouseUp decoder =
    Attributes.EventHandlers [ ( "mouseup", mouseUpDecoder middleButton decoder ) ]


decodeRightMouseUp : Decoder msg -> Attribute units coordinates (Event drawingCoordinates msg)
decodeRightMouseUp decoder =
    Attributes.EventHandlers [ ( "mouseup", mouseUpDecoder rightButton decoder ) ]


decodeTouchStart : Decoder (Dict Int (Point2d Pixels drawingCoordinates) -> TouchInteraction drawingCoordinates -> msg) -> Attribute units coordinates (Event drawingCoordinates msg)
decodeTouchStart decoder =
    Attributes.EventHandlers [ ( "touchstart", touchStartDecoder decoder ) ]


wrapMessage : msg -> Event drawingCoordinates msg
wrapMessage message =
    Event (always message)


filterByButton : Int -> Decoder a -> Decoder a
filterByButton whichButton decoder =
    Decode.button
        |> Decode.andThen
            (\button ->
                if button == whichButton then
                    decoder

                else
                    Decode.wrongButton
            )


clickDecoder :
    Decoder (Point2d Pixels drawingCoordinates -> msg)
    -> Decoder (Event drawingCoordinates msg)
clickDecoder givenDecoder =
    Decode.map2 handleClick MouseStartEvent.decoder givenDecoder


handleClick : MouseStartEvent -> (Point2d Pixels drawingCoordinates -> msg) -> Event drawingCoordinates msg
handleClick mouseStartEvent userCallback =
    Event
        (\viewBox ->
            let
                drawingPoint =
                    InteractionPoint.position mouseStartEvent viewBox mouseStartEvent.container
            in
            userCallback drawingPoint
        )


mouseDownDecoder :
    Int
    -> Decoder (Point2d Pixels drawingCoordinates -> MouseInteraction drawingCoordinates -> msg)
    -> Decoder (Event drawingCoordinates msg)
mouseDownDecoder givenButton givenDecoder =
    filterByButton givenButton (Decode.map2 handleMouseDown MouseStartEvent.decoder givenDecoder)


handleMouseDown :
    MouseStartEvent
    -> (Point2d Pixels drawingCoordinates -> MouseInteraction drawingCoordinates -> msg)
    -> Event drawingCoordinates msg
handleMouseDown mouseStartEvent userCallback =
    Event
        (\viewBox ->
            let
                drawingPoint =
                    InteractionPoint.position mouseStartEvent viewBox mouseStartEvent.container

                mouseInteraction =
                    MouseInteraction.start mouseStartEvent viewBox
            in
            userCallback drawingPoint mouseInteraction
        )


mouseUpDecoder : Int -> Decoder msg -> Decoder (Event drawingCoordinates msg)
mouseUpDecoder givenButton givenDecoder =
    filterByButton givenButton (Decode.map wrapMessage givenDecoder)


touchStartDecoder :
    Decoder
        (Dict Int (Point2d Pixels drawingCoordinates)
         -> TouchInteraction drawingCoordinates
         -> msg
        )
    -> Decoder (Event drawingCoordinates msg)
touchStartDecoder givenDecoder =
    Decode.map2 handleTouchStart TouchStartEvent.decoder givenDecoder


handleTouchStart :
    TouchStartEvent
    -> (Dict Int (Point2d Pixels drawingCoordinates) -> TouchInteraction drawingCoordinates -> msg)
    -> Event drawingCoordinates msg
handleTouchStart touchStartEvent userCallback =
    Event
        (\viewBox ->
            let
                ( touchInteraction, initialPoints ) =
                    TouchInteraction.start touchStartEvent viewBox
            in
            userCallback initialPoints touchInteraction
        )
