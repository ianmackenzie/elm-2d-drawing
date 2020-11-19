module Drawing2d.TouchInteraction.Protected exposing
    ( TouchInteraction(..)
    , start
    )

import Dict exposing (Dict)
import Drawing2d.InteractionPoint as InteractionPoint exposing (ReferencePoint)
import Drawing2d.TouchEndEvent exposing (TouchEndEvent)
import Drawing2d.TouchStartEvent exposing (TouchStart, TouchStartEvent)
import Duration exposing (Duration)
import Pixels exposing (Pixels)
import Point2d exposing (Point2d)
import Rectangle2d exposing (Rectangle2d)


type TouchInteraction drawingUnits drawingCoordinates
    = TouchInteraction
        { startTimeStamp : Duration
        , referencePoint : ReferencePoint drawingUnits drawingCoordinates
        }


start :
    TouchStartEvent
    -> Rectangle2d drawingUnits drawingCoordinates
    -> ( TouchInteraction drawingUnits drawingCoordinates, Dict Int (Point2d drawingUnits drawingCoordinates) )
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


toDictEntry :
    ReferencePoint drawingUnits drawingCoordinates
    -> TouchStart
    -> ( Int, Point2d drawingUnits drawingCoordinates )
toDictEntry referencePoint touchStart =
    ( touchStart.identifier, InteractionPoint.updatedPosition referencePoint touchStart )
