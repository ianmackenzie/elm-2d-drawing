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
    , toString
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


# Advanced

@docs toString

-}

import Pixels exposing (Pixels)
import Point2d exposing (Point2d)


type Cursor
    = Auto
    | Default
    | None
    | ContextMenu
    | Help
    | Pointer
    | Progress
    | Wait
    | Cell
    | Crosshair
    | Text
    | VerticalText
    | Alias
    | Copy
    | Move
    | NoDrop
    | NotAllowed
    | Grab
    | Grabbing
    | AllScroll
    | ColResize
    | RowResize
    | NResize
    | EResize
    | SResize
    | WResize
    | NeResize
    | NwResize
    | SeResize
    | SwResize
    | EwResize
    | NsResize
    | NeswResize
    | NwseResize
    | ZoomIn
    | ZoomOut
    | Image String Float Float Cursor


{-| -}
auto : Cursor
auto =
    Auto


{-| -}
default : Cursor
default =
    Default


{-| -}
none : Cursor
none =
    None


{-| -}
contextMenu : Cursor
contextMenu =
    ContextMenu


{-| -}
help : Cursor
help =
    Help


{-| -}
pointer : Cursor
pointer =
    Pointer


{-| -}
progress : Cursor
progress =
    Progress


{-| -}
wait : Cursor
wait =
    Wait


{-| -}
cell : Cursor
cell =
    Cell


{-| -}
crosshair : Cursor
crosshair =
    Crosshair


{-| -}
text : Cursor
text =
    Text


{-| -}
verticalText : Cursor
verticalText =
    VerticalText


{-| -}
alias_ : Cursor
alias_ =
    Alias


{-| -}
copy : Cursor
copy =
    Copy


{-| -}
move : Cursor
move =
    Move


{-| -}
noDrop : Cursor
noDrop =
    NoDrop


{-| -}
notAllowed : Cursor
notAllowed =
    NotAllowed


{-| -}
grab : Cursor
grab =
    Grab


{-| -}
grabbing : Cursor
grabbing =
    Grabbing


{-| -}
allScroll : Cursor
allScroll =
    AllScroll


{-| -}
colResize : Cursor
colResize =
    ColResize


{-| -}
rowResize : Cursor
rowResize =
    RowResize


{-| -}
nResize : Cursor
nResize =
    NResize


{-| -}
eResize : Cursor
eResize =
    EResize


{-| -}
sResize : Cursor
sResize =
    SResize


{-| -}
wResize : Cursor
wResize =
    WResize


{-| -}
neResize : Cursor
neResize =
    NeResize


{-| -}
nwResize : Cursor
nwResize =
    NwResize


{-| -}
seResize : Cursor
seResize =
    SeResize


{-| -}
swResize : Cursor
swResize =
    SwResize


{-| -}
ewResize : Cursor
ewResize =
    EwResize


{-| -}
nsResize : Cursor
nsResize =
    NsResize


{-| -}
neswResize : Cursor
neswResize =
    NeswResize


{-| -}
nwseResize : Cursor
nwseResize =
    NwseResize


{-| -}
zoomIn : Cursor
zoomIn =
    ZoomIn


{-| -}
zoomOut : Cursor
zoomOut =
    ZoomOut


image : { url : String, hotspot : Point2d Pixels ImageCoordinates, fallback : Cursor } -> Cursor
image { url, hotspot, fallback } =
    let
        { x, y } =
            Point2d.toPixels hotspot
    in
    Image url x y fallback


type ImageCoordinates
    = ImageCoordinates


toString : Cursor -> String
toString cursor =
    case cursor of
        Auto ->
            "auto"

        Default ->
            "default"

        None ->
            "none"

        ContextMenu ->
            "context-menu"

        Help ->
            "help"

        Pointer ->
            "pointer"

        Progress ->
            "progress"

        Wait ->
            "wait"

        Cell ->
            "cell"

        Crosshair ->
            "crosshair"

        Text ->
            "text"

        VerticalText ->
            "vertical-text"

        Alias ->
            "alias"

        Copy ->
            "copy"

        Move ->
            "move"

        NoDrop ->
            "no-drop"

        NotAllowed ->
            "not-allowed"

        Grab ->
            "grab"

        Grabbing ->
            "grabbing"

        AllScroll ->
            "all-scroll"

        ColResize ->
            "col-resize"

        RowResize ->
            "row-resize"

        NResize ->
            "n-resize"

        EResize ->
            "e-resize"

        SResize ->
            "s-resize"

        WResize ->
            "w-resize"

        NeResize ->
            "ne-resize"

        NwResize ->
            "nw-resize"

        SeResize ->
            "se-resize"

        SwResize ->
            "sw-resize"

        EwResize ->
            "ew-resize"

        NsResize ->
            "ns-resize"

        NeswResize ->
            "nesw-resize"

        NwseResize ->
            "nwse-resize"

        ZoomIn ->
            "zoom-in"

        ZoomOut ->
            "zoom-out"

        Image url x y fallback ->
            "url"
                ++ "("
                ++ url
                ++ ") "
                ++ String.fromFloat x
                ++ " "
                ++ String.fromFloat y
                ++ ", "
                ++ toString fallback
