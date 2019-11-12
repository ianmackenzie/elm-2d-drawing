module Drawing2d.Events exposing
    ( onLeftClick
    , onLeftMouseDown
    , onLeftMouseUp
    , onMiddleMouseDown
    , onMiddleMouseUp
    , onRightClick
    , onRightMouseDown
    , onRightMouseUp
    )

import Drawing2d.Attributes exposing (Attribute)
import Drawing2d.Types as Types exposing (MouseInteraction)
import Json.Decode exposing (Decoder)
import Pixels exposing (Pixels)
import Point2d exposing (Point2d)


onLeftClick : Decoder (Point2d Pixels drawingCoordinates -> msg) -> Attribute units coordinates drawingCoordinates msg
onLeftClick decoder =
    Types.OnLeftClick decoder


onRightClick : Decoder (Point2d Pixels drawingCoordinates -> msg) -> Attribute units coordinates drawingCoordinates msg
onRightClick decoder =
    Types.OnRightClick decoder


onLeftMouseDown : Decoder (Point2d Pixels drawingCoordinates -> MouseInteraction drawingCoordinates -> msg) -> Attribute units coordinates drawingCoordinates msg
onLeftMouseDown decoder =
    Types.OnLeftMouseDown decoder


onMiddleMouseDown : Decoder (Point2d Pixels drawingCoordinates -> MouseInteraction drawingCoordinates -> msg) -> Attribute units coordinates drawingCoordinates msg
onMiddleMouseDown decoder =
    Types.OnMiddleMouseDown decoder


onRightMouseDown : Decoder (Point2d Pixels drawingCoordinates -> MouseInteraction drawingCoordinates -> msg) -> Attribute units coordinates drawingCoordinates msg
onRightMouseDown decoder =
    Types.OnRightMouseDown decoder


onLeftMouseUp : Decoder msg -> Attribute units coordinates drawingCoordinates msg
onLeftMouseUp decoder =
    Types.OnLeftMouseUp decoder


onMiddleMouseUp : Decoder msg -> Attribute units coordinates drawingCoordinates msg
onMiddleMouseUp decoder =
    Types.OnMiddleMouseUp decoder


onRightMouseUp : Decoder msg -> Attribute units coordinates drawingCoordinates msg
onRightMouseUp decoder =
    Types.OnRightMouseUp decoder
