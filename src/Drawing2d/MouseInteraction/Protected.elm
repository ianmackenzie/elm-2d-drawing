module Drawing2d.MouseInteraction.Protected exposing
    ( MouseInteraction(..)
    , MouseInteractionData
    , start
    )

import BoundingBox2d exposing (BoundingBox2d)
import Drawing2d.InteractionPoint as InteractionPoint exposing (ReferencePoint)
import Drawing2d.MouseStartEvent exposing (MouseStartEvent)
import Pixels exposing (Pixels)


type alias MouseInteractionData =
    { button : Int
    , referencePoint : ReferencePoint
    }


type MouseInteraction drawingCoordinates
    = MouseInteraction MouseInteractionData


start : MouseStartEvent -> BoundingBox2d Pixels drawingCoordinates -> MouseInteraction drawingCoordinates
start mouseStartEvent viewBox =
    MouseInteraction
        { button = mouseStartEvent.button
        , referencePoint = InteractionPoint.referencePoint mouseStartEvent viewBox mouseStartEvent.container
        }
