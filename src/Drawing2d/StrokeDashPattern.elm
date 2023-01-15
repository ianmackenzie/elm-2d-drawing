module Drawing2d.StrokeDashPattern exposing
    ( StrokeDashPattern
    , at
    , at_
    , attribute
    , fromList
    , none
    , period
    , render
    , scaleBy
    )

import Drawing2d.RenderedSvg as RenderedSvg exposing (RenderedSvg)
import Quantity exposing (Quantity, Rate)
import Svg
import Svg.Attributes


type StrokeDashPattern units
    = StrokeDashPattern (List (Quantity Float units))


none : StrokeDashPattern units
none =
    StrokeDashPattern []


fromList : List (Quantity Float units) -> StrokeDashPattern units
fromList pattern =
    StrokeDashPattern pattern


at :
    Quantity Float (Rate units2 units1)
    -> StrokeDashPattern units1
    -> StrokeDashPattern units2
at rate (StrokeDashPattern pattern) =
    StrokeDashPattern (List.map (Quantity.at rate) pattern)


at_ :
    Quantity Float (Rate units1 units2)
    -> StrokeDashPattern units1
    -> StrokeDashPattern units2
at_ rate strokeDashPattern =
    at (Quantity.inverse rate) strokeDashPattern


scaleBy : Float -> StrokeDashPattern units -> StrokeDashPattern units
scaleBy scale (StrokeDashPattern pattern) =
    StrokeDashPattern (List.map (Quantity.multiplyBy scale) pattern)


attribute : StrokeDashPattern units -> Svg.Attribute event
attribute (StrokeDashPattern pattern) =
    Svg.Attributes.strokeDasharray <|
        case pattern of
            [] ->
                "none"

            _ ->
                String.join " " (List.map (Quantity.unwrap >> String.fromFloat) pattern)


render : StrokeDashPattern units -> RenderedSvg units coordinates msg
render strokeDashPattern =
    RenderedSvg.attributes [ attribute strokeDashPattern ]


period : StrokeDashPattern units -> Quantity Float units
period (StrokeDashPattern pattern) =
    let
        listSize =
            List.length pattern
    in
    if listSize == 0 then
        Quantity.zero

    else if modBy 2 listSize == 0 then
        Quantity.sum pattern

    else
        Quantity.twice (Quantity.sum pattern)
