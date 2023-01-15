module Drawing2d.Event exposing (Event)

import Rectangle2d exposing (Rectangle2d)


type alias Event units coordinates msg =
    Rectangle2d units coordinates -> msg
