module Drawing2d.Border
    exposing
        ( BorderPosition
        , centered
        , inside
        , outside
        )

import Drawing2d.BorderPosition as BorderPosition


type alias BorderPosition =
    BorderPosition.BorderPosition


centered : BorderPosition
centered =
    BorderPosition.Centered


inside : BorderPosition
inside =
    BorderPosition.Inside


outside : BorderPosition
outside =
    BorderPosition.Outside
