module Drawing2d.Utils exposing
    ( computeDrawingScale
    , debugDecoder
    , decodeButton
    , decodeClientX
    , decodeClientY
    , decodeMouseMoveEvent
    , decodeMouseStartEvent
    , decodePageX
    , decodePageY
    , decodeTouchEndEvent
    , decodeTouchMoveEvent
    , decodeTouchStartEvent
    , isMemberOf
    , isSameTouch
    , isSubsetOf
    , toDisplacedPoint
    , toDrawingPoint
    , wrongButton
    )

import BoundingBox2d exposing (BoundingBox2d)
import DOM
import Drawing2d.Types
    exposing
        ( MouseMoveEvent
        , MouseStartEvent
        , TouchEnd
        , TouchEndEvent
        , TouchMove
        , TouchMoveEvent
        , TouchStart
        , TouchStartEvent
        )
import Duration exposing (Duration)
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


decodeIdentifier : Decoder Int
decodeIdentifier =
    Decode.field "identifier" Decode.int


decodeTimeStamp : Decoder Duration
decodeTimeStamp =
    Decode.map Duration.milliseconds (Decode.field "timeStamp" Decode.float)


computeDrawingScale : BoundingBox2d Pixels drawingCoordinates -> DOM.Rectangle -> Float
computeDrawingScale viewBox container =
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
    -> DOM.Rectangle
    -> { a | clientX : Float, clientY : Float }
    -> Point2d Pixels drawingCoordinates
toDrawingPoint viewBox container { clientX, clientY } =
    let
        scale =
            computeDrawingScale viewBox container

        containerMidX =
            container.left + container.width / 2

        containerMidY =
            container.top + container.height / 2

        containerDeltaX =
            clientX - containerMidX

        containerDeltaY =
            clientY - containerMidY

        drawingDeltaX =
            pixels (containerDeltaX / scale)

        drawingDeltaY =
            pixels (-containerDeltaY / scale)
    in
    BoundingBox2d.centerPoint viewBox
        |> Point2d.translateBy (Vector2d.xy drawingDeltaX drawingDeltaY)


toDisplacedPoint :
    { a | pageX : Float, pageY : Float }
    -> Float
    -> Point2d Pixels drawingCoordinates
    -> { b | pageX : Float, pageY : Float }
    -> Point2d Pixels drawingCoordinates
toDisplacedPoint start drawingScale initialPoint current =
    let
        displacement =
            Vector2d.pixels
                ((current.pageX - start.pageX) / drawingScale)
                ((start.pageY - current.pageY) / drawingScale)
    in
    initialPoint |> Point2d.translateBy displacement


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


decodeMouseStartEvent : Decoder MouseStartEvent
decodeMouseStartEvent =
    Decode.map6 MouseStartEvent
        decodeContainer
        decodeClientX
        decodeClientY
        decodePageX
        decodePageY
        decodeButton


decodeMouseMoveEvent : Decoder MouseMoveEvent
decodeMouseMoveEvent =
    Decode.map2 MouseMoveEvent
        decodePageX
        decodePageY


decodeTouchStartEvent : Decoder TouchStartEvent
decodeTouchStartEvent =
    Decode.map5 TouchStartEvent
        decodeContainer
        decodeTimeStamp
        (Decode.field "touches" decodeTouchStartList)
        (Decode.field "targetTouches" decodeTouchStartList)
        (Decode.field "changedTouches" decodeTouchStartList)


decodeTouchList : Decoder touch -> Decoder (List touch)
decodeTouchList decodeTouch =
    Decode.field "length" Decode.int
        |> Decode.andThen (decodeTouchListItems decodeTouch [])


decodeTouchStartList : Decoder (List TouchStart)
decodeTouchStartList =
    decodeTouchList decodeTouchStart


decodeTouchMoveList : Decoder (List TouchMove)
decodeTouchMoveList =
    decodeTouchList decodeTouchMove


decodeTouchEndList : Decoder (List TouchEnd)
decodeTouchEndList =
    decodeTouchList decodeTouchEnd


decodeTouchListItems : Decoder touch -> List touch -> Int -> Decoder (List touch)
decodeTouchListItems decodeTouch touches count =
    if count == 0 then
        Decode.succeed touches

    else
        Decode.field (String.fromInt (count - 1)) decodeTouch
            |> Decode.andThen
                (\touch -> decodeTouchListItems decodeTouch (touch :: touches) (count - 1))


decodeTouchStart : Decoder TouchStart
decodeTouchStart =
    Decode.map5 TouchStart
        decodeIdentifier
        decodeClientX
        decodeClientY
        decodePageX
        decodePageY


decodeTouchMove : Decoder TouchMove
decodeTouchMove =
    Decode.map3 TouchMove
        decodeIdentifier
        decodePageX
        decodePageY


decodeTouchMoveEvent : Decoder TouchMoveEvent
decodeTouchMoveEvent =
    Decode.map3 TouchMoveEvent
        (Decode.field "touches" decodeTouchMoveList)
        (Decode.field "targetTouches" decodeTouchMoveList)
        (Decode.field "changedTouches" decodeTouchMoveList)


decodeTouchEndEvent : Decoder TouchEndEvent
decodeTouchEndEvent =
    Decode.map4 TouchEndEvent
        decodeTimeStamp
        (Decode.field "touches" decodeTouchEndList)
        (Decode.field "targetTouches" decodeTouchEndList)
        (Decode.field "changedTouches" decodeTouchEndList)


decodeTouchEnd : Decoder TouchEnd
decodeTouchEnd =
    Decode.map TouchEnd decodeIdentifier


isSameTouch : { a | identifier : Int } -> { b | identifier : Int } -> Bool
isSameTouch firstTouch secondTouch =
    firstTouch.identifier == secondTouch.identifier


isMemberOf : List { a | identifier : Int } -> { b | identifier : Int } -> Bool
isMemberOf touches touch =
    List.any (isSameTouch touch) touches


isSubsetOf : List { a | identifier : Int } -> List { b | identifier : Int } -> Bool
isSubsetOf touches subset =
    List.all (isMemberOf touches) subset


debugDecoder : Decode.Decoder a -> Decode.Decoder a
debugDecoder decoder =
    Decode.value
        |> Decode.andThen
            (\value ->
                case Decode.decodeValue decoder value of
                    Ok _ ->
                        decoder

                    Err error ->
                        let
                            _ =
                                Debug.log "Decoding failed" error
                        in
                        decoder
            )
