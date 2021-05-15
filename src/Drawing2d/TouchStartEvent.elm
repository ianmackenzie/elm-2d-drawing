module Drawing2d.TouchStartEvent exposing
    ( TouchStart
    , TouchStartEvent
    , decoder
    )

import Drawing2d.Decode as Decode exposing (BoundingClientRect)
import Duration exposing (Duration)
import Json.Decode as Decode exposing (Decoder)


type alias TouchStartEvent =
    { container : BoundingClientRect
    , timeStamp : Duration
    , touches : ( TouchStart, List TouchStart )
    , targetTouches : ( TouchStart, List TouchStart )
    , changedTouches : ( TouchStart, List TouchStart )
    }


type alias TouchStart =
    { identifier : Int
    , clientX : Float
    , clientY : Float
    , pageX : Float
    , pageY : Float
    }


decodeTouchStart : Decoder TouchStart
decodeTouchStart =
    Decode.map5 TouchStart
        Decode.identifier
        Decode.clientX
        Decode.clientY
        Decode.pageX
        Decode.pageY


decoder : Decoder TouchStartEvent
decoder =
    Decode.map5 TouchStartEvent
        Decode.container
        Decode.timeStamp
        (Decode.nonempty (Decode.touches decodeTouchStart))
        (Decode.nonempty (Decode.targetTouches decodeTouchStart))
        (Decode.nonempty (Decode.changedTouches decodeTouchStart))
        |> Decode.andThen
            (\touchStartEvent ->
                if touchStartEvent.targetTouches == touchStartEvent.changedTouches then
                    Decode.succeed touchStartEvent

                else
                    Decode.fail "Not the initial start event"
            )
