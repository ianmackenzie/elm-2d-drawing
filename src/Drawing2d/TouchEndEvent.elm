module Drawing2d.TouchEndEvent exposing (isEndOf)

import Drawing2d.Types exposing (SingleTouchInteraction(..), TouchEnd, TouchEndEvent)
import Drawing2d.Utils exposing (isMemberOf)


isEndOf : SingleTouchInteraction drawingCoordinates -> TouchEndEvent -> Bool
isEndOf (SingleTouchInteraction interaction) event =
    interaction.initialTouch |> isMemberOf event.changedTouches
