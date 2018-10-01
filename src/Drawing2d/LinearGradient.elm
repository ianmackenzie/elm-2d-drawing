module Drawing2d.LinearGradient exposing
    ( LinearGradient
    , along
    , endPoint
    , from
    , placeIn
    , relativeTo
    , scaleAbout
    , startPoint
    , stops
    )

import Axis2d exposing (Axis2d)
import Color exposing (Color)
import Frame2d exposing (Frame2d)
import Point2d exposing (Point2d)


type LinearGradient
    = LinearGradient
        { startPoint : Point2d
        , endPoint : Point2d
        , stops : List ( Float, Color )
        }


along : Axis2d -> List ( Float, Color ) -> LinearGradient
along axis distanceStops =
    case distanceStops of
        [] ->
            LinearGradient
                { startPoint = Point2d.origin
                , endPoint = Point2d.origin
                , stops = []
                }

        [ ( distance, color ) ] ->
            LinearGradient
                { startPoint = Point2d.origin
                , endPoint = Point2d.origin
                , stops = [ ( 0, color ) ]
                }

        firstDistanceStop :: secondDistanceStop :: rest ->
            let
                ( startDistance, _ ) =
                    firstDistanceStop

                lastDistanceStop =
                    List.foldl always secondDistanceStop rest

                ( endDistance, endColor ) =
                    lastDistanceStop

                startPoint_ =
                    Point2d.along axis startDistance

                endPoint_ =
                    Point2d.along axis endDistance

                fractionStops =
                    if startDistance == endDistance then
                        [ ( 0, endColor ) ]

                    else
                        let
                            delta =
                                endDistance - startDistance
                        in
                        distanceStops
                            |> List.map
                                (\( distance, color ) ->
                                    ( (distance - startDistance) / delta
                                    , color
                                    )
                                )
            in
            LinearGradient
                { startPoint = startPoint_
                , endPoint = endPoint_
                , stops = fractionStops
                }


from : ( Point2d, Color ) -> ( Point2d, Color ) -> LinearGradient
from ( givenStartPoint, givenStartColor ) ( givenEndPoint, givenEndColor ) =
    LinearGradient
        { startPoint = givenStartPoint
        , endPoint = givenEndPoint
        , stops = [ ( 0, givenStartColor ), ( 1, givenEndColor ) ]
        }


startPoint : LinearGradient -> Point2d
startPoint (LinearGradient gradient) =
    gradient.startPoint


endPoint : LinearGradient -> Point2d
endPoint (LinearGradient gradient) =
    gradient.endPoint


stops : LinearGradient -> List ( Float, Color )
stops (LinearGradient gradient) =
    gradient.stops


relativeTo : Frame2d -> LinearGradient -> LinearGradient
relativeTo frame (LinearGradient gradient) =
    LinearGradient
        { startPoint = Point2d.relativeTo frame gradient.startPoint
        , endPoint = Point2d.relativeTo frame gradient.endPoint
        , stops = gradient.stops
        }


placeIn : Frame2d -> LinearGradient -> LinearGradient
placeIn frame (LinearGradient gradient) =
    LinearGradient
        { startPoint = Point2d.placeIn frame gradient.startPoint
        , endPoint = Point2d.placeIn frame gradient.endPoint
        , stops = gradient.stops
        }


scaleAbout : Point2d -> Float -> LinearGradient -> LinearGradient
scaleAbout centerPoint scale (LinearGradient gradient) =
    LinearGradient
        { startPoint = Point2d.scaleAbout centerPoint scale gradient.startPoint
        , endPoint = Point2d.scaleAbout centerPoint scale gradient.endPoint
        , stops = gradient.stops
        }
