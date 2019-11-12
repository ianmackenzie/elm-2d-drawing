module Drawing2d.Utils exposing
    ( decodeButton
    , decodeClientX
    , decodeClientY
    , decodeMouseEvent
    , decodePageX
    , decodePageY
    , drawingScale
    , toDrawingPoint
    , wrongButton
    )

import BoundingBox2d exposing (BoundingBox2d)
import DOM
import Drawing2d.Types exposing (MouseEvent)
import Json.Decode as Decode exposing (Decoder)
import Pixels exposing (Pixels, inPixels, pixels)
import Point2d exposing (Point2d)
import Quantity exposing (Quantity, Rate)
import Vector2d


decodePageX : Decoder Float
decodePageX =
    Decode.field "pageX" Decode.float


decodePageY : Decoder Float
decodePageY =
    Decode.field "pageY" Decode.float


decodeClientX : Decoder Float
decodeClientX =
    Decode.field "clientX" Decode.float


decodeClientY : Decoder Float
decodeClientY =
    Decode.field "clientY" Decode.float


decodeButton : Decoder Int
decodeButton =
    Decode.field "button" Decode.int


drawingScale : BoundingBox2d Pixels drawingCoordinates -> DOM.Rectangle -> Float
drawingScale viewBox container =
    let
        ( drawingWidth, drawingHeight ) =
            BoundingBox2d.dimensions viewBox

        xScale =
            container.width / inPixels drawingWidth

        yScale =
            container.height / inPixels drawingHeight
    in
    min xScale yScale


toDrawingPoint :
    BoundingBox2d Pixels drawingCoordinates
    -> { a | container : DOM.Rectangle, clientX : Float, clientY : Float }
    -> Point2d Pixels drawingCoordinates
toDrawingPoint viewBox event =
    let
        scale =
            drawingScale viewBox event.container

        containerMidX =
            event.container.left + event.container.width / 2

        containerMidY =
            event.container.top + event.container.height / 2

        containerDeltaX =
            event.clientX - containerMidX

        containerDeltaY =
            event.clientY - containerMidY

        drawingDeltaX =
            pixels (containerDeltaX / scale)

        drawingDeltaY =
            pixels (-containerDeltaY / scale)
    in
    BoundingBox2d.centerPoint viewBox
        |> Point2d.translateBy (Vector2d.xy drawingDeltaX drawingDeltaY)


wrongButton : Decoder msg
wrongButton =
    Decode.fail "Ignoring non-matching button"


decodeBoundingClientRect : Decoder DOM.Rectangle
decodeBoundingClientRect =
    DOM.boundingClientRect


decodeContainer : Decoder DOM.Rectangle
decodeContainer =
    Decode.field "target" <|
        Decode.oneOf
            [ Decode.at [ "ownerSVGElement", "parentNode" ] decodeBoundingClientRect
            , Decode.at [ "parentNode" ] decodeBoundingClientRect
            ]


decodeMouseEvent : Decoder MouseEvent
decodeMouseEvent =
    Decode.map6 MouseEvent
        decodeContainer
        decodeClientX
        decodeClientY
        decodePageX
        decodePageY
        decodeButton
