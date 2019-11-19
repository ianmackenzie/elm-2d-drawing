module Drawing2d.Gradient exposing
    ( Gradient
    , along
    , circular
    , from
    , placeIn
    , relativeTo
    , scaleAbout
    )

import Axis2d exposing (Axis2d)
import Circle2d exposing (Circle2d)
import Color exposing (Color)
import Drawing2d.Gradient.Private as Private
import Drawing2d.Gradient.Stops as Stops exposing (Stops)
import Frame2d exposing (Frame2d)
import Murmur3
import Point2d exposing (Point2d)
import Quantity exposing (Quantity(..))


type alias Gradient units coordinates =
    Private.Gradient units coordinates


along : Axis2d units coordinates -> List ( Quantity Float units, Color ) -> Gradient units coordinates
along axis distanceStops =
    case distanceStops of
        [] ->
            makeLinearGradient Point2d.origin Point2d.origin Stops.empty

        [ ( distance, color ) ] ->
            makeLinearGradient Point2d.origin Point2d.origin (Stops.constant color)

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

                fractionalStops =
                    if startDistance == endDistance then
                        [ ( 0, endColor ) ]

                    else
                        let
                            delta =
                                endDistance |> Quantity.minus startDistance
                        in
                        distanceStops
                            |> List.map (toFractionalStop startDistance delta)
            in
            makeLinearGradient startPoint endPoint (Stops.fromList fractionalStops)


toFractionalStop : Quantity Float units -> Quantity Float units -> ( Quantity Float units, Color ) -> ( Float, Color )
toFractionalStop startDistance delta ( distance, color ) =
    ( Quantity.ratio (distance |> Quantity.minus startDistance) delta
    , color
    )


makeLinearGradient : Point2d units coordinates -> Point2d units coordinates -> Stops -> Gradient units coordinates
makeLinearGradient start end stops =
    let
        p1 =
            Point2d.unwrap start

        p2 =
            Point2d.unwrap end

        id =
            String.join "_"
                [ "lg"
                , String.fromFloat p1.x
                , String.fromFloat p1.y
                , String.fromFloat p2.x
                , String.fromFloat p2.y
                , Stops.id stops
                ]
    in
    Private.LinearGradient
        { id = id
        , start = start
        , end = end
        , stops = stops
        }


makeRadialGradient : Point2d units coordinates -> Circle2d units coordinates -> Stops -> Gradient units coordinates
makeRadialGradient start end stops =
    let
        f =
            Point2d.unwrap start

        c =
            Point2d.unwrap (Circle2d.centerPoint end)

        (Quantity r) =
            Circle2d.radius end

        id =
            String.join "_"
                [ "rg"
                , String.fromFloat f.x
                , String.fromFloat f.y
                , String.fromFloat c.x
                , String.fromFloat c.y
                , String.fromFloat r
                , Stops.id stops
                ]
    in
    Private.RadialGradient
        { id = id
        , start = start
        , end = end
        , stops = stops
        }


from : ( Point2d units coordinates, Color ) -> ( Point2d units coordinates, Color ) -> Gradient units coordinates
from ( startPoint, startColor ) ( endPoint, endColor ) =
    makeLinearGradient startPoint endPoint (Stops.from startColor endColor)


circular : Circle2d units coordinates -> Color -> Color -> Gradient units coordinates
circular circle startColor endColor =
    makeRadialGradient (Circle2d.centerPoint circle) circle (Stops.from startColor endColor)


relativeTo : Frame2d units globalCoordinates { defines : localCoordinates } -> Gradient units globalCoordinates -> Gradient units localCoordinates
relativeTo frame gradient =
    case gradient of
        Private.LinearGradient linearGradient ->
            makeLinearGradient
                (Point2d.relativeTo frame linearGradient.start)
                (Point2d.relativeTo frame linearGradient.end)
                linearGradient.stops

        Private.RadialGradient radialGradient ->
            makeRadialGradient
                (Point2d.relativeTo frame radialGradient.start)
                (Circle2d.relativeTo frame radialGradient.end)
                radialGradient.stops


placeIn : Frame2d units globalCoordinates { defines : localCoordinates } -> Gradient units localCoordinates -> Gradient units globalCoordinates
placeIn frame gradient =
    case gradient of
        Private.LinearGradient linearGradient ->
            makeLinearGradient
                (Point2d.placeIn frame linearGradient.start)
                (Point2d.placeIn frame linearGradient.end)
                linearGradient.stops

        Private.RadialGradient radialGradient ->
            makeRadialGradient
                (Point2d.placeIn frame radialGradient.start)
                (Circle2d.placeIn frame radialGradient.end)
                radialGradient.stops


scaleAbout : Point2d units coordinates -> Float -> Gradient units coordinates -> Gradient units coordinates
scaleAbout centerPoint scale gradient =
    case gradient of
        Private.LinearGradient linearGradient ->
            makeLinearGradient
                (Point2d.scaleAbout centerPoint scale linearGradient.start)
                (Point2d.scaleAbout centerPoint scale linearGradient.end)
                linearGradient.stops

        Private.RadialGradient radialGradient ->
            makeRadialGradient
                (Point2d.scaleAbout centerPoint scale radialGradient.start)
                (Circle2d.scaleAbout centerPoint scale radialGradient.end)
                radialGradient.stops
