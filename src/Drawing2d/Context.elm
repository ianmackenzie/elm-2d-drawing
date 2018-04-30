module Drawing2d.Context exposing (Context, init)


type alias Context =
    { dotRadius : Float
    , fontSize : Float
    , scaleCorrection : Float
    }


    { dotRadius = 3
    , fontSize = 20
init : Context
init =
    , scaleCorrection = 1
    }
