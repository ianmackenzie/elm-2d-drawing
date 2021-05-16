module Drawing2d.RenderContext.Protected exposing
    ( RenderContext(..)
    , at
    , at_
    , bordersVisible
    , fillGradient
    , init
    , placeIn
    , relativeTo
    , scaleAbout
    , strokeDashPattern
    , strokeGradient
    , update
    )

import Drawing2d.Attributes as Attributes exposing (Attribute(..), AttributeValues)
import Drawing2d.Gradient as Gradient exposing (Gradient)
import Frame2d exposing (Frame2d)
import Point2d exposing (Point2d)
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


init : Quantity Float units -> RenderContext units coordinates
init pixelSize =
    RenderContext
        { bordersVisible = False
        , pixelSize = pixelSize
        , strokeWidth = Quantity.zero
        , fontSize = Quantity.zero
        , fillGradient = Nothing
        , strokeGradient = Nothing
        , strokeDashPattern = []
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


scaleAbout :
    Point2d units coordinates
    -> Float
    -> RenderContext units coordinates
    -> RenderContext units coordinates
scaleAbout point scale (RenderContext context) =
    RenderContext
        { pixelSize = context.pixelSize |> Quantity.multiplyBy scale
        , bordersVisible = context.bordersVisible
        , strokeWidth = context.strokeWidth |> Quantity.multiplyBy scale
        , fontSize = context.fontSize |> Quantity.multiplyBy scale
        , fillGradient = Maybe.map (Gradient.scaleAbout point scale) context.fillGradient
        , strokeGradient = Maybe.map (Gradient.scaleAbout point scale) context.strokeGradient
        , strokeDashPattern = List.map (Quantity.multiplyBy scale) context.strokeDashPattern
        }


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


bordersVisible : RenderContext units coordinates -> Bool
bordersVisible (RenderContext context) =
    context.bordersVisible


fillGradient : RenderContext units coordinates -> Maybe (Gradient units coordinates)
fillGradient (RenderContext context) =
    context.fillGradient


strokeGradient : RenderContext units coordinates -> Maybe (Gradient units coordinates)
strokeGradient (RenderContext context) =
    context.strokeGradient


strokeDashPattern : RenderContext units coordinates -> List (Quantity Float units)
strokeDashPattern (RenderContext context) =
    context.strokeDashPattern


update : AttributeValues units coordinates msg -> RenderContext units coordinates -> RenderContext units coordinates
update attributeValues (RenderContext context) =
    let
        updatedBordersVisible =
            attributeValues.borderVisibility
                |> Maybe.withDefault context.bordersVisible

        updatedStrokeWidth =
            attributeValues.strokeWidth
                |> Maybe.withDefault context.strokeWidth

        updatedFontSize =
            attributeValues.fontSize
                |> Maybe.withDefault context.fontSize

        updatedFillGradient =
            case attributeValues.fillStyle of
                Nothing ->
                    context.fillGradient

                Just Attributes.NoFill ->
                    Nothing

                Just Attributes.TransparentFill ->
                    Nothing

                Just (Attributes.FillColor _) ->
                    Nothing

                Just (Attributes.FillGradient gradient) ->
                    Just gradient

        updatedStrokeGradient =
            case attributeValues.strokeStyle of
                Nothing ->
                    context.strokeGradient

                Just (Attributes.StrokeColor _) ->
                    Nothing

                Just (Attributes.StrokeGradient gradient) ->
                    Just gradient

        updatedDashPattern =
            case attributeValues.strokeDashPattern of
                Nothing ->
                    context.strokeDashPattern

                Just dashPattern ->
                    dashPattern
    in
    RenderContext
        { pixelSize = context.pixelSize
        , bordersVisible = updatedBordersVisible
        , strokeWidth = updatedStrokeWidth
        , fontSize = updatedFontSize
        , fillGradient = updatedFillGradient
        , strokeGradient = updatedStrokeGradient
        , strokeDashPattern = updatedDashPattern
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
