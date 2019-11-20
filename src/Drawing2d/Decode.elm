module Drawing2d.Decode exposing
    ( button
    , changedTouches
    , clientX
    , clientY
    , container
    , identifier
    , nonempty
    , pageX
    , pageY
    , targetTouches
    , timeStamp
    , touches
    , wrongButton
    )

import BoundingBox2d exposing (BoundingBox2d)
import DOM
import Duration exposing (Duration)
import Json.Decode as Decode exposing (Decoder)
import Pixels exposing (Pixels, inPixels, pixels)
import Point2d exposing (Point2d)
import Quantity exposing (Quantity, Rate)
import Vector2d


pageX : Decoder Float
pageX =
    Decode.field "pageX" Decode.float


pageY : Decoder Float
pageY =
    Decode.field "pageY" Decode.float


clientX : Decoder Float
clientX =
    Decode.field "clientX" Decode.float


clientY : Decoder Float
clientY =
    Decode.field "clientY" Decode.float


button : Decoder Int
button =
    Decode.field "button" Decode.int


identifier : Decoder Int
identifier =
    Decode.field "identifier" Decode.int


timeStamp : Decoder Duration
timeStamp =
    Decode.map Duration.milliseconds (Decode.field "timeStamp" Decode.float)


wrongButton : Decoder msg
wrongButton =
    Decode.fail "Ignoring non-matching button"


decodeBoundingClientRectProperty : Decoder DOM.Rectangle
decodeBoundingClientRectProperty =
    Decode.field "boundingClientRect"
        (Decode.map4
            (\left top width height ->
                { left = left
                , top = top
                , width = width
                , height = height
                }
            )
            (Decode.field "left" Decode.float)
            (Decode.field "top" Decode.float)
            (Decode.field "width" Decode.float)
            (Decode.field "height" Decode.float)
        )


decodeBoundingClientRect : Decoder DOM.Rectangle
decodeBoundingClientRect =
    Decode.oneOf
        [ decodeBoundingClientRectProperty
        , DOM.boundingClientRect
        ]


container : Decoder DOM.Rectangle
container =
    Decode.field "target" <|
        Decode.oneOf
            [ Decode.at [ "ownerSVGElement", "parentNode" ] decodeBoundingClientRect
            , Decode.at [ "parentNode" ] decodeBoundingClientRect
            ]


decodeTouchList : Decoder touch -> Decoder (List touch)
decodeTouchList decodeTouch =
    Decode.field "length" Decode.int
        |> Decode.andThen (decodeTouchListItems decodeTouch [])


decodeTouchListItems : Decoder touch -> List touch -> Int -> Decoder (List touch)
decodeTouchListItems decodeTouch accumulated count =
    if count == 0 then
        Decode.succeed accumulated

    else
        Decode.field (String.fromInt (count - 1)) decodeTouch
            |> Decode.andThen
                (\touch -> decodeTouchListItems decodeTouch (touch :: accumulated) (count - 1))


touches : Decoder touch -> Decoder (List touch)
touches touchDecoder =
    Decode.field "touches" (decodeTouchList touchDecoder)


changedTouches : Decoder touch -> Decoder (List touch)
changedTouches touchDecoder =
    Decode.field "changedTouches" (decodeTouchList touchDecoder)


targetTouches : Decoder touch -> Decoder (List touch)
targetTouches touchDecoder =
    Decode.field "targetTouches" (decodeTouchList touchDecoder)


nonempty : Decoder (List a) -> Decoder ( a, List a )
nonempty listDecoder =
    listDecoder |> Decode.andThen checkNonempty


checkNonempty : List a -> Decoder ( a, List a )
checkNonempty list =
    case list of
        first :: rest ->
            Decode.succeed ( first, rest )

        [] ->
            Decode.fail "Expected nonempty list"
