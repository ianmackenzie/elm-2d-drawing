module Drawing2d.MouseInteraction.Protected exposing
    ( MouseInteraction(..)
    , start
    )

import Drawing2d.InteractionPoint as InteractionPoint exposing (ReferencePoint)
import Drawing2d.MouseStartEvent exposing (MouseStartEvent)
import Pixels exposing (Pixels)
import Rectangle2d exposing (Rectangle2d)


type MouseInteraction drawingCoordinates
    = MouseInteraction
        { button : Int
        , referencePoint : ReferencePoint drawingCoordinates
        }


start : MouseStartEvent -> Rectangle2d Pixels drawingCoordinates -> MouseInteraction drawingCoordinates
start mouseStartEvent viewBox =
    MouseInteraction
        { button = mouseStartEvent.button
        , referencePoint = InteractionPoint.referencePoint mouseStartEvent viewBox mouseStartEvent.container
        }
