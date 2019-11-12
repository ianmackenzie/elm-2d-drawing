module Drawing2d.Types exposing
    ( Attribute(..)
    , ClickDecoder
    , Fill(..)
    , Gradient(..)
    , MouseDownDecoder
    , MouseEvent
    , MouseInteraction(..)
    , Stop
    , Stops(..)
    , Stroke(..)
    )

import BoundingBox2d exposing (BoundingBox2d)
import Circle2d exposing (Circle2d)
import Color exposing (Color)
import DOM
import Json.Decode exposing (Decoder)
import Pixels exposing (Pixels)
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


type alias ClickDecoder drawingCoordinates msg =
    Decoder (Point2d Pixels drawingCoordinates -> msg)


type alias MouseDownDecoder drawingCoordinates msg =
    Decoder (Point2d Pixels drawingCoordinates -> MouseInteraction drawingCoordinates -> msg)


type Attribute units coordinates drawingCoordinates msg
    = FillStyle (Fill units coordinates) -- Svg.Attributes.fill
    | StrokeStyle (Stroke units coordinates) -- Svg.Attributes.stroke
    | FontSize Float
    | StrokeWidth Float
    | BorderVisibility Bool
    | TextColor String -- Svg.Attributes.color
    | FontFamily String -- Svg.Attributes.fontFamily
    | TextAnchor { x : String, y : String } -- Svg.Attributes.textAnchor, Svg.Attributes.dominantBaseline
    | OnLeftClick (ClickDecoder drawingCoordinates msg)
    | OnRightClick (ClickDecoder drawingCoordinates msg)
    | OnLeftMouseDown (MouseDownDecoder drawingCoordinates msg)
    | OnMiddleMouseDown (MouseDownDecoder drawingCoordinates msg)
    | OnRightMouseDown (MouseDownDecoder drawingCoordinates msg)
    | OnLeftMouseUp (Decoder msg)
    | OnMiddleMouseUp (Decoder msg)
    | OnRightMouseUp (Decoder msg)


type alias MouseEvent =
    { container : DOM.Rectangle
    , clientX : Float
    , clientY : Float
    , pageX : Float
    , pageY : Float
    , button : Int
    }


type MouseInteraction drawingCoordinates
    = MouseInteraction
        { initialEvent : MouseEvent
        , viewBox : BoundingBox2d Pixels drawingCoordinates
        , drawingScale : Float
        , initialPoint : Point2d Pixels drawingCoordinates
        }
