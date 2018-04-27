module Drawing2d.Context exposing (Context, default)


type alias Context =
    { dotRadius : Float
    }


default : Context
default =
    { dotRadius = 3
    }
