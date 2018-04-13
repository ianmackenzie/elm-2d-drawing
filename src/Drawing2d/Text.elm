module Drawing2d.Text
    exposing
        ( Anchor
        , bottomCenter
        , bottomLeft
        , bottomRight
        , center
        , centerLeft
        , centerRight
        , topCenter
        , topLeft
        , topRight
        )

import Drawing2d.Internal as Internal


type alias Anchor =
    Internal.Anchor


topLeft : Anchor
topLeft =
    Internal.TopLeft


topCenter : Anchor
topCenter =
    Internal.TopCenter


topRight : Anchor
topRight =
    Internal.TopRight


centerLeft : Anchor
centerLeft =
    Internal.CenterLeft


center : Anchor
center =
    Internal.Center


centerRight : Anchor
centerRight =
    Internal.CenterRight


bottomLeft : Anchor
bottomLeft =
    Internal.BottomLeft


bottomCenter : Anchor
bottomCenter =
    Internal.BottomCenter


bottomRight : Anchor
bottomRight =
    Internal.BottomRight
