module Drawing2d.Gradient.Protected exposing
    ( Gradient
    , decode
    , decoder
    , encode
    , reference
    , render
    , transformEncoded
    )

import Circle2d
import Drawing2d.Gradient.Private as Private
import Drawing2d.Gradient.Stops as Stops
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode
import Point2d
import Quantity exposing (Quantity(..))
import Svg exposing (Svg)
import Svg.Attributes


type alias Gradient units coordinates =
    Private.Gradient units coordinates


encode : Gradient units coordinates -> String
encode gradient =
    Encode.encode 0 <|
        case gradient of
            Private.LinearGradient linearGradient ->
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

            Private.RadialGradient radialGradient ->
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
    Private.LinearGradient
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
    Private.RadialGradient
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
        Private.LinearGradient linearGradient ->
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

        Private.RadialGradient radialGradient ->
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
                Private.LinearGradient { id } ->
                    id

                Private.RadialGradient { id } ->
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
