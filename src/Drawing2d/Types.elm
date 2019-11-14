module Drawing2d.Types exposing
    ( AttributeIn(..)
    , ClickDecoder
    , Fill(..)
    , Gradient(..)
    , MouseDownDecoder
    , MouseEvent
    , MouseInteraction(..)
    , SingleTouchInteraction(..)
    , SingleTouchMoveDecoder
    , SingleTouchStartDecoder
    , Stop
    , Stops(..)
    , Stroke(..)
    , TouchEndDecoder
    , TouchStartEvent
    )

import BoundingBox2d exposing (BoundingBox2d)
import Circle2d exposing (Circle2d)
import Color exposing (Color)
import DOM
import Duration exposing (Duration)
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


type alias SingleTouchStartDecoder drawingCoordinates msg =
    Decoder (Point2d Pixels drawingCoordinates -> SingleTouchInteraction drawingCoordinates -> msg)


type alias SingleTouchMoveDecoder drawingCoordinates msg =
    Decoder (Point2d Pixels drawingCoordinates -> msg)


type alias TouchEndDecoder msg =
    Decoder (Duration -> msg)


type AttributeIn units coordinates drawingCoordinates msg
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
    | OnSingleTouchStart (SingleTouchStartDecoder drawingCoordinates msg)
    | OnSingleTouchMove (SingleTouchMoveDecoder drawingCoordinates msg) (SingleTouchInteraction drawingCoordinates)
    | OnSingleTouchEnd (TouchEndDecoder msg) (SingleTouchInteraction drawingCoordinates)


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


type alias TouchStartEvent =
    { container : DOM.Rectangle
    , touches : List Touch
    , targetTouches : List Touch
    , changedTouches : List Touch
    }


type alias Touch =
    { identifier : Int
    , clientX : Float
    , clientY : Float
    , pageX : Float
    , pageY : Float
    }


type SingleTouchInteraction drawingCoordinates
    = TouchInteraction
        { initialEvent : TouchStartEvent
        , viewBox : BoundingBox2d Pixels drawingCoordinates
        , drawingScale : Float
        , initialPoint : Point2d Pixels drawingCoordinates
        }
