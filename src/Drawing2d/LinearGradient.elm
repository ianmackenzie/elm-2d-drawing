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


type LinearGradient units coordinates
    = LinearGradient
        { startPoint : Point2d units coordinates
        , endPoint : Point2d units coordinates
        , stops : List ( Float, Color )
        }


along : Axis2d units coordinates -> List ( Quantity Float units, Color ) -> LinearGradient units coordinates
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
                                endDistance |> Quantity.minus startDistance
                        in
                        distanceStops
                            |> List.map
                                (\( distance, color ) ->
                                    ( Quantity.ratio
                                        (distance |> Quantity.minus startDistance)
                                        delta
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


relativeTo : Frame2d units globalCoordinates localCoordinates -> LinearGradient units globalCoordinates -> LinearGradient units localCoordinates
relativeTo frame (LinearGradient gradient) =
    LinearGradient
        { startPoint = Point2d.relativeTo frame gradient.startPoint
        , endPoint = Point2d.relativeTo frame gradient.endPoint
        , stops = gradient.stops
        }


placeIn : Frame2d units globalCoordinates localCoordinates -> LinearGradient units localCoordinates -> LinearGradient units globalCoordinates
placeIn frame (LinearGradient gradient) =
    LinearGradient
        { startPoint = Point2d.placeIn frame gradient.startPoint
        , endPoint = Point2d.placeIn frame gradient.endPoint
        , stops = gradient.stops
        }


scaleAbout : Point2d units coordinates -> Float -> LinearGradient units coordinates -> LinearGradient units coordinates
scaleAbout centerPoint scale (LinearGradient gradient) =
    LinearGradient
        { startPoint = Point2d.scaleAbout centerPoint scale gradient.startPoint
        , endPoint = Point2d.scaleAbout centerPoint scale gradient.endPoint
        , stops = gradient.stops
        }
