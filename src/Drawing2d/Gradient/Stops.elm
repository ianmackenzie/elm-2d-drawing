module Drawing2d.Gradient.Stops exposing
    ( Stops
    , constant
    , empty
    , from
    , fromList
    , id
    , reference
    , render
    )

import Color exposing (Color)
import Murmur3
import Svg exposing (Svg)
import Svg.Attributes


type Stops
    = Values String (List Stop)
    | Reference String


type alias Stop =
    { offset : String
    , color : String
    }


id : Stops -> String
id stops =
    case stops of
        Values stopsId values ->
            stopsId

        Reference stopsId ->
            stopsId


toStop : ( Float, Color ) -> Stop
toStop ( fraction, color ) =
    { offset = String.fromFloat (fraction * 100) ++ "%"
    , color = Color.toCssString color
    }


empty : Stops
empty =
    fromList []


constant : Color -> Stops
constant color =
    fromList [ ( 0, color ) ]


from : Color -> Color -> Stops
from firstColor secondColor =
    fromList [ ( 0, firstColor ), ( 1, secondColor ) ]


fromList : List ( Float, Color ) -> Stops
fromList fractionalStops =
    let
        values =
            List.map toStop fractionalStops

        valuesString =
            String.join "," (List.map stopString values)

        hashValue =
            Murmur3.hashString 0 valuesString

        stopsId =
            "stops" ++ String.fromInt hashValue
    in
    Values stopsId values


stopString : Stop -> String
stopString { offset, color } =
    offset ++ ":" ++ color


reference : String -> Stops
reference stopsId =
    Reference stopsId


render : (List (Svg.Attribute msg) -> List (Svg msg) -> Svg msg) -> Stops -> List (Svg msg) -> List (Svg msg)
render toSvgElement stops accumulated =
    case stops of
        Values stopsId stopValues ->
            let
                svgElement =
                    toSvgElement [ Svg.Attributes.id stopsId ] (List.map stopElement stopValues)
            in
            svgElement :: accumulated

        Reference _ ->
            accumulated


stopElement : Stop -> Svg msg
stopElement { offset, color } =
    Svg.stop [ Svg.Attributes.offset offset, Svg.Attributes.stopColor color ] []
