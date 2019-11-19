module Drawing2d.MouseStartEvent exposing (MouseStartEvent, decoder)

import DOM
import Drawing2d.Decode as Decode
import Json.Decode as Decode exposing (Decoder)


type alias MouseStartEvent =
    { container : DOM.Rectangle
    , clientX : Float
    , clientY : Float
    , pageX : Float
    , pageY : Float
    , button : Int
    }


decoder : Decoder MouseStartEvent
decoder =
    Decode.map6 MouseStartEvent
        Decode.container
        Decode.clientX
        Decode.clientY
        Decode.pageX
        Decode.pageY
        Decode.button
