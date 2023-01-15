module Drawing2d.LineJoin exposing
    ( LineJoin
    , bevel
    , miter
    , render
    , round
    )

import Drawing2d.RenderedSvg as RenderedSvg exposing (RenderedSvg)
import Svg.Attributes


type LineJoin
    = LineJoin String


bevel : LineJoin
bevel =
    LineJoin "bevel"


miter : LineJoin
miter =
    LineJoin "miter"


round : LineJoin
round =
    LineJoin "round"


render : LineJoin -> RenderedSvg units coordinates msg
render (LineJoin string) =
    RenderedSvg.attributes [ Svg.Attributes.strokeLinejoin string ]
