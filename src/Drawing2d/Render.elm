module Drawing2d.Render exposing
    ( cursor
    , dominantBaseline
    , eventHandlers
    , fontSize
    , fontWeight
    , opacity
    , strokeWidth
    , textAnchor
    , textColor
    )

import Color exposing (Color)
import Dict exposing (Dict)
import Drawing2d.Cursor as Cursor exposing (Cursor)
import Drawing2d.Event exposing (Event)
import Drawing2d.RenderedSvg as RenderedSvg exposing (RenderedSvg)
import Html.Attributes
import Json.Decode as Decode exposing (Decoder)
import Quantity exposing (Quantity)
import Svg
import Svg.Attributes
import Svg.Events


opacity : Float -> RenderedSvg units coordinates msg
opacity value =
    RenderedSvg.attributes [ Svg.Attributes.opacity (String.fromFloat value) ]


strokeWidth : Quantity Float units -> RenderedSvg units coordinates msg
strokeWidth width =
    RenderedSvg.attributes
        [ Svg.Attributes.strokeWidth (String.fromFloat (Quantity.unwrap width)) ]


fontSize : Quantity Float units -> RenderedSvg units coordinates msg
fontSize size =
    RenderedSvg.attributes
        [ Svg.Attributes.fontSize (String.fromFloat (Quantity.unwrap size)) ]


textColor : Color -> RenderedSvg units coordinates msg
textColor color =
    RenderedSvg.attributes [ Svg.Attributes.color (Color.toCssString color) ]


fontWeight : Int -> RenderedSvg units coordinates msg
fontWeight weight =
    RenderedSvg.attributes [ Svg.Attributes.fontWeight (String.fromInt weight) ]


cursor : Cursor -> RenderedSvg units coordinates msg
cursor givenCursor =
    RenderedSvg.attributes [ Svg.Attributes.cursor (Cursor.toString givenCursor) ]


eventHandlers :
    Dict String (List (Decoder (Event units coordinates msg)))
    -> RenderedSvg units coordinates msg
eventHandlers handlerDict =
    Dict.foldl addEventHandler [] handlerDict
        |> suppressTouchActions handlerDict
        |> RenderedSvg.attributes


addEventHandler :
    String
    -> List (Decoder (Event units coordinates msg))
    -> List (Svg.Attribute (Event units coordinates msg))
    -> List (Svg.Attribute (Event units coordinates msg))
addEventHandler eventName decoders svgAttributes =
    on eventName (Decode.oneOf decoders) :: svgAttributes


on : String -> Decoder (Event units coordinates msg) -> Svg.Attribute (Event units coordinates msg)
on eventName decoder =
    Svg.Events.custom eventName (preventDefaultAndStopPropagation decoder)


preventDefaultAndStopPropagation :
    Decoder msg
    -> Decoder { message : msg, preventDefault : Bool, stopPropagation : Bool }
preventDefaultAndStopPropagation =
    Decode.map (\message -> { message = message, preventDefault = True, stopPropagation = True })


suppressTouchActions :
    Dict String (List (Decoder (Event units coordinates msg)))
    -> List (Svg.Attribute (Event units coordinates msg))
    -> List (Svg.Attribute (Event units coordinates msg))
suppressTouchActions handlerDict svgAttributes =
    if
        Dict.member "touchstart" handlerDict
            || Dict.member "touchmove" handlerDict
            || Dict.member "touchend" handlerDict
    then
        Html.Attributes.style "touch-action" "none" :: svgAttributes

    else
        svgAttributes


textAnchor : String -> RenderedSvg units coordinates msg
textAnchor string =
    RenderedSvg.attributes [ Svg.Attributes.textAnchor string ]


dominantBaseline : String -> RenderedSvg units coordinates msg
dominantBaseline string =
    RenderedSvg.attributes [ Svg.Attributes.dominantBaseline string ]
