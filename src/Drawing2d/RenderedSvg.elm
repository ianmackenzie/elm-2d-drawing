module Drawing2d.RenderedSvg exposing
    ( RenderedSvg
    , add
    , addAttribute
    , addAttributes
    , addElement
    , addElements
    , attributes
    , elements
    , merge
    , nothing
    , with
    , wrap
    )

import Drawing2d.Event exposing (Event)
import Svg exposing (Svg)


type RenderedSvg units coordinates msg
    = RenderedSvg
        { attributes : List (Svg.Attribute (Event units coordinates msg))
        , elements : List (Svg (Event units coordinates msg))
        }


nothing : RenderedSvg units coordinates msg
nothing =
    RenderedSvg
        { attributes = []
        , elements = []
        }


attributes : List (Svg.Attribute (Event units coordinates msg)) -> RenderedSvg units coordinates msg
attributes givenAttributes =
    RenderedSvg
        { attributes = givenAttributes
        , elements = []
        }


elements : List (Svg (Event units coordinates msg)) -> RenderedSvg units coordinates msg
elements givenElements =
    RenderedSvg
        { attributes = []
        , elements = givenElements
        }


with :
    { attributes : List (Svg.Attribute (Event units coordinates msg))
    , elements : List (Svg (Event units coordinates msg))
    }
    -> RenderedSvg units coordinates msg
with properties =
    RenderedSvg properties


unwrap :
    RenderedSvg units coordinates msg
    ->
        { attributes : List (Svg.Attribute (Event units coordinates msg))
        , elements : List (Svg (Event units coordinates msg))
        }
unwrap (RenderedSvg renderedSvg) =
    renderedSvg


add : (a -> RenderedSvg units coordinates msg) -> Maybe a -> RenderedSvg units coordinates msg -> RenderedSvg units coordinates msg
add render maybe current =
    case maybe of
        Just value ->
            let
                (RenderedSvg new) =
                    render value

                (RenderedSvg existing) =
                    current
            in
            RenderedSvg
                { attributes = new.attributes ++ existing.attributes
                , elements = new.elements ++ existing.elements
                }

        Nothing ->
            current


addAttribute :
    Svg.Attribute (Event units coordinates msg)
    -> RenderedSvg units coordinates msg
    -> RenderedSvg units coordinates msg
addAttribute newAttribute (RenderedSvg renderedSvg) =
    RenderedSvg
        { attributes = newAttribute :: renderedSvg.attributes
        , elements = renderedSvg.elements
        }


addAttributes :
    List (Svg.Attribute (Event units coordinates msg))
    -> RenderedSvg units coordinates msg
    -> RenderedSvg units coordinates msg
addAttributes newAttributes (RenderedSvg renderedSvg) =
    RenderedSvg
        { attributes = newAttributes ++ renderedSvg.attributes
        , elements = renderedSvg.elements
        }


addElement :
    Svg (Event units coordinates msg)
    -> RenderedSvg units coordinates msg
    -> RenderedSvg units coordinates msg
addElement newElement (RenderedSvg renderedSvg) =
    RenderedSvg
        { attributes = renderedSvg.attributes
        , elements = newElement :: renderedSvg.elements
        }


addElements :
    List (Svg (Event units coordinates msg))
    -> RenderedSvg units coordinates msg
    -> RenderedSvg units coordinates msg
addElements newElements (RenderedSvg renderedSvg) =
    RenderedSvg
        { attributes = renderedSvg.attributes
        , elements = newElements ++ renderedSvg.elements
        }


merge : List (RenderedSvg units coordinates msg) -> RenderedSvg units coordinates msg
merge list =
    RenderedSvg
        { attributes = List.concatMap (unwrap >> .attributes) list
        , elements = List.concatMap (unwrap >> .elements) list
        }


wrap :
    (List (Svg.Attribute (Event units coordinates msg)) -> a -> Svg (Event units coordinates msg))
    -> RenderedSvg units coordinates msg
    -> a
    -> Svg (Event units coordinates msg)
wrap toSvg (RenderedSvg rendered) value =
    let
        svgElement =
            toSvg rendered.attributes value
    in
    case rendered.elements of
        [] ->
            svgElement

        renderedElements ->
            Svg.g [] (renderedElements ++ [ svgElement ])
