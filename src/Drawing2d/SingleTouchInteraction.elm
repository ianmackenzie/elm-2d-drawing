module Drawing2d.SingleTouchInteraction exposing
    ( SingleTouchInteraction
    , decodeEnd
    , decodeMove
    , onEnd
    , onMove
    )

import Drawing2d.Types as Types exposing (AttributeIn)
import Duration exposing (Duration)
import Json.Decode as Decode exposing (Decoder)
import Pixels exposing (Pixels)
import Point2d exposing (Point2d)


type alias SingleTouchInteraction drawingCoordinates =
    Types.SingleTouchInteraction drawingCoordinates


decodeMove : Decoder (Point2d Pixels drawingCoordinates -> msg) -> SingleTouchInteraction drawingCoordinates -> AttributeIn units coordinates drawingCoordinates msg
decodeMove decoder singleTouchInteraction =
    Types.OnSingleTouchMove decoder singleTouchInteraction


decodeEnd : Decoder (Duration -> msg) -> SingleTouchInteraction drawingCoordinates -> AttributeIn units coordinates drawingCoordinates msg
decodeEnd decoder singleTouchInteraction =
    Types.OnSingleTouchEnd decoder singleTouchInteraction


onEnd : (Duration -> msg) -> SingleTouchInteraction drawingCoordinates -> AttributeIn units coordinates drawingCoordinates msg
onEnd callback singleTouchInteraction =
    decodeEnd (Decode.succeed callback) singleTouchInteraction


onMove : (Point2d Pixels drawingCoordinates -> msg) -> SingleTouchInteraction drawingCoordinates -> AttributeIn units coordinates drawingCoordinates msg
onMove callback singleTouchInteraction =
    decodeMove (Decode.succeed callback) singleTouchInteraction
