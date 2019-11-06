module Drawing2d.Events exposing (onClick, onMouseDown)

import Drawing2d.Attributes exposing (Attribute)
import Drawing2d.Types as Types
import Point2d exposing (Point2d)


onClick : msg -> Attribute units coordinates msg
onClick message =
    Types.OnClick message


onMouseDown : msg -> Attribute units coordinates msg
onMouseDown message =
    Types.OnMouseDown message
