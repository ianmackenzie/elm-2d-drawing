module Drawing2d.Context exposing (Context, SvgCoordinates, init)

import BoundingBox2d exposing (BoundingBox2d)
import Drawing2d.Border as Border exposing (BorderPosition)
import Frame2d exposing (Frame2d)
import Quantity exposing (Quantity)


type SvgCoordinates
    = SvgCoordinates


type alias Context units coordinates =
    { dotRadius : Quantity Float units
    , bordersEnabled : Bool
    , borderPosition : BorderPosition
    , placementFrame : Frame2d units SvgCoordinates coordinates
    }


init : BoundingBox2d units coordinates -> Context units coordinates
init renderBounds =
    let
        { minX, maxY } =
            BoundingBox2d.extrema renderBounds

        topLeftFrame =
            Frame2d.atCoordinates ( minX, maxY ) |> Frame2d.reverseY
    in
    { dotRadius = Quantity.zero
    , bordersEnabled = False
    , borderPosition = Border.centered
    , placementFrame = Frame2d.xy |> Frame2d.relativeTo topLeftFrame
    }
