module Drawing2d.MouseInteraction.Protected exposing (MouseInteraction, start)

import BoundingBox2d exposing (BoundingBox2d)
import Drawing2d.InteractionPoint as InteractionPoint
import Drawing2d.MouseInteraction.Private as Private
import Drawing2d.MouseStartEvent exposing (MouseStartEvent)
import Pixels exposing (Pixels)


type alias MouseInteraction drawingCoordinates =
    Private.MouseInteraction drawingCoordinates


start : MouseStartEvent -> BoundingBox2d Pixels drawingCoordinates -> MouseInteraction drawingCoordinates
start mouseStartEvent viewBox =
    Private.MouseInteraction
        { button = mouseStartEvent.button
        , referencePoint = InteractionPoint.referencePoint mouseStartEvent viewBox mouseStartEvent.container
        }
