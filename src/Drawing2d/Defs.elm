module Drawing2d.Defs
    exposing
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


type Def
    = LinearGradient LinearGradient


type Defs
    = Defs
        { nextIndex : Int
        , entries : List ( String, Def )
        }


init : Defs
init =
    Defs { nextIndex = 1, entries = [] }


add : Def -> Defs -> ( String, Defs )
add def (Defs defs) =
    let
        id =
            "defs" ++ toString defs.nextIndex

        updatedDefs =
            Defs
                { defs
                    | nextIndex = defs.nextIndex + 1
                    , entries = ( id, def ) :: defs.entries
                }
    in
    ( id, updatedDefs )


addLinearGradient : LinearGradient -> Defs -> ( String, Defs )
addLinearGradient linearGradient =
    add (LinearGradient linearGradient)


stopElement : ( Float, Color ) -> Svg msg
stopElement ( offset, color ) =
    let
        ( colorString, opacityString ) =
            Color.strings color
    in
    Svg.stop
        [ Svg.Attributes.offset (toString offset)
        , Svg.Attributes.stopColor colorString
        , Svg.Attributes.stopOpacity opacityString
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
                ( x1, y1 ) =
                    Point2d.coordinates
                        (LinearGradient.startPoint linearGradient)

                ( x2, y2 ) =
                    Point2d.coordinates
                        (LinearGradient.endPoint linearGradient)
            in
            Svg.linearGradient
                [ Svg.Attributes.id id
                , Svg.Attributes.x1 (toString x1)
                , Svg.Attributes.y1 (toString y1)
                , Svg.Attributes.x2 (toString x2)
                , Svg.Attributes.y2 (toString y2)
                , gradientUnitsAttribute
                ]
                (List.map stopElement (LinearGradient.stops linearGradient))


toSvgElement : Defs -> Svg msg
toSvgElement (Defs defs) =
    Svg.defs [] (List.map entryToElement (List.reverse defs.entries))
