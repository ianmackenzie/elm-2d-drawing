module Drawing2d.Context exposing (Context, init)

import BoundingBox2d exposing (BoundingBox2d)
import Drawing2d.Border as Border exposing (BorderPosition)
import Frame2d exposing (Frame2d)


type alias Context =
    { dotRadius : Float
    , bordersEnabled : Bool
    , borderPosition : BorderPosition
    , placementFrame : Frame2d
    }


init : BoundingBox2d -> Context
init renderBounds =
    let
        { minX, maxY } =
            BoundingBox2d.extrema renderBounds

        topLeftFrame =
            Frame2d.atCoordinates ( minX, maxY ) |> Frame2d.reverseY
    in
    { dotRadius = 0
    , bordersEnabled = False
    , borderPosition = Border.centered
    , placementFrame = Frame2d.xy |> Frame2d.relativeTo topLeftFrame
    }
