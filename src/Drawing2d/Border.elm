module Drawing2d.Border exposing
    ( BorderPosition
    , centered
    )

import Drawing2d.BorderPosition as BorderPosition


type alias BorderPosition =
    BorderPosition.BorderPosition


centered : BorderPosition
centered =
    BorderPosition.Centered
