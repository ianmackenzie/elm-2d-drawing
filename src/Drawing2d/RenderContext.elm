module Drawing2d.RenderContext exposing
    ( RenderContext
    , ems
    , pixels
    , resolution
    )

import Drawing2d.RenderContext.Protected as RenderContext exposing (RenderContext)
import Pixels exposing (Pixels)
import Quantity exposing (Quantity, Rate)


type alias RenderContext units coordinates =
    RenderContext.RenderContext units coordinates


pixels : Float -> RenderContext units coordinates -> Quantity Float units
pixels numPixels renderContext =
    let
        (RenderContext.RenderContext context) =
            renderContext
    in
    Quantity.multiplyBy numPixels context.pixelSize


resolution : RenderContext units coordinates -> Quantity Float (Rate units Pixels)
resolution renderContext =
    let
        (RenderContext.RenderContext context) =
            renderContext
    in
    context.pixelSize |> Quantity.per Pixels.pixel


ems : Float -> RenderContext units coordinates -> Quantity Float units
ems numEms renderContext =
    let
        (RenderContext.RenderContext context) =
            renderContext
    in
    Quantity.multiplyBy numEms context.fontSize
