module Drawing2d.MouseMoveEvent exposing (MouseMoveEvent, decoder)

import Drawing2d.Decode as Decode
import Json.Decode as Decode exposing (Decoder)


type alias MouseMoveEvent =
    { pageX : Float
    , pageY : Float
    }


decoder : Decoder MouseMoveEvent
decoder =
    Decode.map2 MouseMoveEvent Decode.pageX Decode.pageY
