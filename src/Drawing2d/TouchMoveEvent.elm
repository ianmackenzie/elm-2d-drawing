module Drawing2d.TouchMoveEvent exposing (singleTouch)

import Drawing2d.Types exposing (SingleTouchInteraction(..), TouchMove, TouchMoveEvent)
import Drawing2d.Utils exposing (isSameTouch)


singleTouch : SingleTouchInteraction drawingCoordinates -> TouchMoveEvent -> Maybe TouchMove
singleTouch (SingleTouchInteraction interaction) touchMoveEvent =
    case touchMoveEvent.changedTouches |> List.filter (isSameTouch interaction.initialTouch) of
        [ matchingTouch ] ->
            Just matchingTouch

        _ ->
            Nothing
