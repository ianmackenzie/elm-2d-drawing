module Drawing2d.Cursor exposing
    ( Cursor
    , auto, default, none
    , contextMenu, help, pointer, progress, wait
    , cell, crosshair, text, verticalText
    , alias_, copy, move, noDrop, notAllowed, grab, grabbing
    , allScroll, colResize, rowResize
    , nResize, eResize, sResize, wResize, neResize, nwResize, seResize, swResize, ewResize, nsResize, neswResize, nwseResize
    , zoomIn, zoomOut
    , image, ImageCoordinates
    )

{-|

@docs Cursor

@docs auto, default, none

@docs contextMenu, help, pointer, progress, wait

@docs cell, crosshair, text, verticalText

@docs alias_, copy, move, noDrop, notAllowed, grab, grabbing

@docs allScroll, colResize, rowResize

@docs nResize, eResize, sResize, wResize, neResize, nwResize, seResize, swResize, ewResize, nsResize, neswResize, nwseResize

@docs zoomIn, zoomOut


# Image-based cursors

@docs image, ImageCoordinates

-}

import Drawing2d.Attributes as Attributes
import Pixels exposing (Pixels)
import Point2d exposing (Point2d)


type alias Cursor =
    Attributes.Cursor


{-| -}
auto : Cursor
auto =
    Attributes.AutoCursor


{-| -}
default : Cursor
default =
    Attributes.DefaultCursor


{-| -}
none : Cursor
none =
    Attributes.NoCursor


{-| -}
contextMenu : Cursor
contextMenu =
    Attributes.ContextMenuCursor


{-| -}
help : Cursor
help =
    Attributes.HelpCursor


{-| -}
pointer : Cursor
pointer =
    Attributes.PointerCursor


{-| -}
progress : Cursor
progress =
    Attributes.ProgressCursor


{-| -}
wait : Cursor
wait =
    Attributes.WaitCursor


{-| -}
cell : Cursor
cell =
    Attributes.CellCursor


{-| -}
crosshair : Cursor
crosshair =
    Attributes.CrosshairCursor


{-| -}
text : Cursor
text =
    Attributes.TextCursor


{-| -}
verticalText : Cursor
verticalText =
    Attributes.VerticalTextCursor


{-| -}
alias_ : Cursor
alias_ =
    Attributes.AliasCursor


{-| -}
copy : Cursor
copy =
    Attributes.CopyCursor


{-| -}
move : Cursor
move =
    Attributes.MoveCursor


{-| -}
noDrop : Cursor
noDrop =
    Attributes.NoDropCursor


{-| -}
notAllowed : Cursor
notAllowed =
    Attributes.NotAllowedCursor


{-| -}
grab : Cursor
grab =
    Attributes.GrabCursor


{-| -}
grabbing : Cursor
grabbing =
    Attributes.GrabbingCursor


{-| -}
allScroll : Cursor
allScroll =
    Attributes.AllScrollCursor


{-| -}
colResize : Cursor
colResize =
    Attributes.ColResizeCursor


{-| -}
rowResize : Cursor
rowResize =
    Attributes.RowResizeCursor


{-| -}
nResize : Cursor
nResize =
    Attributes.NResizeCursor


{-| -}
eResize : Cursor
eResize =
    Attributes.EResizeCursor


{-| -}
sResize : Cursor
sResize =
    Attributes.SResizeCursor


{-| -}
wResize : Cursor
wResize =
    Attributes.WResizeCursor


{-| -}
neResize : Cursor
neResize =
    Attributes.NeResizeCursor


{-| -}
nwResize : Cursor
nwResize =
    Attributes.NwResizeCursor


{-| -}
seResize : Cursor
seResize =
    Attributes.SeResizeCursor


{-| -}
swResize : Cursor
swResize =
    Attributes.SwResizeCursor


{-| -}
ewResize : Cursor
ewResize =
    Attributes.EwResizeCursor


{-| -}
nsResize : Cursor
nsResize =
    Attributes.NsResizeCursor


{-| -}
neswResize : Cursor
neswResize =
    Attributes.NeswResizeCursor


{-| -}
nwseResize : Cursor
nwseResize =
    Attributes.NwseResizeCursor


{-| -}
zoomIn : Cursor
zoomIn =
    Attributes.ZoomInCursor


{-| -}
zoomOut : Cursor
zoomOut =
    Attributes.ZoomOutCursor


image : { url : String, hotspot : Point2d Pixels ImageCoordinates, fallback : Cursor } -> Cursor
image { url, hotspot, fallback } =
    let
        { x, y } =
            Point2d.toPixels hotspot
    in
    Attributes.ImageCursor url x y fallback


type ImageCoordinates
    = ImageCoordinates
