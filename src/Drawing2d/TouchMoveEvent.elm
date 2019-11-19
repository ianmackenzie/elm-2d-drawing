module Drawing2d.TouchMoveEvent exposing (TouchMove, TouchMoveEvent, decoder)

import Drawing2d.Decode as Decode
import Json.Decode as Decode exposing (Decoder)


type alias TouchMove =
    { identifier : Int
    , pageX : Float
    , pageY : Float
    }


type alias TouchMoveEvent =
    { touches : List TouchMove
    , targetTouches : List TouchMove
    , changedTouches : List TouchMove
    }


decodeTouchMove : Decoder TouchMove
decodeTouchMove =
    Decode.map3 TouchMove
        Decode.identifier
        Decode.pageX
        Decode.pageY


decoder : Decoder TouchMoveEvent
decoder =
    Decode.map3 TouchMoveEvent
        (Decode.touches decodeTouchMove)
        (Decode.targetTouches decodeTouchMove)
        (Decode.changedTouches decodeTouchMove)
