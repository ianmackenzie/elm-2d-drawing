module Drawing2d.Events exposing
    ( decodeLeftClick
    , decodeLeftMouseDown
    , decodeLeftMouseUp
    , decodeMiddleMouseDown
    , decodeMiddleMouseUp
    , decodeRightClick
    , decodeRightMouseDown
    , decodeRightMouseUp
    , decodeTouchStart
    , onLeftClick
    , onLeftMouseDown
    , onLeftMouseUp
    , onMiddleMouseDown
    , onMiddleMouseUp
    , onRightClick
    , onRightMouseDown
    , onRightMouseUp
    , onTouchStart
    )

import Dict exposing (Dict)
import Drawing2d.Attributes.Protected as Attributes exposing (AttributeIn)
import Drawing2d.MouseInteraction exposing (MouseInteraction)
import Drawing2d.TouchInteraction exposing (TouchInteraction)
import Json.Decode as Decode exposing (Decoder)
import Pixels exposing (Pixels)
import Point2d exposing (Point2d)


onLeftClick : (Point2d Pixels drawingCoordinates -> msg) -> AttributeIn units coordinates drawingCoordinates msg
onLeftClick callback =
    decodeLeftClick (Decode.succeed callback)


onRightClick : (Point2d Pixels drawingCoordinates -> msg) -> AttributeIn units coordinates drawingCoordinates msg
onRightClick callback =
    decodeRightClick (Decode.succeed callback)


onLeftMouseDown : (Point2d Pixels drawingCoordinates -> MouseInteraction drawingCoordinates -> msg) -> AttributeIn units coordinates drawingCoordinates msg
onLeftMouseDown callback =
    decodeLeftMouseDown (Decode.succeed callback)


onRightMouseDown : (Point2d Pixels drawingCoordinates -> MouseInteraction drawingCoordinates -> msg) -> AttributeIn units coordinates drawingCoordinates msg
onRightMouseDown callback =
    decodeRightMouseDown (Decode.succeed callback)


onMiddleMouseDown : (Point2d Pixels drawingCoordinates -> MouseInteraction drawingCoordinates -> msg) -> AttributeIn units coordinates drawingCoordinates msg
onMiddleMouseDown callback =
    decodeMiddleMouseDown (Decode.succeed callback)


onLeftMouseUp : msg -> AttributeIn units coordinates drawingCoordinates msg
onLeftMouseUp message =
    decodeLeftMouseUp (Decode.succeed message)


onRightMouseUp : msg -> AttributeIn units coordinates drawingCoordinates msg
onRightMouseUp message =
    decodeRightMouseUp (Decode.succeed message)


onMiddleMouseUp : msg -> AttributeIn units coordinates drawingCoordinates msg
onMiddleMouseUp message =
    decodeMiddleMouseUp (Decode.succeed message)


onTouchStart : (Dict Int (Point2d Pixels drawingCoordinates) -> TouchInteraction drawingCoordinates -> msg) -> AttributeIn units coordinates drawingCoordinates msg
onTouchStart callback =
    decodeTouchStart (Decode.succeed callback)


decodeLeftClick : Decoder (Point2d Pixels drawingCoordinates -> msg) -> AttributeIn units coordinates drawingCoordinates msg
decodeLeftClick decoder =
    Attributes.OnLeftClick decoder


decodeRightClick : Decoder (Point2d Pixels drawingCoordinates -> msg) -> AttributeIn units coordinates drawingCoordinates msg
decodeRightClick decoder =
    Attributes.OnRightClick decoder


decodeLeftMouseDown : Decoder (Point2d Pixels drawingCoordinates -> MouseInteraction drawingCoordinates -> msg) -> AttributeIn units coordinates drawingCoordinates msg
decodeLeftMouseDown decoder =
    Attributes.OnLeftMouseDown decoder


decodeMiddleMouseDown : Decoder (Point2d Pixels drawingCoordinates -> MouseInteraction drawingCoordinates -> msg) -> AttributeIn units coordinates drawingCoordinates msg
decodeMiddleMouseDown decoder =
    Attributes.OnMiddleMouseDown decoder


decodeRightMouseDown : Decoder (Point2d Pixels drawingCoordinates -> MouseInteraction drawingCoordinates -> msg) -> AttributeIn units coordinates drawingCoordinates msg
decodeRightMouseDown decoder =
    Attributes.OnRightMouseDown decoder


decodeLeftMouseUp : Decoder msg -> AttributeIn units coordinates drawingCoordinates msg
decodeLeftMouseUp decoder =
    Attributes.OnLeftMouseUp decoder


decodeMiddleMouseUp : Decoder msg -> AttributeIn units coordinates drawingCoordinates msg
decodeMiddleMouseUp decoder =
    Attributes.OnMiddleMouseUp decoder


decodeRightMouseUp : Decoder msg -> AttributeIn units coordinates drawingCoordinates msg
decodeRightMouseUp decoder =
    Attributes.OnRightMouseUp decoder


decodeTouchStart : Decoder (Dict Int (Point2d Pixels drawingCoordinates) -> TouchInteraction drawingCoordinates -> msg) -> AttributeIn units coordinates drawingCoordinates msg
decodeTouchStart decoder =
    Attributes.OnTouchStart decoder
