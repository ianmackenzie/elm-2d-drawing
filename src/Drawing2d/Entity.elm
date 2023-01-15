module Drawing2d.Entity exposing
    ( Entity
    , contextual
    , nothing
    , render
    , simple
    )

import Drawing2d.Event exposing (Event)
import Drawing2d.RenderContext exposing (RenderContext)
import Rectangle2d exposing (Rectangle2d)
import Svg exposing (Svg)


type Entity units coordinates msg
    = Entity (RenderContext units coordinates -> Svg (Event units coordinates msg))


nothing : Entity units coordinates msg
nothing =
    simple (Svg.text "")


simple : Svg (Event units coordinates msg) -> Entity units coordinates msg
simple element =
    Entity (\_ -> element)


contextual :
    (RenderContext units coordinates -> Svg (Event units coordinates msg))
    -> Entity units coordinates msg
contextual callback =
    Entity callback


render :
    RenderContext units coordinates
    -> Entity units coordinates msg
    -> Svg (Event units coordinates msg)
render context (Entity function) =
    function context
