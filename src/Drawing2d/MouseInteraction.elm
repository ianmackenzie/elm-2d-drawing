module Drawing2d.MouseInteraction exposing
    ( MouseInteraction
    , onEnd
    , onMove
    )

import Browser.Events
import Drawing2d.Types as Types exposing (MouseEvent)
import Drawing2d.Utils exposing (decodeMouseEvent, decodePageX, decodePageY, wrongButton)
import Json.Decode as Decode exposing (Decoder)
import Pixels exposing (Pixels)
import Point2d exposing (Point2d)
import Vector2d


type alias MouseInteraction drawingCoordinates =
    Types.MouseInteraction drawingCoordinates


toDisplacedPoint :
    { initialEvent | pageX : Float, pageY : Float }
    -> Float
    -> Point2d Pixels drawingCoordinates
    -> Float
    -> Float
    -> Point2d Pixels drawingCoordinates
toDisplacedPoint initialEvent drawingScale initialPoint pageX pageY =
    let
        displacement =
            Vector2d.pixels
                ((pageX - initialEvent.pageX) / drawingScale)
                ((initialEvent.pageY - pageY) / drawingScale)
    in
    initialPoint |> Point2d.translateBy displacement


decodeDisplacedPoint :
    { initialEvent | pageX : Float, pageY : Float }
    -> Float
    -> Point2d Pixels drawingCoordinates
    -> Decoder (Point2d Pixels drawingCoordinates)
decodeDisplacedPoint initialEvent drawingScale initialPoint =
    Decode.map2 (toDisplacedPoint initialEvent drawingScale initialPoint) decodePageX decodePageY


mouseMoveDecoder :
    MouseInteraction drawingCoordinates
    -> Decoder (Point2d Pixels drawingCoordinates -> msg)
    -> Decoder msg
mouseMoveDecoder (Types.MouseInteraction mouseInteraction) givenDecoder =
    let
        { initialEvent, drawingScale, initialPoint } =
            mouseInteraction
    in
    Decode.map2 (<|) givenDecoder (decodeDisplacedPoint initialEvent drawingScale initialPoint)


onMove :
    MouseInteraction drawingCoordinates
    -> Decoder (Point2d Pixels drawingCoordinates -> msg)
    -> Sub msg
onMove mouseInteraction givenDecoder =
    Browser.Events.onMouseMove (mouseMoveDecoder mouseInteraction givenDecoder)


decodeMouseUp : MouseInteraction drawingCoordinates -> Decoder msg -> Decoder msg
decodeMouseUp (Types.MouseInteraction mouseInteraction) givenDecoder =
    Decode.field "button" Decode.int
        |> Decode.andThen
            (\button ->
                if button == mouseInteraction.initialEvent.button then
                    givenDecoder

                else
                    wrongButton
            )


onEnd : MouseInteraction drawingCoordinates -> Decoder msg -> Sub msg
onEnd mouseInteraction decoder =
    Browser.Events.onMouseUp (decodeMouseUp mouseInteraction decoder)
