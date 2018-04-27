module Drawing2d.Internal exposing (..)

import Arc2d exposing (Arc2d)
import Circle2d exposing (Circle2d)
import Color exposing (Color)
import CubicSpline2d exposing (CubicSpline2d)
import Direction2d as Direction2d exposing (Direction2d)
import Ellipse2d exposing (Ellipse2d)
import EllipticalArc2d exposing (EllipticalArc2d)
import Frame2d as Frame2d exposing (Frame2d)
import LineSegment2d exposing (LineSegment2d)
import Mouse
import Point2d as Point2d exposing (Point2d)
import Polygon2d exposing (Polygon2d)
import Polyline2d exposing (Polyline2d)
import QuadraticSpline2d exposing (QuadraticSpline2d)
import Triangle2d exposing (Triangle2d)


type FillStyle
    = FillColor Color
    | NoFill


type StrokeStyle
    = StrokeColor Color
    | NoStroke


type ArrowTipStyle
    = TriangularTip { length : Float, width : Float }


type Anchor
    = TopLeft
    | TopCenter
    | TopRight
    | CenterLeft
    | Center
    | CenterRight
    | BottomLeft
    | BottomCenter
    | BottomRight


type Attribute msg
    = FillStyle FillStyle
    | StrokeStyle StrokeStyle
    | StrokeWidth Float
    | ArrowTipStyle ArrowTipStyle
    | DotRadius Float
    | TextAnchor Anchor
    | TextColor Color
    | FontSize Int
    | FontFamily (List String)
    | OnClick msg
    | OnMouseDown (Mouse.Position -> msg)


type Element msg
    = Empty
    | Group (List (Attribute msg)) (List (Element msg))
    | PlaceIn Frame2d (Element msg)
    | ScaleAbout Point2d Float (Element msg)
    | Arrow (List (Attribute msg)) Point2d Float Direction2d
    | LineSegment (List (Attribute msg)) LineSegment2d
    | Triangle (List (Attribute msg)) Triangle2d
    | Dot (List (Attribute msg)) Point2d
    | Arc (List (Attribute msg)) Arc2d
    | CubicSpline (List (Attribute msg)) CubicSpline2d
    | QuadraticSpline (List (Attribute msg)) QuadraticSpline2d
    | Polyline (List (Attribute msg)) Polyline2d
    | Polygon (List (Attribute msg)) Polygon2d
    | Circle (List (Attribute msg)) Circle2d
    | Ellipse (List (Attribute msg)) Ellipse2d
    | EllipticalArc (List (Attribute msg)) EllipticalArc2d
    | Text (List (Attribute msg)) Point2d String
    | TextShape (List (Attribute msg)) Point2d String


type alias Context =
    { dotRadius : Float
    , arrowTipStyle : ArrowTipStyle
    }


defaultContext : Context
defaultContext =
    { dotRadius = 3
    , arrowTipStyle = TriangularTip { length = 10, width = 8 }
    }
