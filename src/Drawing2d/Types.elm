module Drawing2d.Types exposing
    ( Attribute(..)
    , Fill(..)
    , Gradient(..)
    , Stop
    , Stops(..)
    , Stroke(..)
    )

import Circle2d exposing (Circle2d)
import Color exposing (Color)
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


type Stops
    = StopValues String (List Stop)
    | StopsReference String


type alias Stop =
    { offset : String
    , color : String
    }


type Fill units coordinates
    = NoFill
    | FillColor String
    | FillGradient (Gradient units coordinates)


type Stroke units coordinates
    = StrokeColor String
    | StrokeGradient (Gradient units coordinates)


type Attribute units coordinates msg
    = FillStyle (Fill units coordinates) -- Svg.Attributes.fill
    | StrokeStyle (Stroke units coordinates) -- Svg.Attributes.stroke
    | FontSize Float
    | StrokeWidth Float
    | BorderVisibility Bool
    | TextColor String -- Svg.Attributes.color
    | FontFamily String -- Svg.Attributes.fontFamily
    | TextAnchor { x : String, y : String } -- Svg.Attributes.textAnchor, Svg.Attributes.dominantBaseline
    | OnClick msg
    | OnMouseDown msg
