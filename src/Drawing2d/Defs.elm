module Drawing2d.Defs exposing
    ( Defs
    , addLinearGradient
    , init
    , toSvgElement
    )

import Color exposing (Color)
import Drawing2d.Color as Color
import Drawing2d.LinearGradient as LinearGradient exposing (LinearGradient)
import Point2d exposing (Point2d)
import Svg exposing (Svg)
import Svg.Attributes


type Def units coordinates
    = LinearGradient (LinearGradient units coordinates)


type Defs units coordinates
    = Defs
        { nextIndex : Int
        , entries : List ( String, Def units coordinates )
        }


init : Defs units coordinates
init =
    Defs { nextIndex = 1, entries = [] }


add : Def units coordinates -> Defs units coordinates -> ( String, Defs units coordinates )
add def (Defs defs) =
    let
        id =
            "defs" ++ String.fromInt defs.nextIndex

        updatedDefs =
            Defs
                { defs
                    | nextIndex = defs.nextIndex + 1
                    , entries = ( id, def ) :: defs.entries
                }
    in
    ( id, updatedDefs )


addLinearGradient : LinearGradient units coordinates -> Defs units coordinates -> ( String, Defs units coordinates )
addLinearGradient linearGradient =
    add (LinearGradient linearGradient)


stopElement : ( Float, Color ) -> Svg msg
stopElement ( offset, color ) =
    Svg.stop
        [ Svg.Attributes.offset (toString offset)
        , Svg.Attributes.stopColor (Color.toCssString color)
        ]
        []


gradientUnitsAttribute : Svg.Attribute msg
gradientUnitsAttribute =
    Svg.Attributes.gradientUnits "userSpaceOnUse"


entryToElement : ( String, Def ) -> Svg msg
entryToElement ( id, def ) =
    case def of
        LinearGradient linearGradient ->
            let
                ( Quantity x1, Quantity y1 ) =
                    Point2d.coordinates
                        (LinearGradient.startPoint linearGradient)

                ( Quantity x2, Quantity y2 ) =
                    Point2d.coordinates
                        (LinearGradient.endPoint linearGradient)
            in
            Svg.linearGradient
                [ Svg.Attributes.id id
                , Svg.Attributes.x1 (String.fromFloat x1)
                , Svg.Attributes.y1 (String.fromFloat y1)
                , Svg.Attributes.x2 (String.fromFloat x2)
                , Svg.Attributes.y2 (String.fromFloat y2)
                , gradientUnitsAttribute
                ]
                (List.map stopElement (LinearGradient.stops linearGradient))


toSvgElement : Defs -> Svg msg
toSvgElement (Defs defs) =
    Svg.defs [] (List.map entryToElement (List.reverse defs.entries))
