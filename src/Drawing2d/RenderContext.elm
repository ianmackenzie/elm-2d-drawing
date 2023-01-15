module Drawing2d.RenderContext exposing
    ( RenderContext
    , at
    , at_
    , bordersVisible
    , ems
    , fontSize
    , init
    , pixelSize
    , pixels
    , placeIn
    , relativeTo
    , render
    , resolution
    , scaleAbout
    , strokeDashPattern
    , strokeWidth
    , update
    , viewBox
    )

import Color
import Drawing2d.Attributes as Attributes exposing (AttributeValues)
import Drawing2d.FillStyle as FillStyle exposing (FillStyle)
import Drawing2d.Gradient as Gradient exposing (Gradient)
import Drawing2d.HatchPattern as HatchPattern
import Drawing2d.Render as Render
import Drawing2d.RenderedSvg as RenderedSvg exposing (RenderedSvg)
import Drawing2d.StrokeDashPattern as StrokeDashPattern exposing (StrokeDashPattern)
import Drawing2d.StrokeStyle as StrokeStyle exposing (StrokeStyle)
import Frame2d exposing (Frame2d)
import Pixels exposing (Pixels)
import Point2d exposing (Point2d)
import Quantity exposing (Quantity, Rate)
import Rectangle2d exposing (Rectangle2d)
import Svg exposing (Svg)
import Svg.Attributes


type alias RenderContext units coordinates =
    { pixelSize : Quantity Float units
    , viewBox : Rectangle2d units coordinates
    , bordersVisible : Bool
    , strokeWidth : Quantity Float units
    , fontSize : Quantity Float units
    , strokeGradient : Maybe (Gradient units coordinates)
    , fillGradient : Maybe (Gradient units coordinates)
    , hatchPattern : Maybe (HatchPattern.Linked units coordinates)
    , strokeDashPattern : StrokeDashPattern units
    }


init : Quantity Float units -> Rectangle2d units coordinates -> RenderContext units coordinates
init givenPixelSize givenViewBox =
    { bordersVisible = False
    , pixelSize = givenPixelSize
    , viewBox = givenViewBox
    , strokeWidth = Quantity.zero
    , fontSize = Quantity.zero
    , strokeDashPattern = StrokeDashPattern.none
    , strokeGradient = Nothing
    , fillGradient = Nothing
    , hatchPattern = Nothing
    }


pixels : Float -> RenderContext units coordinates -> Quantity Float units
pixels numPixels renderContext =
    Quantity.multiplyBy numPixels (pixelSize renderContext)


pixelSize : RenderContext units coordinates -> Quantity Float units
pixelSize renderContext =
    renderContext.pixelSize


resolution : RenderContext units coordinates -> Quantity Float (Rate units Pixels)
resolution renderContext =
    pixelSize renderContext |> Quantity.per Pixels.pixel


ems : Float -> RenderContext units coordinates -> Quantity Float units
ems numEms renderContext =
    Quantity.multiplyBy numEms (fontSize renderContext)


fontSize : RenderContext units coordinates -> Quantity Float units
fontSize renderContext =
    renderContext.fontSize


strokeWidth : RenderContext units coordinates -> Quantity Float units
strokeWidth renderContext =
    renderContext.strokeWidth


at :
    Quantity Float (Rate units2 units1)
    -> RenderContext units1 coordinates
    -> RenderContext units2 coordinates
at rate renderContext =
    { pixelSize = renderContext.pixelSize |> Quantity.at rate
    , viewBox = renderContext.viewBox |> Rectangle2d.at rate
    , bordersVisible = renderContext.bordersVisible
    , strokeWidth = renderContext.strokeWidth |> Quantity.at rate
    , fontSize = renderContext.fontSize |> Quantity.at rate
    , strokeDashPattern = StrokeDashPattern.at rate renderContext.strokeDashPattern
    , strokeGradient = Maybe.map (Gradient.at rate) renderContext.strokeGradient
    , fillGradient = Maybe.map (Gradient.at rate) renderContext.fillGradient
    , hatchPattern = Maybe.map (HatchPattern.at rate) renderContext.hatchPattern
    }


at_ :
    Quantity Float (Rate units2 units1)
    -> RenderContext units2 coordinates
    -> RenderContext units1 coordinates
at_ rate renderContext =
    at (Quantity.inverse rate) renderContext


scaleAbout :
    Point2d units coordinates
    -> Float
    -> RenderContext units coordinates
    -> RenderContext units coordinates
