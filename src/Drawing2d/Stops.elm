module Drawing2d.Stops exposing (id)

import Color
import Drawing2d.Types as Types exposing (Stops(..))


id : Stops -> String
id stops =
    case stops of
        StopValues stopsId values ->
            stopsId

        StopsReference stopsId ->
            stopsId
