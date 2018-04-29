module Drawing2d.Context exposing (Context, default)


type alias Context =
    { dotRadius : Float
    , fontSize : Float
    , scaleCorrection : Float
    }


default : Context
default =
    { dotRadius = 3
    , fontSize = 20
    , scaleCorrection = 1
    }
