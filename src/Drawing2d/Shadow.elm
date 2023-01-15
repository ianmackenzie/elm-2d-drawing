module Drawing2d.Shadow exposing
    ( Shadow
    , render
    , with
    )

import Color exposing (Color)
import Drawing2d.RenderedSvg as RenderedSvg exposing (RenderedSvg)
import Quantity exposing (Quantity(..))
import Svg exposing (Svg)
import Svg.Attributes
import Vector2d exposing (Vector2d)
import VirtualDom


type Shadow units coordinates
    = Shadow
        { id : String
        , stdDeviation : String
        , dx : String
        , dy : String
        , floodColor : String
        , floodOpacity : String
        }


with :
    { radius : Quantity Float units, offset : Vector2d units coordinates, color : Color }
    -> Shadow units coordinates
with { radius, offset, color } =
    let
        { x, y } =
            Vector2d.unwrap offset

        xString =
            String.fromFloat x

        yString =
            String.fromFloat -y

        (Quantity r) =
            radius

        { red, green, blue, alpha } =
            Color.toRgba color

        opaqueColor =
            Color.fromRgba { red = red, green = green, blue = blue, alpha = 1 }

        generatedId =
            String.join "_"
                [ "ds"
                , xString
                , yString
                , String.fromFloat r
                , String.fromFloat red
                , String.fromFloat green
                , String.fromFloat blue
                , String.fromFloat alpha
                ]
    in
    Shadow
        { id = generatedId
        , dx = xString
        , dy = yString
        , stdDeviation = String.fromFloat (r / 2)
        , floodColor = Color.toCssString opaqueColor
        , floodOpacity = String.fromFloat alpha
        }


render : Shadow units coordinates -> RenderedSvg units coordinates msg
render (Shadow shadow) =
    RenderedSvg.with
        { attributes = [ Svg.Attributes.filter ("url(#" ++ shadow.id ++ ")") ]
        , elements =
            [ Svg.filter [ Svg.Attributes.id shadow.id ]
                [ VirtualDom.nodeNS "http://www.w3.org/2000/svg"
                    "feDropShadow"
                    [ Svg.Attributes.dx shadow.dx
                    , Svg.Attributes.dy shadow.dy
                    , Svg.Attributes.stdDeviation shadow.stdDeviation
                    , Svg.Attributes.floodColor shadow.floodColor
                    , Svg.Attributes.floodOpacity shadow.floodOpacity
                    ]
                    []
                ]
            ]
        }
