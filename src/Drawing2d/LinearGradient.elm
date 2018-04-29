module Drawing2d.LinearGradient
    exposing
        ( LinearGradient
        , along
        , endPoint
        , from
        , startPoint
        , stops
        )

import Axis2d exposing (Axis2d)
import Color exposing (Color)
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

                startPoint =
                    Point2d.along axis startDistance

                endPoint =
                    Point2d.along axis endDistance

                stops =
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
                { startPoint = startPoint
                , endPoint = endPoint
                , stops = stops
                }


from : ( Point2d, Color ) -> ( Point2d, Color ) -> LinearGradient
from ( startPoint, startColor ) ( endPoint, endColor ) =
    LinearGradient
        { startPoint = startPoint
        , endPoint = endPoint
        , stops = [ ( 0, startColor ), ( 1, endColor ) ]
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
