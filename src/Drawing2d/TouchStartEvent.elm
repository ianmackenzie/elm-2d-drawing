module Drawing2d.TouchStartEvent exposing
    ( doubleTouch
    , singleTouch
    )

import Drawing2d.Types exposing (TouchStart, TouchStartEvent)
import Set


singleTouch : TouchStartEvent -> Maybe TouchStart
singleTouch event =
    case event.targetTouches of
        [ touch ] ->
            -- There's only one touch point on the target, and this event
            -- marked the start of a touch point on the target, so those two
            -- must be one and the same
            Just touch

        _ ->
            -- More than one current touch point: not the start of a single
            -- touch
            Nothing


doubleTouch : TouchStartEvent -> Maybe ( TouchStart, TouchStart )
doubleTouch event =
    case event.targetTouches of
        [ firstTouch, secondTouch ] ->
            -- Exactly two touch points on the target, and this event marked the
            -- start of at least one of them, so those two points are the start
            -- of a double touch
            Just ( firstTouch, secondTouch )

        _ ->
            -- Not exactly two current touch points: not the start of a double
            -- touch
            Nothing
