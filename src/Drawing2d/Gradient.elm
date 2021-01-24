module Drawing2d.Gradient exposing
    ( Gradient
    , along
    , at
    , at_
    , circular
    , decode
    , decoder
    , encode
    , from
    , placeIn
    , reference
    , relativeTo
    , render
    , scaleAbout
    , transformEncoded
    )

import Axis2d exposing (Axis2d)
import Circle2d exposing (Circle2d)
import Color exposing (Color)
import Drawing2d.Stops as Stops exposing (Stops)
import Frame2d exposing (Frame2d)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode
import Murmur3
import Point2d exposing (Point2d)
import Quantity exposing (Quantity(..), Rate)
import Svg exposing (Svg)
import Svg.Attributes


type Gradient units coordinates
    = LinearGradient
        { id : String
        , start : Point2d units coordinates
        , end : Point2d units coordinates
        , stops : Stops
        }
    | RadialGradient
        { id : String
        , start : Point2d units coordinates
        , end : Circle2d units coordinates
        , stops : Stops
        }


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
    LinearGradient
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
    RadialGradient
        { id = id
        , start = start
        , end = end
        , stops = stops
        }


from : ( Point2d units coordinates, Color ) -> ( Point2d units coordinates, Color ) -> Gradient units coordinates
from ( startPoint, startColor ) ( endPoint, endColor ) =
    makeLinearGradient startPoint endPoint (Stops.from startColor endColor)


circular : ( Point2d units coordinates, Color ) -> ( Circle2d units coordinates, Color ) -> Gradient units coordinates
circular ( startPoint, startColor ) ( endCircle, endColor ) =
    makeRadialGradient startPoint endCircle (Stops.from startColor endColor)


relativeTo : Frame2d units globalCoordinates { defines : localCoordinates } -> Gradient units globalCoordinates -> Gradient units localCoordinates
relativeTo frame gradient =
    case gradient of
        LinearGradient linearGradient ->
            makeLinearGradient
                (Point2d.relativeTo frame linearGradient.start)
                (Point2d.relativeTo frame linearGradient.end)
                linearGradient.stops

        RadialGradient radialGradient ->
            makeRadialGradient
                (Point2d.relativeTo frame radialGradient.start)
                (Circle2d.relativeTo frame radialGradient.end)
                radialGradient.stops


placeIn : Frame2d units globalCoordinates { defines : localCoordinates } -> Gradient units localCoordinates -> Gradient units globalCoordinates
placeIn frame gradient =
    case gradient of
        LinearGradient linearGradient ->
            makeLinearGradient
                (Point2d.placeIn frame linearGradient.start)
                (Point2d.placeIn frame linearGradient.end)
                linearGradient.stops

        RadialGradient radialGradient ->
            makeRadialGradient
                (Point2d.placeIn frame radialGradient.start)
                (Circle2d.placeIn frame radialGradient.end)
                radialGradient.stops


scaleAbout : Point2d units coordinates -> Float -> Gradient units coordinates -> Gradient units coordinates
scaleAbout centerPoint scale gradient =
    case gradient of
        LinearGradient linearGradient ->
            makeLinearGradient
                (Point2d.scaleAbout centerPoint scale linearGradient.start)
                (Point2d.scaleAbout centerPoint scale linearGradient.end)
                linearGradient.stops

        RadialGradient radialGradient ->
            makeRadialGradient
                (Point2d.scaleAbout centerPoint scale radialGradient.start)
                (Circle2d.scaleAbout centerPoint scale radialGradient.end)
                radialGradient.stops


at : Quantity Float (Rate units2 units1) -> Gradient units1 coordinates -> Gradient units2 coordinates
at rate gradient =
    case gradient of
        LinearGradient linearGradient ->
            makeLinearGradient
                (Point2d.at rate linearGradient.start)
                (Point2d.at rate linearGradient.end)
                linearGradient.stops

        RadialGradient radialGradient ->
            makeRadialGradient
                (Point2d.at rate radialGradient.start)
                (Circle2d.at rate radialGradient.end)
                radialGradient.stops


at_ : Quantity Float (Rate units1 units2) -> Gradient units1 coordinates -> Gradient units2 coordinates
at_ rate gradient =
    at (Quantity.inverse rate) gradient


encode : Gradient units coordinates -> String
encode gradient =
    Encode.encode 0 <|
        case gradient of
            LinearGradient linearGradient ->
                let
                    p1 =
                        Point2d.unwrap linearGradient.start

                    p2 =
                        Point2d.unwrap linearGradient.end
                in
                Encode.list identity
                    [ Encode.string "lg"
                    , Encode.float p1.x
                    , Encode.float p1.y
                    , Encode.float p2.x
                    , Encode.float p2.y
                    , Encode.string (Stops.id linearGradient.stops)
                    ]

            RadialGradient radialGradient ->
                let
                    f =
                        Point2d.unwrap radialGradient.start

                    c =
                        Point2d.unwrap (Circle2d.centerPoint radialGradient.end)

                    (Quantity r) =
                        Circle2d.radius radialGradient.end
                in
                Encode.list identity
                    [ Encode.string "rg"
                    , Encode.float f.x
                    , Encode.float f.y
                    , Encode.float c.x
                    , Encode.float c.y
                    , Encode.float r
                    , Encode.string (Stops.id radialGradient.stops)
                    ]


