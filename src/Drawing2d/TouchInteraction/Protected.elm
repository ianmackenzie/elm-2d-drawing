module Drawing2d.TouchInteraction.Protected exposing (TouchInteraction, duration, start, updatedPoint)

import BoundingBox2d exposing (BoundingBox2d)
import Dict exposing (Dict)
import Drawing2d.InteractionPoint as InteractionPoint exposing (ReferencePoint)
import Drawing2d.TouchEndEvent exposing (TouchEndEvent)
import Drawing2d.TouchInteraction.Private as Private
import Drawing2d.TouchStartEvent exposing (TouchStart, TouchStartEvent)
import Duration exposing (Duration)
import Pixels exposing (Pixels)
import Point2d exposing (Point2d)
import Quantity


type alias TouchInteraction drawingCoordinates =
    Private.TouchInteraction drawingCoordinates


start : TouchStartEvent -> BoundingBox2d Pixels drawingCoordinates -> ( TouchInteraction drawingCoordinates, Dict Int (Point2d Pixels drawingCoordinates) )
start touchStartEvent viewBox =
    let
        ( firstTargetTouch, remainingTargetTouches ) =
            touchStartEvent.targetTouches

        referencePoint =
            InteractionPoint.referencePoint firstTargetTouch viewBox touchStartEvent.container

        firstIdentifier =
            firstTargetTouch.identifier

        firstPoint =
            InteractionPoint.startPosition referencePoint

        dictEntries =
            ( firstIdentifier, firstPoint )
                :: List.map (toDictEntry referencePoint) remainingTargetTouches

        touchInteraction =
            Private.TouchInteraction
                { startTimeStamp = touchStartEvent.timeStamp
                , referencePoint = referencePoint
                }
    in
    ( touchInteraction, Dict.fromList dictEntries )


toDictEntry : ReferencePoint drawingCoordinates -> TouchStart -> ( Int, Point2d Pixels drawingCoordinates )
toDictEntry referencePoint touchStart =
    ( touchStart.identifier, InteractionPoint.updatedPosition referencePoint touchStart )


updatedPoint : TouchInteraction drawingCoordinates -> { a | identifier : Int, pageX : Float, pageY : Float } -> ( Int, Point2d Pixels drawingCoordinates )
updatedPoint (Private.TouchInteraction interaction) touch =
    ( touch.identifier, InteractionPoint.updatedPosition interaction.referencePoint touch )


duration : TouchInteraction drawingCoordinates -> TouchEndEvent -> Duration
duration (Private.TouchInteraction interaction) touchEndEvent =
    touchEndEvent.timeStamp |> Quantity.minus interaction.startTimeStamp
