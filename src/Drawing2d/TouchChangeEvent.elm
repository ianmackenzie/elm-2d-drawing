module Drawing2d.TouchChangeEvent exposing (TouchChangeEvent, TouchPosition, decoder)

import Drawing2d.Decode as Decode
import Json.Decode as Decode exposing (Decoder)


type alias TouchChangeEvent =
    { targetTouches : List TouchPosition
    }


type alias TouchPosition =
    { pageX : Float
    , pageY : Float
    }


decodeTouchPosition : Decoder TouchPosition
decodeTouchPosition =
    Decode.map2 TouchPosition
        Decode.pageX
        Decode.pageY


decoder : Decoder TouchChangeEvent
decoder =
    Decode.map TouchChangeEvent
        (Decode.nonempty (Decode.targetTouches decodeTouchPosition)
            |> Decode.map (\( first, rest ) -> first :: rest)
        )
