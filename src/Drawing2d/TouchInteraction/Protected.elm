module Drawing2d.TouchInteraction.Protected exposing
    ( TouchInteraction(..)
    , start
    )

import BoundingBox2d exposing (BoundingBox2d)
import Dict exposing (Dict)
import Drawing2d.InteractionPoint as InteractionPoint exposing (ReferencePoint)
import Drawing2d.TouchEndEvent exposing (TouchEndEvent)
import Drawing2d.TouchStartEvent exposing (TouchStart, TouchStartEvent)
import Duration exposing (Duration)
import Pixels exposing (Pixels)
import Point2d exposing (Point2d)


type TouchInteraction drawingCoordinates
    = TouchInteraction
        { startTimeStamp : Duration
        , referencePoint : ReferencePoint drawingCoordinates
        }


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
            TouchInteraction
                { startTimeStamp = touchStartEvent.timeStamp
                , referencePoint = referencePoint
                }
    in
    ( touchInteraction, Dict.fromList dictEntries )


toDictEntry : ReferencePoint drawingCoordinates -> TouchStart -> ( Int, Point2d Pixels drawingCoordinates )
toDictEntry referencePoint touchStart =
    ( touchStart.identifier, InteractionPoint.updatedPosition referencePoint touchStart )
