module Drawing2d.TouchInteraction.Private exposing (TouchInteraction(..))

import Drawing2d.InteractionPoint exposing (ReferencePoint)
import Duration exposing (Duration)


type TouchInteraction drawingCoordinates
    = TouchInteraction
        { startTimeStamp : Duration
        , referencePoint : ReferencePoint drawingCoordinates
        }