decoder : Decoder (Maybe (Gradient units coordinates))
decoder =
    Decode.nullable
        (Decode.index 0 Decode.string
            |> Decode.andThen
                (\tag ->
                    case tag of
                        "lg" ->
                            Decode.map5 rebuildLinearGradient
                                (Decode.index 1 Decode.float)
                                (Decode.index 2 Decode.float)
                                (Decode.index 3 Decode.float)
                                (Decode.index 4 Decode.float)
                                (Decode.index 5 Decode.string)

                        "rg" ->
                            Decode.map6 rebuildRadialGradient
                                (Decode.index 1 Decode.float)
                                (Decode.index 2 Decode.float)
                                (Decode.index 3 Decode.float)
                                (Decode.index 4 Decode.float)
                                (Decode.index 5 Decode.float)
                                (Decode.index 6 Decode.string)

                        _ ->
                            Decode.fail ("Unexpected tag '" ++ tag ++ "'")
                )
        )


rebuildLinearGradient :
    Float
    -> Float
    -> Float
    -> Float
    -> String
    -> Gradient units coordinates
rebuildLinearGradient x1 y1 x2 y2 stopsId =
    LinearGradient
        { id = ""
        , start = Point2d.unsafe { x = x1, y = y1 }
        , end = Point2d.unsafe { x = x2, y = y2 }
        , stops = Stops.reference stopsId
        }


rebuildRadialGradient :
    Float
    -> Float
    -> Float
    -> Float
    -> Float
    -> String
    -> Gradient units coordinates
rebuildRadialGradient fx fy cx cy r stopsId =
    RadialGradient
        { id = ""
        , start = Point2d.unsafe { x = fx, y = fy }
        , end = Circle2d.withRadius (Quantity r) (Point2d.unsafe { x = cx, y = cy })
        , stops = Stops.reference stopsId
        }


decode : String -> Maybe (Gradient units coordinates)
decode string =
    if String.isEmpty string then
        Nothing

    else
        Decode.decodeString decoder string |> Result.withDefault Nothing


render : Gradient units coordinates -> List (Svg msg) -> List (Svg msg)
render gradient svgElements =
    case gradient of
        LinearGradient linearGradient ->
            let
                p1 =
                    Point2d.unwrap linearGradient.start

                p2 =
                    Point2d.unwrap linearGradient.end

                stopsId =
                    Stops.id linearGradient.stops

                gradientElement =
                    Svg.linearGradient
                        [ Svg.Attributes.id linearGradient.id
                        , Svg.Attributes.x1 (String.fromFloat p1.x)
                        , Svg.Attributes.y1 (String.fromFloat -p1.y)
                        , Svg.Attributes.x2 (String.fromFloat p2.x)
                        , Svg.Attributes.y2 (String.fromFloat -p2.y)
                        , Svg.Attributes.gradientUnits "userSpaceOnUse"
                        , Svg.Attributes.xlinkHref ("#" ++ stopsId)
                        ]
                        []
            in
            Stops.render Svg.linearGradient linearGradient.stops (gradientElement :: svgElements)

        RadialGradient radialGradient ->
            let
                f =
                    Point2d.unwrap radialGradient.start

                c =
                    Point2d.unwrap (Circle2d.centerPoint radialGradient.end)

                (Quantity r) =
                    Circle2d.radius radialGradient.end

                stopsId =
                    Stops.id radialGradient.stops

                gradientElement =
                    Svg.radialGradient
                        [ Svg.Attributes.id radialGradient.id
                        , Svg.Attributes.fx (String.fromFloat f.x)
                        , Svg.Attributes.fy (String.fromFloat -f.y)
                        , Svg.Attributes.cx (String.fromFloat c.x)
                        , Svg.Attributes.cy (String.fromFloat -c.y)
                        , Svg.Attributes.r (String.fromFloat r)
                        , Svg.Attributes.gradientUnits "userSpaceOnUse"
                        , Svg.Attributes.xlinkHref ("#" ++ stopsId)
                        ]
                        []
            in
            Stops.render Svg.radialGradient radialGradient.stops (gradientElement :: svgElements)


reference : Gradient units coordinates -> String
reference gradient =
    let
        gradientId =
            case gradient of
                LinearGradient { id } ->
                    id

                RadialGradient { id } ->
                    id
    in
    "url(#" ++ gradientId ++ ")"


transformEncoded : String -> (Gradient units coordinates1 -> Gradient units coordinates2) -> String
transformEncoded gradient function =
    if gradient == "" then
        gradient

    else
        case decode gradient of
            Just decoded ->
                encode (function decoded)

            Nothing ->
                ""
