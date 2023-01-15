module Drawing2d.FontFamily exposing
    ( FontFamily
    , fromNames
    , render
    )

import Drawing2d.RenderedSvg as RenderedSvg exposing (RenderedSvg)
import Svg.Attributes


type FontFamily
    = FontFamily String


fromNames : List String -> FontFamily
fromNames names =
    FontFamily (String.join "," (List.map normalize names))


normalize : String -> String
normalize name =
    if String.contains " " name then
        -- Font family name has spaces, should be quoted
        if
            (String.startsWith "\"" name && String.endsWith "\"" name)
                || (String.startsWith "'" name && String.endsWith "'" name)
        then
            -- Font family name is already quoted, don't need to do anything
            name

        else
            -- Font family name is not already quoted, add quotes
            "\"" ++ name ++ "\""

    else
        -- Font family name has no spaces, don't need quotes (note that generic
        -- font family names like 'sans-serif' *must not* be quoted, so we can't
        -- just always add quotes)
        name


render : FontFamily -> RenderedSvg units coordinates msg
render (FontFamily family) =
    RenderedSvg.attributes [ Svg.Attributes.fontFamily family ]
