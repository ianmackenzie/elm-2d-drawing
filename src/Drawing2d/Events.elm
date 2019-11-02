module Drawing2d.Events exposing (onClick, onMouseDown)

import Drawing2d.Attributes exposing (Attribute)
import Drawing2d.Types as Types exposing (EventProperties)
import Point2d exposing (Point2d)


onClick : (Point2d units coordinates -> msg) -> Attribute units coordinates msg
onClick toMessage =
    Types.OnClick toMessage


onMouseDown : (Point2d units coordinates -> msg) -> Attribute units coordinates msg
onMouseDown toMessage =
    Types.OnMouseDown toMessage


onMouseUp : (Point2d units coordinates -> msg) -> Attribute units coordinates msg
onMouseUp toMessage =
    Types.OnMouseUp toMessage
