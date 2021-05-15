module Drawing2d.RenderContext.Protected exposing
    ( RenderContext(..)
    , at
    , at_
    , placeIn
    , relativeTo
    )

import Drawing2d.Gradient as Gradient exposing (Gradient)
import Frame2d exposing (Frame2d)
import Quantity exposing (Quantity, Rate)


type RenderContext units coordinates
    = RenderContext
        { pixelSize : Quantity Float units
        , bordersVisible : Bool
        , strokeWidth : Quantity Float units
        , fontSize : Quantity Float units
        , fillGradient : Maybe (Gradient units coordinates)
        , strokeGradient : Maybe (Gradient units coordinates)
        , strokeDashPattern : List (Quantity Float units)
        }


at :
    Quantity Float (Rate units2 units1)
    -> RenderContext units1 coordinates
    -> RenderContext units2 coordinates
at rate (RenderContext context) =
    RenderContext
        { pixelSize = context.pixelSize |> Quantity.at rate
        , bordersVisible = context.bordersVisible
        , strokeWidth = context.strokeWidth |> Quantity.at rate
        , fontSize = context.fontSize |> Quantity.at rate
        , fillGradient = Maybe.map (Gradient.at rate) context.fillGradient
        , strokeGradient = Maybe.map (Gradient.at rate) context.strokeGradient
        , strokeDashPattern = List.map (Quantity.at rate) context.strokeDashPattern
        }


at_ :
    Quantity Float (Rate units2 units1)
    -> RenderContext units2 coordinates
    -> RenderContext units1 coordinates
at_ rate renderContext =
    at (Quantity.inverse rate) renderContext


placeIn :
    Frame2d units coordinates2 { defines : coordinates1 }
    -> RenderContext units coordinates1
    -> RenderContext units coordinates2
placeIn frame (RenderContext context) =
    RenderContext
        { pixelSize = context.pixelSize
        , bordersVisible = context.bordersVisible
        , strokeWidth = context.strokeWidth
        , fontSize = context.fontSize
        , fillGradient = Maybe.map (Gradient.placeIn frame) context.fillGradient
        , strokeGradient = Maybe.map (Gradient.placeIn frame) context.strokeGradient
        , strokeDashPattern = context.strokeDashPattern
        }


relativeTo :
    Frame2d units coordinates1 { defines : coordinates2 }
    -> RenderContext units coordinates1
    -> RenderContext units coordinates2
relativeTo frame (RenderContext context) =
    RenderContext
        { pixelSize = context.pixelSize
        , bordersVisible = context.bordersVisible
        , strokeWidth = context.strokeWidth
        , fontSize = context.fontSize
        , fillGradient = Maybe.map (Gradient.relativeTo frame) context.fillGradient
        , strokeGradient = Maybe.map (Gradient.relativeTo frame) context.strokeGradient
        , strokeDashPattern = context.strokeDashPattern
        }



-- scaleAbout :
--     Point2d units coordinates
--     -> Float
--     -> RenderContext units coordinates
--     -> RenderContext units coordinates
-- scaleAbout point scale (RenderContext context) =
--     RenderContext
--         { pixelSize = context.pixelSize
--         , bordersVisible = context.bordersVisible
--         , strokeWidth = context.strokeWidth
--         , fontSize = context.fontSize
--         , fillGradient = Maybe.map (Gradient.scaleAbout point scale) context.fillGradient
--         , strokeGradient = Maybe.map (Gradient.scaleAbout point scale) context.strokeGradient
--         , strokeDashPattern = List.map (Quantity.at rate) context.strokeDashPattern
--         }
