module Drawing2d.TouchEndEvent exposing (TouchEndEvent, decoder)

import Drawing2d.Decode as Decode
import Duration exposing (Duration)
import Json.Decode as Decode exposing (Decoder)


type alias TouchEndEvent =
    { timeStamp : Duration
    }


decoder : Decoder TouchEndEvent
decoder =
    Decode.at [ "targetTouches", "length" ] Decode.int
        |> Decode.andThen
            (\numTargetTouches ->
                if numTargetTouches == 0 then
                    Decode.map TouchEndEvent Decode.timeStamp

                else
                    Decode.fail "Still at least one active target touch"
            )
