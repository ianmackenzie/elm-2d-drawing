module Drawing2d.Context exposing (Context, init)

import Drawing2d.Border as Border exposing (BorderPosition)


type alias Context =
    { dotRadius : Float
    , fontSize : Float
    , scaleCorrection : Float
    , bordersEnabled : Bool
    , borderPosition : BorderPosition
    , strokeWidth : Float
    }


init : Context
init =
    { dotRadius = 0
    , fontSize = 0
    , scaleCorrection = 1
    , bordersEnabled = False
    , borderPosition = Border.centered
    , strokeWidth = 0
    }
