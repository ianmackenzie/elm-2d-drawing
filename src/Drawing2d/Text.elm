module Drawing2d.Text exposing
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

import Drawing2d.TextAnchor as TextAnchor


type alias Anchor =
    TextAnchor.Anchor


topLeft : Anchor
topLeft =
    TextAnchor.TopLeft


topCenter : Anchor
topCenter =
    TextAnchor.TopCenter


topRight : Anchor
topRight =
    TextAnchor.TopRight


centerLeft : Anchor
centerLeft =
    TextAnchor.CenterLeft


center : Anchor
center =
    TextAnchor.Center


centerRight : Anchor
centerRight =
    TextAnchor.CenterRight


bottomLeft : Anchor
bottomLeft =
    TextAnchor.BottomLeft


bottomCenter : Anchor
bottomCenter =
    TextAnchor.BottomCenter


bottomRight : Anchor
bottomRight =
    TextAnchor.BottomRight
