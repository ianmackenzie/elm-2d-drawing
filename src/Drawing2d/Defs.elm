module Drawing2d.Defs
    exposing
        ( Defs
        , addLinearGradientStops
        , init
        , instantiateLinearGradient
        , toSvgElement
        )

import Color exposing (Color)
import Drawing2d.Color as Color
import Point2d exposing (Point2d)
import Svg exposing (Svg)
import Svg.Attributes


type Def
    = LinearGradientStops (List ( Float, Color ))
    | LinearGradientInstantiation String Point2d Point2d


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


addLinearGradientStops : List ( Float, Color ) -> Defs -> ( String, Defs )
addLinearGradientStops stops =
    add (LinearGradientStops stops)


instantiateLinearGradient : String -> Point2d -> Point2d -> Defs -> ( String, Defs )
instantiateLinearGradient id localStartPoint localEndPoint defs =
    add (LinearGradientInstantiation id localStartPoint localEndPoint) defs


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
        LinearGradientStops stops ->
            Svg.linearGradient
                [ Svg.Attributes.id id
                ]
                (List.map stopElement stops)

        LinearGradientInstantiation referencedId startPoint endPoint ->
            let
                ( x1, y1 ) =
                    Point2d.coordinates startPoint

                ( x2, y2 ) =
                    Point2d.coordinates endPoint
            in
            Svg.linearGradient
                [ Svg.Attributes.id id
                , Svg.Attributes.x1 (toString x1)
                , Svg.Attributes.y1 (toString y1)
                , Svg.Attributes.x2 (toString x2)
                , Svg.Attributes.y2 (toString y2)
                , gradientUnitsAttribute
                , Svg.Attributes.xlinkHref ("#" ++ referencedId)
                ]
                []


toSvgElement : Defs -> Svg msg
toSvgElement (Defs defs) =
    Svg.defs [] (List.map entryToElement (List.reverse defs.entries))
