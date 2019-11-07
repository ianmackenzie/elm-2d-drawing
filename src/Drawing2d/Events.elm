module Drawing2d.Events exposing (onClick, onMouseDown)

import Drawing2d.Attributes exposing (Attribute)
import Drawing2d.Types as Types
import Json.Decode exposing (Decoder)
import Pixels exposing (Pixels)
import Point2d exposing (Point2d)


type alias DrawingCoordinates =
    Types.DrawingCoordinates


onClick : (Point2d Pixels DrawingCoordinates -> msg) -> Attribute units coordinates msg
onClick toMessage =
    Types.OnClick toMessage


onMouseDown : (Point2d Pixels DrawingCoordinates -> Decoder (Point2d Pixels DrawingCoordinates) -> msg) -> Attribute units coordinates msg
onMouseDown toMessage =
    Types.OnMouseDown toMessage
