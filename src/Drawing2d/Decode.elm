module Drawing2d.Decode exposing
    ( BoundingClientRect
    , boundingClientRect
    , button
    , changedTouches
    , clientX
    , clientY
    , container
    , identifier
    , movementX
    , movementY
    , nonempty
    , pageX
    , pageY
    , targetTouches
    , timeStamp
    , touches
    , wrongButton
    )

import BoundingBox2d exposing (BoundingBox2d)
import Duration exposing (Duration)
import Json.Decode as Decode exposing (Decoder)
import Pixels exposing (Pixels)
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


movementX : Decoder Float
movementX =
    Decode.field "movementX" Decode.float


movementY : Decoder Float
movementY =
    Decode.field "movementY" Decode.float


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


type alias BoundingClientRect =
    { left : Float
    , top : Float
    , width : Float
    , height : Float
    }


boundingClientRectProperty : Decoder BoundingClientRect
boundingClientRectProperty =
    Decode.field "boundingClientRect"
        (Decode.map4 BoundingClientRect
            (Decode.field "left" Decode.float)
            (Decode.field "top" Decode.float)
            (Decode.field "width" Decode.float)
            (Decode.field "height" Decode.float)
        )


computedBoundingClientRect : Decoder BoundingClientRect
computedBoundingClientRect =
    Decode.map3
        (\( x, y ) width height ->
            { left = x
            , top = y
            , width = width
            , height = height
            }
        )
        elementPosition
        (Decode.field "offsetWidth" Decode.float)
        (Decode.field "offsetHeight" Decode.float)


elementPosition : Decoder ( Float, Float )
elementPosition =
    Decode.map7
        (\( parentX, parentY ) scrollLeft scrollTop offsetLeft offsetTop clientLeft clientTop ->
            ( parentX + offsetLeft - scrollLeft + clientLeft
            , parentY + offsetTop - scrollTop + clientTop
            )
        )
        parentPosition
        (Decode.field "scrollLeft" Decode.float)
        (Decode.field "scrollTop" Decode.float)
        (Decode.field "offsetLeft" Decode.float)
        (Decode.field "offsetTop" Decode.float)
        (Decode.field "clientLeft" Decode.float)
        (Decode.field "clientTop" Decode.float)


parentPosition : Decoder ( Float, Float )
parentPosition =
    Decode.field "tagName" Decode.string
        |> Decode.andThen
            (\tagName ->
                case tagName of
                    "BODY" ->
                        -- Decode position of the parent <html> element to
                        -- capture top-level scroll (the <html> element is not
                        -- considered the offsetParent of the <body> element for
                        -- some reason, but it _is_ the parentNode)
                        decodeParentNodePosition

                    "HTML" ->
                        -- The 'parent' of the <html> element is just the
                        -- window itself
                        decodeWindowPosition

                    _ ->
                        -- In the general case, get the position of this
                        -- node's offsetParent
                        decodeOffsetParentPosition
            )


decodeParentNodePosition : Decoder ( Float, Float )
decodeParentNodePosition =
    Decode.field "parentNode" elementPosition


decodeWindowPosition : Decoder ( Float, Float )
decodeWindowPosition =
    -- The browser window itself has, by definition, a position in client
    -- coordinates of ( 0, 0 )
    Decode.succeed ( 0, 0 )


decodeOffsetParentPosition : Decoder ( Float, Float )
decodeOffsetParentPosition =
    -- Not entirely sure if this decoder should return ( 0, 0 ) or just fail
    -- if offsetParent is null
    Decode.field "offsetParent" <|
        Decode.oneOf
            [ Decode.null ( 0, 0 )
            , elementPosition
            ]


boundingClientRect : Decoder BoundingClientRect
boundingClientRect =
    Decode.oneOf
        [ boundingClientRectProperty
        , computedBoundingClientRect
        ]


container : Decoder BoundingClientRect
container =
    Decode.field "target" <|
        Decode.oneOf
            [ Decode.at [ "ownerSVGElement", "parentNode" ] boundingClientRect
            , Decode.at [ "parentNode" ] boundingClientRect
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
