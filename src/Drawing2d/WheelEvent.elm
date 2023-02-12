module Drawing2d.WheelEvent exposing (..)

import Drawing2d.Decode as Decode exposing (BoundingClientRect)
import Drawing2d.Wheel as Wheel exposing (Delta)
import Json.Decode as Decode exposing (Decoder)


type alias WheelEvent =
    { container : BoundingClientRect
    , clientX : Float
    , clientY : Float
    , pageX : Float
    , pageY : Float
    , delta : Wheel.Delta
    }


decoder : Decoder WheelEvent
decoder =
    Decode.map6 WheelEvent
        Decode.container
        Decode.clientX
        Decode.clientY
        Decode.pageX
        Decode.pageY
        Wheel.decoder
