module Drawing2d.TouchInteraction exposing
    ( TouchInteraction
    , decodeChange
    , decodeEnd
    , onChange
    , onEnd
    )

import Dict exposing (Dict)
import Drawing2d.Attributes.Protected as Attributes exposing (AttributeIn)
import Drawing2d.TouchInteraction.Private as Private
import Duration exposing (Duration)
import Json.Decode as Decode exposing (Decoder)
import Pixels exposing (Pixels)
import Point2d exposing (Point2d)


type alias TouchInteraction drawingCoordinates =
    Private.TouchInteraction drawingCoordinates


decodeChange : Decoder (Dict Int (Point2d Pixels drawingCoordinates) -> msg) -> TouchInteraction drawingCoordinates -> AttributeIn units coordinates drawingCoordinates msg
decodeChange decoder touchInteraction =
    Attributes.OnTouchChange decoder touchInteraction


decodeEnd : Decoder (Duration -> msg) -> TouchInteraction drawingCoordinates -> AttributeIn units coordinates drawingCoordinates msg
decodeEnd decoder touchInteraction =
    Attributes.OnTouchEnd decoder touchInteraction


onChange : (Dict Int (Point2d Pixels drawingCoordinates) -> msg) -> TouchInteraction drawingCoordinates -> AttributeIn units coordinates drawingCoordinates msg
onChange callback touchInteraction =
    decodeChange (Decode.succeed callback) touchInteraction


onEnd : (Duration -> msg) -> TouchInteraction drawingCoordinates -> AttributeIn units coordinates drawingCoordinates msg
onEnd callback touchInteraction =
    decodeEnd (Decode.succeed callback) touchInteraction
