module Drawing2d.LineCap exposing
    ( LineCap
    , none
    , render
    , round
    , square
    )

import Drawing2d.RenderedSvg as RenderedSvg exposing (RenderedSvg)
import Svg.Attributes


type LineCap
    = LineCap String


none : LineCap
none =
    LineCap "butt"


square : LineCap
square =
    LineCap "square"


round : LineCap
round =
    LineCap "round"


render : LineCap -> RenderedSvg units coordinates msg
render (LineCap string) =
    RenderedSvg.attributes [ Svg.Attributes.strokeLinecap string ]