scaleAbout point scale renderContext =
    { pixelSize = renderContext.pixelSize |> Quantity.multiplyBy scale
    , viewBox = renderContext.viewBox |> Rectangle2d.scaleAbout point scale
    , bordersVisible = renderContext.bordersVisible
    , strokeWidth = renderContext.strokeWidth |> Quantity.multiplyBy scale
    , fontSize = renderContext.fontSize |> Quantity.multiplyBy scale
    , strokeDashPattern = StrokeDashPattern.scaleBy scale renderContext.strokeDashPattern
    , strokeGradient = Maybe.map (Gradient.scaleAbout point scale) renderContext.strokeGradient
    , fillGradient = Maybe.map (Gradient.scaleAbout point scale) renderContext.fillGradient
    , hatchPattern = Maybe.map (HatchPattern.scaleAbout point scale) renderContext.hatchPattern
    }


placeIn :
    Frame2d units coordinates2 { defines : coordinates1 }
    -> RenderContext units coordinates1
    -> RenderContext units coordinates2
placeIn frame renderContext =
    { pixelSize = renderContext.pixelSize
    , viewBox = renderContext.viewBox |> Rectangle2d.placeIn frame
    , bordersVisible = renderContext.bordersVisible
    , strokeWidth = renderContext.strokeWidth
    , fontSize = renderContext.fontSize
    , strokeDashPattern = renderContext.strokeDashPattern
    , strokeGradient = Maybe.map (Gradient.placeIn frame) renderContext.strokeGradient
    , fillGradient = Maybe.map (Gradient.placeIn frame) renderContext.fillGradient
    , hatchPattern = Maybe.map (HatchPattern.placeIn frame) renderContext.hatchPattern
    }


relativeTo :
    Frame2d units coordinates1 { defines : coordinates2 }
    -> RenderContext units coordinates1
    -> RenderContext units coordinates2
relativeTo frame renderContext =
    { pixelSize = renderContext.pixelSize
    , viewBox = renderContext.viewBox |> Rectangle2d.relativeTo frame
    , bordersVisible = renderContext.bordersVisible
    , strokeWidth = renderContext.strokeWidth
    , fontSize = renderContext.fontSize
    , strokeDashPattern = renderContext.strokeDashPattern
    , strokeGradient = Maybe.map (Gradient.relativeTo frame) renderContext.strokeGradient
    , fillGradient = Maybe.map (Gradient.relativeTo frame) renderContext.fillGradient
    , hatchPattern = Maybe.map (HatchPattern.relativeTo frame) renderContext.hatchPattern
    }


viewBox : RenderContext units coordinates -> Rectangle2d units coordinates
viewBox renderContext =
    renderContext.viewBox


bordersVisible : RenderContext units coordinates -> Bool
bordersVisible renderContext =
    renderContext.bordersVisible


strokeDashPattern : RenderContext units coordinates -> StrokeDashPattern units
strokeDashPattern renderContext =
    renderContext.strokeDashPattern


update : AttributeValues units coordinates msg -> RenderContext units coordinates -> RenderContext units coordinates
update attributeValues renderContext =
    let
        updatedBordersVisible =
            attributeValues.borderVisibility
                |> Maybe.withDefault renderContext.bordersVisible

        updatedStrokeWidth =
            attributeValues.strokeWidth
                |> Maybe.withDefault renderContext.strokeWidth

        updatedFontSize =
            attributeValues.fontSize
                |> Maybe.withDefault renderContext.fontSize

        updatedDashPattern =
            attributeValues.strokeDashPattern
                |> Maybe.withDefault renderContext.strokeDashPattern

        updatedStrokeGradient =
            StrokeStyle.updateStrokeGradient attributeValues.strokeStyle renderContext.strokeGradient

        updatedFillGradient =
            FillStyle.updateFillGradient attributeValues.fillStyle renderContext.fillGradient

        updatedHatchPatthern =
            FillStyle.updateHatchPattern attributeValues.fillStyle renderContext.hatchPattern
    in
    { pixelSize = renderContext.pixelSize
    , viewBox = renderContext.viewBox
    , bordersVisible = updatedBordersVisible
    , strokeWidth = updatedStrokeWidth
    , fontSize = updatedFontSize
    , strokeDashPattern = updatedDashPattern
    , strokeGradient = updatedStrokeGradient
    , fillGradient = updatedFillGradient
    , hatchPattern = updatedHatchPatthern
    }


render : RenderContext units coordinates -> RenderedSvg units coordinates msg
render renderContext =
    RenderedSvg.merge
        [ Render.strokeWidth renderContext.strokeWidth
        , Render.fontSize renderContext.fontSize
        , StrokeDashPattern.render renderContext.strokeDashPattern
        ]
        |> RenderedSvg.add (Gradient.render Svg.Attributes.stroke) renderContext.strokeGradient
        |> RenderedSvg.add (Gradient.render Svg.Attributes.fill) renderContext.fillGradient
        |> RenderedSvg.add HatchPattern.renderLinked renderContext.hatchPattern
