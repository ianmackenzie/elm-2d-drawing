module Drawing2d.TouchInteraction.Protected exposing (TouchInteraction, duration, start, updatedPoint)

import BoundingBox2d exposing (BoundingBox2d)
import Drawing2d.InteractionPoint as InteractionPoint
import Drawing2d.TouchEndEvent exposing (TouchEndEvent)
import Drawing2d.TouchInteraction.Private as Private
import Drawing2d.TouchStartEvent exposing (TouchStartEvent)
import Duration exposing (Duration)
import Pixels exposing (Pixels)
import Point2d exposing (Point2d)
import Quantity


type alias TouchInteraction drawingCoordinates =
    Private.TouchInteraction drawingCoordinates


start : TouchStartEvent -> BoundingBox2d Pixels drawingCoordinates -> ( TouchInteraction drawingCoordinates, List (Point2d Pixels drawingCoordinates) )
start touchStartEvent viewBox =
    let
        ( firstTargetTouch, remainingTargetTouches ) =
            touchStartEvent.targetTouches

        referencePoint =
            InteractionPoint.referencePoint firstTargetTouch viewBox touchStartEvent.container

        firstPoint =
            InteractionPoint.startPosition referencePoint

        remainingPoints =
            List.map (InteractionPoint.updatedPosition referencePoint) remainingTargetTouches

        touchInteraction =
            Private.TouchInteraction
                { startTimeStamp = touchStartEvent.timeStamp
                , referencePoint = referencePoint
                }
    in
    ( touchInteraction, firstPoint :: remainingPoints )


updatedPoint : TouchInteraction drawingCoordinates -> { a | pageX : Float, pageY : Float } -> Point2d Pixels drawingCoordinates
updatedPoint (Private.TouchInteraction interaction) touch =
    InteractionPoint.updatedPosition interaction.referencePoint touch


duration : TouchInteraction drawingCoordinates -> TouchEndEvent -> Duration
duration (Private.TouchInteraction interaction) touchEndEvent =
    touchEndEvent.timeStamp |> Quantity.minus interaction.startTimeStamp
