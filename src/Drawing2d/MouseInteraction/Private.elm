module Drawing2d.MouseInteraction.Private exposing (MouseInteraction(..))

import Drawing2d.InteractionPoint as InteractionPoint exposing (ReferencePoint)


type MouseInteraction drawingCoordinates
    = MouseInteraction
        { button : Int
        , referencePoint : ReferencePoint drawingCoordinates
        }
