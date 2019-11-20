module Drawing2d.MouseInteraction exposing
    ( MouseInteraction
    , decodeEnd
    , decodeMove
    , onEnd
    , onMove
    )

import Browser.Events
import Drawing2d.Decode as Decode
import Drawing2d.InteractionPoint as InteractionPoint
import Drawing2d.MouseInteraction.Protected as Protected
import Drawing2d.MouseMoveEvent as MouseMoveEvent exposing (MouseMoveEvent)
import Json.Decode as Decode exposing (Decoder)
import Pixels exposing (Pixels)
import Point2d exposing (Point2d)
import Vector2d


type alias MouseInteraction drawingCoordinates =
    Protected.MouseInteraction drawingCoordinates


decodeMove :
    Decoder (Point2d Pixels drawingCoordinates -> msg)
    -> MouseInteraction drawingCoordinates
    -> Sub msg
decodeMove givenDecoder (Protected.MouseInteraction interaction) =
    let
        positionDecoder =
            MouseMoveEvent.decoder
                |> Decode.map (InteractionPoint.updatedPosition interaction.referencePoint)
    in
    Browser.Events.onMouseMove (Decode.map2 (<|) givenDecoder positionDecoder)


onMove : (Point2d Pixels drawingCoordinates -> msg) -> MouseInteraction drawingCoordinates -> Sub msg
onMove callback mouseInteraction =
    decodeMove (Decode.succeed callback) mouseInteraction


decodeEnd : Decoder msg -> MouseInteraction drawingCoordinates -> Sub msg
decodeEnd givenDecoder (Protected.MouseInteraction interaction) =
    Browser.Events.onMouseUp
        (Decode.button
            |> Decode.andThen
                (\button ->
                    if button == interaction.button then
                        givenDecoder

                    else
                        Decode.wrongButton
                )
        )


onEnd : msg -> MouseInteraction drawingCoordinates -> Sub msg
onEnd message mouseInteraction =
    decodeEnd (Decode.succeed message) mouseInteraction
