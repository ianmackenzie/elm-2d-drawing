module Drawing2d.Gradient.Private exposing (Gradient(..))

import Circle2d exposing (Circle2d)
import Drawing2d.Gradient.Stops exposing (Stops)
import Point2d exposing (Point2d)


type Gradient units coordinates
    = LinearGradient
        { id : String
        , start : Point2d units coordinates
        , end : Point2d units coordinates
        , stops : Stops
        }
    | RadialGradient
        { id : String
        , start : Point2d units coordinates
        , end : Circle2d units coordinates
        , stops : Stops
        }
