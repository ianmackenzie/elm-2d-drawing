module Drawing2d.Events exposing
    ( decodeLeftClick
    , decodeLeftMouseDown
    , decodeLeftMouseUp
    , decodeMiddleMouseDown
    , decodeMiddleMouseUp
    , decodeRightClick
    , decodeRightMouseDown
    , decodeRightMouseUp
    , decodeSingleTouchStart
    , onLeftClick
    , onLeftMouseDown
    , onLeftMouseUp
    , onMiddleMouseDown
    , onMiddleMouseUp
    , onRightClick
    , onRightMouseDown
    , onRightMouseUp
    , onSingleTouchStart
    )

import Drawing2d.Attributes exposing (AttributeIn)
import Drawing2d.Types as Types exposing (MouseInteraction, SingleTouchInteraction)
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


onSingleTouchStart : (Point2d Pixels drawingCoordinates -> SingleTouchInteraction drawingCoordinates -> msg) -> AttributeIn units coordinates drawingCoordinates msg
onSingleTouchStart callback =
    decodeSingleTouchStart (Decode.succeed callback)


decodeLeftClick : Decoder (Point2d Pixels drawingCoordinates -> msg) -> AttributeIn units coordinates drawingCoordinates msg
decodeLeftClick decoder =
    Types.OnLeftClick decoder


decodeRightClick : Decoder (Point2d Pixels drawingCoordinates -> msg) -> AttributeIn units coordinates drawingCoordinates msg
decodeRightClick decoder =
    Types.OnRightClick decoder


decodeLeftMouseDown : Decoder (Point2d Pixels drawingCoordinates -> MouseInteraction drawingCoordinates -> msg) -> AttributeIn units coordinates drawingCoordinates msg
decodeLeftMouseDown decoder =
    Types.OnLeftMouseDown decoder


decodeMiddleMouseDown : Decoder (Point2d Pixels drawingCoordinates -> MouseInteraction drawingCoordinates -> msg) -> AttributeIn units coordinates drawingCoordinates msg
decodeMiddleMouseDown decoder =
    Types.OnMiddleMouseDown decoder


decodeRightMouseDown : Decoder (Point2d Pixels drawingCoordinates -> MouseInteraction drawingCoordinates -> msg) -> AttributeIn units coordinates drawingCoordinates msg
decodeRightMouseDown decoder =
    Types.OnRightMouseDown decoder


decodeLeftMouseUp : Decoder msg -> AttributeIn units coordinates drawingCoordinates msg
decodeLeftMouseUp decoder =
    Types.OnLeftMouseUp decoder


decodeMiddleMouseUp : Decoder msg -> AttributeIn units coordinates drawingCoordinates msg
decodeMiddleMouseUp decoder =
    Types.OnMiddleMouseUp decoder


decodeRightMouseUp : Decoder msg -> AttributeIn units coordinates drawingCoordinates msg
decodeRightMouseUp decoder =
    Types.OnRightMouseUp decoder


decodeSingleTouchStart : Decoder (Point2d Pixels drawingCoordinates -> SingleTouchInteraction drawingCoordinates -> msg) -> AttributeIn units coordinates drawingCoordinates msg
decodeSingleTouchStart decoder =
    Types.OnSingleTouchStart decoder
