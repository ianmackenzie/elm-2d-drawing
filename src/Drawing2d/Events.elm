module Drawing2d.Events exposing
    ( onLeftClick
    , onLeftMouseDown
    , onLeftMouseUp
    , onMiddleMouseDown
    , onMiddleMouseUp
    , onRightMouseDown
    , onRightMouseUp
    )

import Drawing2d.Attributes exposing (Attribute)
import Drawing2d.Types as Types exposing (ClickHandler, DownHandler, UpHandler)
import Json.Decode exposing (Decoder)
import Pixels exposing (Pixels)
import Point2d exposing (Point2d)


type alias DrawingCoordinates =
    Types.DrawingCoordinates


onLeftClick : ClickHandler msg -> Attribute units coordinates msg
onLeftClick toMessage =
    Types.OnLeftClick toMessage


onLeftMouseDown : DownHandler msg -> Attribute units coordinates msg
onLeftMouseDown toMessage =
    Types.OnLeftMouseDown toMessage


onMiddleMouseDown : DownHandler msg -> Attribute units coordinates msg
onMiddleMouseDown toMessage =
    Types.OnMiddleMouseDown toMessage


onRightMouseDown : DownHandler msg -> Attribute units coordinates msg
onRightMouseDown toMessage =
    Types.OnRightMouseDown toMessage


onLeftMouseUp : UpHandler msg -> Attribute units coordinates msg
onLeftMouseUp toMessage =
    Types.OnLeftMouseUp toMessage


onMiddleMouseUp : UpHandler msg -> Attribute units coordinates msg
onMiddleMouseUp toMessage =
    Types.OnMiddleMouseUp toMessage


onRightMouseUp : UpHandler msg -> Attribute units coordinates msg
onRightMouseUp toMessage =
    Types.OnRightMouseUp toMessage
