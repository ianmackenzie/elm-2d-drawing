module Drawing2d.RenderContext exposing
    ( RenderContext
    , ems
    , fontSize
    , pixelSize
    , pixels
    , resolution
    , strokeWidth
    )

import Drawing2d.RenderContext.Protected as RenderContext exposing (RenderContext)
import Pixels exposing (Pixels)
import Quantity exposing (Quantity, Rate)


type alias RenderContext units coordinates =
    RenderContext.RenderContext units coordinates


pixels : Float -> RenderContext units coordinates -> Quantity Float units
pixels numPixels renderContext =
    Quantity.multiplyBy numPixels (pixelSize renderContext)


pixelSize : RenderContext units coordinates -> Quantity Float units
pixelSize renderContext =
    let
        (RenderContext.RenderContext context) =
            renderContext
    in
    context.pixelSize


resolution : RenderContext units coordinates -> Quantity Float (Rate units Pixels)
resolution renderContext =
    pixelSize renderContext |> Quantity.per Pixels.pixel


ems : Float -> RenderContext units coordinates -> Quantity Float units
ems numEms renderContext =
    Quantity.multiplyBy numEms (fontSize renderContext)


fontSize : RenderContext units coordinates -> Quantity Float units
fontSize renderContext =
    let
        (RenderContext.RenderContext context) =
            renderContext
    in
    context.fontSize


strokeWidth : RenderContext units coordinates -> Quantity Float units
strokeWidth renderContext =
    let
        (RenderContext.RenderContext context) =
            renderContext
    in
    context.strokeWidth
