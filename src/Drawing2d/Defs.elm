module Drawing2d.Defs
    exposing
        ( Defs
        , addLinearGradient
        , init
        , toSvgElement
        )

import Color exposing (Color)
import Drawing2d.Color as Color
import LineSegment2d exposing (LineSegment2d)
import Point2d
import Svg exposing (Svg)
import Svg.Attributes


type Def
    = LinearGradient LineSegment2d (List ( Float, Color ))


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


addLinearGradient : LineSegment2d -> List ( Float, Color ) -> Defs -> ( String, Defs )
addLinearGradient lineSegment stops =
    add (LinearGradient lineSegment stops)


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


entryToElement : ( String, Def ) -> Svg msg
entryToElement ( id, def ) =
    case def of
        LinearGradient lineSegment stops ->
            let
                ( p1, p2 ) =
                    LineSegment2d.endpoints lineSegment

                ( x1, y1 ) =
                    Point2d.coordinates p1

                ( x2, y2 ) =
                    Point2d.coordinates p2
            in
            Svg.linearGradient
                [ Svg.Attributes.id id
                , Svg.Attributes.x1 (toString x1)
                , Svg.Attributes.y1 (toString y1)
                , Svg.Attributes.x2 (toString x2)
                , Svg.Attributes.y2 (toString y2)
                , Svg.Attributes.gradientUnits "userSpaceOnUse"
                ]
                (List.map stopElement stops)


toSvgElement : Defs -> Svg msg
toSvgElement (Defs defs) =
    Svg.defs [] (List.map entryToElement defs.entries)
