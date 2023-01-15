module Drawing2d exposing
    ( Entity, Attribute
    , draw, custom
    , Size, fixed, scale, width, height
    , nothing, group, lineSegment, polyline, triangle, rectangle, boundingBox, polygon, arc, circle, ellipticalArc, ellipse, quadraticSpline, cubicSpline, text, image
    , noFill, transparentFill, blackFill, whiteFill, fillColor, fillGradient, hatchFill
    , Gradient, gradientFrom, gradientAlong, circularGradient
    , strokeWidth, blackStroke, whiteStroke, strokeColor, strokeGradient, dashedStroke, solidStroke
    , miterStrokeJoins, roundStrokeJoins, bevelStrokeJoins
    , noStrokeCaps, roundStrokeCaps, squareStrokeCaps
    , opacity
    , dropShadow
    , noBorder, strokedBorder
    , fontSize, fontFamily, blackText, whiteText, textColor
    , anchorAtStart, anchorAtMiddle, anchorAtEnd
    , alphabeticBaseline, centralBaseline, hangingBaseline, ideographicBaseline, mathematicalBaseline, middleBaseline, textAfterEdgeBaseline, textBeforeEdgeBaseline
    , autoCursor, defaultCursor, noCursor
    , contextMenuCursor, helpCursor, pointerCursor, progressCursor, waitCursor
    , cellCursor, crosshairCursor, textCursor, verticalTextCursor
    , aliasCursor, copyCursor, moveCursor, noDropCursor, notAllowedCursor, grabCursor, grabbingCursor
    , allScrollCursor, colResizeCursor, rowResizeCursor
    , nResizeCursor, eResizeCursor, sResizeCursor, wResizeCursor, neResizeCursor, nwResizeCursor, seResizeCursor, swResizeCursor, ewResizeCursor, nsResizeCursor, neswResizeCursor, nwseResizeCursor
    , zoomInCursor, zoomOutCursor
    , cursor
    , dinosaurCursor
    , unsafeCurve, unsafeRegion
    , with, Context, pixelSize, pixels, resolution, currentFontSize, ems, currentStrokeWidth
    , onLeftClick, onRightClick
    , onLeftMouseDown, onLeftMouseUp, onMiddleMouseDown, onMiddleMouseUp, onRightMouseDown, onRightMouseUp
    , onTouchStart
    , scaleAbout, rotateAround, translateBy, translateIn, mirrorAcross
    , at, at_
    , relativeTo, placeIn
    , map
    , decodeLeftClick, decodeRightClick
    , decodeLeftMouseDown, decodeLeftMouseUp, decodeMiddleMouseDown, decodeMiddleMouseUp, decodeRightMouseDown, decodeRightMouseUp
    , decodeTouchStart
    )

{-|

@docs Entity, Attribute

@docs draw, custom


# Size

@docs Size, fixed, scale, width, height, fit, fitWidth


# Drawing

@docs nothing, group, lineSegment, polyline, triangle, rectangle, boundingBox, polygon, arc, circle, ellipticalArc, ellipse, quadraticSpline, cubicSpline, text, image


## Fill

@docs noFill, transparentFill, blackFill, whiteFill, fillColor, fillGradient, hatchFill


## Gradients

@docs Gradient, gradientFrom, gradientAlong, circularGradient


## Stroke

@docs strokeWidth, blackStroke, whiteStroke, strokeColor, strokeGradient, dashedStroke, solidStroke


### Stroke joins

@docs miterStrokeJoins, roundStrokeJoins, bevelStrokeJoins


### Stroke caps

@docs noStrokeCaps, roundStrokeCaps, squareStrokeCaps


## Opacity

@docs opacity


## Shadows

@docs dropShadow


## Borders

@docs noBorder, strokedBorder


## Text

@docs fontSize, fontFamily, blackText, whiteText, textColor


### Alignment

@docs anchorAtStart, anchorAtMiddle, anchorAtEnd

@docs alphabeticBaseline, centralBaseline, hangingBaseline, ideographicBaseline, mathematicalBaseline, middleBaseline, textAfterEdgeBaseline, textBeforeEdgeBaseline


## Cursors

@docs autoCursor, defaultCursor, noCursor

@docs contextMenuCursor, helpCursor, pointerCursor, progressCursor, waitCursor

@docs cellCursor, crosshairCursor, textCursor, verticalTextCursor

@docs aliasCursor, copyCursor, moveCursor, noDropCursor, notAllowedCursor, grabCursor, grabbingCursor

@docs allScrollCursor, colResizeCursor, rowResizeCursor

@docs nResizeCursor, eResizeCursor, sResizeCursor, wResizeCursor, neResizeCursor, nwResizeCursor, seResizeCursor, swResizeCursor, ewResizeCursor, nsResizeCursor, neswResizeCursor, nwseResizeCursor

@docs zoomInCursor, zoomOutCursor

@docs cursor

@docs dinosaurCursor


## Advanced

@docs unsafeCurve, unsafeRegion

@docs with, Context, pixelSize, pixels, resolution, currentFontSize, ems, currentStrokeWidth


# Events

All `Drawing2d` event handlers give you the event position in **drawing
coordinates**. For example, if you draw a circle at the point (200,300), then if
you click the center of the circle you'll get an event containing the point
(200,300) regardless of where on the page your drawing is, whether it's been
scaled to fit its container, or what `viewBox` you provided when calling
[`draw`](#draw).

Under the hood, [this function](https://package.elm-lang.org/packages/debois/elm-dom/latest/DOM#boundingClientRect)
is used to help convert from mouse/touch event coordinates like `clientX` and
`clientY` to drawing coordinates. It should work fine in relatively simple
cases, but can get confused by things like thick margin/padding or scrolling. In
a production build, I recommend adding the following to your HTML file
somewhere:

    <script>
        Object.defineProperty(Element.prototype, 'boundingClientRect', {
            "get": function () { return this.getBoundingClientRect(); }
        });
    </script>

This makes it possible for JSON event decoders to access the
`getBoundingClientRect()` function as a JavaScript property. The decoders in
this package all attempt to access this property first and will fall back to the
pure-Elm function above if the property isn't present. This means that you can
add the above code to your HTML file if you ever notice inaccurate event
positions (or slow performance), and everything should get faster/more accurate
without you having to change any of your Elm code. For example, I use something
like the following, where `main.js` is assumed to be your compiled Elm code
containing a `Main` module:

    <!DOCTYPE HTML>
    <html>

    <head>
        <meta charset="UTF-8">
        <title>My app title</title>
        <script src="main.js"></script>
    </head>

    <body>
        <div id="elm"></div>
        <script>
            Object.defineProperty(Element.prototype, 'boundingClientRect', {
                "get": function () { return this.getBoundingClientRect(); }
            });
            var app = Elm.Main.init({ node: document.getElementById('elm') });
        </script>
    </body>

    </html>


## Clicks

@docs onLeftClick, onRightClick


## Mouse

@docs onLeftMouseDown, onLeftMouseUp, onMiddleMouseDown, onMiddleMouseUp, onRightMouseDown, onRightMouseUp


## Touch

@docs onTouchStart


# Transformations

@docs scaleAbout, rotateAround, translateBy, translateIn, mirrorAcross


# Unit conversions

@docs at, at_


# Coordinate conversions

@docs relativeTo, placeIn


# Message conversion

@docs map


# Custom event handling

The `decode*` functions are similar to [their `on*` counterparts](#events), but
allow you also perform whatever decoding you want on the underlying
[`MouseEvent`](https://developer.mozilla.org/en-US/docs/Web/API/MouseEvent) or
[`TouchEvent`](https://developer.mozilla.org/en-US/docs/Web/API/TouchEvent). For
example, if you wanted to get the `clientX` and `clientY` values from a click
event as well as the computed drawing coordinates, you might have a message type
something like

    type Msg
        = Click Float Float (Point2d Pixels DrawingCoordinates)

(where the two `Float` values represent `clientX` and `clientY`) and then use

    Drawing2d.decodeLeftClick
        (Decode.map2 Click
            (Decode.field "clientX" Decode.float)
            (Decode.field "clientY" Decode.float)
        )

Note that the `Click` message constructor takes _three_ parameters but we're
using `Decode.map2` to grab only _two_ fields from the mouse event. This means
that the decoder will actually return a partially applied function; that is, the
decoder will have the type

    Decoder (Point2d Pixels DrawingCoordinates -> Msg)

which is exactly what we need to pass to `decodeLeftClick`. When a click
happens, the provided decoder will be run to get a partially applied function,
a bunch of internal logic will be performed to compute the clicked drawing
point, and then that computed drawing point will be passed to the partially
applied function to finally return an actual message. Whew! It's a bit
intricate, but if you follow the above pattern it should hopefully be fairly
straightforward to use.

@docs decodeLeftClick, decodeRightClick

@docs decodeLeftMouseDown, decodeLeftMouseUp, decodeMiddleMouseDown, decodeMiddleMouseUp, decodeRightMouseDown, decodeRightMouseUp

@docs decodeTouchStart

-}

import Angle exposing (Angle)
import Arc2d exposing (Arc2d)
import Axis2d exposing (Axis2d)
import BoundingBox2d exposing (BoundingBox2d)
import Circle2d exposing (Circle2d)
import Color exposing (Color)
import CubicSpline2d exposing (CubicSpline2d)
import Dict exposing (Dict)
import Direction2d exposing (Direction2d)
import Drawing2d.Attributes as Attributes exposing (AttributeValues)
import Drawing2d.Cursor as Cursor exposing (Cursor)
import Drawing2d.Decode as Decode
import Drawing2d.Entity as Entity
import Drawing2d.Event as Event exposing (Event)
import Drawing2d.FillStyle as FillStyle
import Drawing2d.FontFamily as FontFamily
import Drawing2d.Gradient as Gradient
import Drawing2d.HatchPattern as HatchPattern
import Drawing2d.InteractionPoint as InteractionPoint
import Drawing2d.LineCap as LineCap
import Drawing2d.LineJoin as LineJoin
import Drawing2d.MouseInteraction as MouseInteraction exposing (MouseInteraction)
import Drawing2d.MouseInteraction.Protected as MouseInteraction
import Drawing2d.MouseStartEvent as MouseStartEvent exposing (MouseStartEvent)
import Drawing2d.RenderContext as RenderContext exposing (RenderContext)
import Drawing2d.RenderedSvg as RenderedSvg
import Drawing2d.Shadow as Shadow
import Drawing2d.StrokeDashPattern as StrokeDashPattern
import Drawing2d.StrokeStyle as StrokeStyle
import Drawing2d.Svg as Svg
import Drawing2d.TouchInteraction as TouchInteraction exposing (TouchInteraction)
import Drawing2d.TouchInteraction.Protected as TouchInteraction
import Drawing2d.TouchStartEvent as TouchStartEvent exposing (TouchStartEvent)
import Ellipse2d exposing (Ellipse2d)
import EllipticalArc2d exposing (EllipticalArc2d)
import Frame2d exposing (Frame2d)
import Html exposing (Html)
import Html.Attributes
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode
import LineSegment2d exposing (LineSegment2d)
import Pixels exposing (Pixels)
import Point2d exposing (Point2d)
import Polygon2d exposing (Polygon2d)
import Polyline2d exposing (Polyline2d)
import QuadraticSpline2d exposing (QuadraticSpline2d)
import Quantity exposing (Quantity(..), Rate)
import Rectangle2d exposing (Rectangle2d)
import Svg exposing (Svg)
import Svg.Attributes
import Svg.Events
import Triangle2d exposing (Triangle2d)
import Vector2d exposing (Vector2d)


type alias Entity units coordinates msg =
    Entity.Entity units coordinates msg


type Size units
    = Scale (Quantity Float (Rate Pixels units))
    | Width (Quantity Float Pixels)
    | Height (Quantity Float Pixels)


type alias Attribute units coordinates msg =
    Attributes.Attribute units coordinates msg


type alias Gradient units coordinates =
    Gradient.Gradient units coordinates


type alias Renderer a units coordinates msg =
    List (Svg.Attribute (Event units coordinates msg)) -> a -> Svg (Event units coordinates msg)


containerStaticCss : List (Html.Attribute msg)
containerStaticCss =
    [ Html.Attributes.style "position" "relative"
    , Html.Attributes.style "padding-top" "0px"
    , Html.Attributes.style "padding-right" "0px"
    , Html.Attributes.style "padding-left" "0px"
    , Html.Attributes.style "overflow" "hidden" -- needed for IE
    ]


svgStaticCss : List (Html.Attribute msg)
svgStaticCss =
    [ Html.Attributes.style "position" "absolute"
    , Html.Attributes.style "height" "100%"
    , Html.Attributes.style "width" "100%"
    , Html.Attributes.style "left" "0"
    , Html.Attributes.style "right" "0"
    ]


px : Quantity Float Pixels -> String
px value =
    String.fromFloat (Pixels.toFloat value) ++ "px"


draw :
    { viewBox : Rectangle2d Pixels coordinates
    , entities : List (Entity Pixels coordinates msg)
    }
    -> Html msg
draw arguments =
    custom
        { viewBox = arguments.viewBox
        , size = fixed
        , strokeWidth = Pixels.float 1
        , fontSize = Pixels.float 16
        , entities = arguments.entities
        }


custom :
    { viewBox : Rectangle2d units coordinates
    , size : Size units
    , strokeWidth : Quantity Float Pixels
    , fontSize : Quantity Float Pixels
    , entities : List (Entity units coordinates msg)
    }
    -> Html msg
custom given =
    let
        ( viewBoxWidth, viewBoxHeight ) =
            Rectangle2d.dimensions given.viewBox

        viewBoxAttribute =
            Svg.Attributes.viewBox <|
                String.join " "
                    [ String.fromFloat (-0.5 * Quantity.unwrap viewBoxWidth)
                    , String.fromFloat (-0.5 * Quantity.unwrap viewBoxHeight)
                    , String.fromFloat (Quantity.unwrap viewBoxWidth)
                    , String.fromFloat (Quantity.unwrap viewBoxHeight)
                    ]

        drawingResolution =
            case given.size of
                Scale factor ->
                    factor

                Width value ->
                    value |> Quantity.per viewBoxWidth

                Height value ->
                    value |> Quantity.per viewBoxHeight

        canvasWidth =
            viewBoxWidth |> Quantity.at drawingResolution

        canvasHeight =
            viewBoxHeight |> Quantity.at drawingResolution

        topLevelPixelSize =
            Pixels.pixel |> Quantity.at_ drawingResolution

        containerSizeCss =
            [ Html.Attributes.style "width" (px canvasWidth)
            , Html.Attributes.style "height" (px canvasHeight)
            ]

        defaultAttributes =
            [ blackStroke
            , strokeWidth (Quantity.at_ drawingResolution given.strokeWidth)
            , bevelStrokeJoins
            , noStrokeCaps
            , noFill
            , strokedBorder
            , fontSize (Quantity.at_ drawingResolution given.fontSize)
            , blackText
            , anchorAtStart
            , alphabeticBaseline
            ]

        svgOriginFrame =
            Rectangle2d.axes given.viewBox

        svgEntity =
            groupLike "svg" (viewBoxAttribute :: svgStaticCss) defaultAttributes <|
                [ group [] given.entities |> relativeTo svgOriginFrame
                ]

        topLevelViewBox =
            given.viewBox |> Rectangle2d.relativeTo svgOriginFrame

        initialRenderContext =
            RenderContext.init topLevelPixelSize topLevelViewBox
    in
    Html.div (containerStaticCss ++ containerSizeCss)
        [ Entity.render initialRenderContext svgEntity
            |> Svg.map (\event -> event topLevelViewBox)
        ]


fixed : Size Pixels
fixed =
    Scale (Quantity 1)


scale : Quantity Float (Rate Pixels units) -> Size units
scale factor =
    Scale factor


width : Quantity Float Pixels -> Size units
width value =
    Width value


height : Quantity Float Pixels -> Size units
height value =
    Height value


nothing : Entity units coordinates msg
nothing =
    Entity.nothing


drawCurve :
    List (Attribute units coordinates msg)
    -> Renderer curve units coordinates msg
    -> curve
    -> Entity units coordinates msg
drawCurve attributes renderer curve =
    let
        attributeValues =
            Attributes.collectAttributeValues attributes

        svgAttributes =
            Attributes.curveAttributes attributeValues
    in
    Entity.simple (RenderedSvg.wrap renderer svgAttributes curve)


drawRegion :
    List (Attribute units coordinates msg)
    -> Renderer region units coordinates msg
    -> region
    -> Entity units coordinates msg
drawRegion attributes renderer region =
    let
        attributeValues =
            Attributes.collectAttributeValues attributes
    in
    Entity.contextual <|
        \context ->
            let
                bordersVisible =
                    attributeValues.borderVisibility
                        |> Maybe.withDefault (RenderContext.bordersVisible context)

                svgAttributes =
                    Attributes.regionAttributes bordersVisible attributeValues
            in
            RenderedSvg.wrap renderer svgAttributes region


lineSegment :
    List (Attribute units coordinates msg)
    -> LineSegment2d units coordinates
    -> Entity units coordinates msg
lineSegment attributes givenSegment =
    drawCurve attributes Svg.lineSegment2d givenSegment


coordinatesString : Point2d units coordinates -> String
coordinatesString point =
    let
        { x, y } =
            Point2d.unwrap point
    in
    String.fromFloat x ++ " " ++ String.fromFloat -y


triangle :
    List (Attribute units coordinates msg)
    -> Triangle2d units coordinates
    -> Entity units coordinates msg
triangle attributes givenTriangle =
    drawRegion attributes Svg.triangle2d givenTriangle


group :
    List (Attribute units coordinates msg)
    -> List (Entity units coordinates msg)
    -> Entity units coordinates msg
group attributes childEntities =
    groupLike "g" [] attributes childEntities


groupLike :
    String
    -> List (Svg.Attribute (Event units coordinates msg))
    -> List (Attribute units coordinates msg)
    -> List (Entity units coordinates msg)
    -> Entity units coordinates msg
groupLike tag extraSvgAttributes attributes childEntities =
    Entity.contextual <|
        \currentContext ->
            let
                attributeValues =
                    Attributes.collectAttributeValues attributes

                childContext =
                    currentContext |> RenderContext.update attributeValues

                childSvgElements =
                    childEntities |> List.map (Entity.render childContext)

                groupAttributes =
                    RenderedSvg.merge
                        [ RenderedSvg.attributes extraSvgAttributes
                        , Attributes.groupAttributes attributeValues
                        ]
            in
            RenderedSvg.wrap (Svg.node tag) groupAttributes childSvgElements


arc :
    List (Attribute units coordinates msg)
    -> Arc2d units coordinates
    -> Entity units coordinates msg
arc attributes givenArc =
    drawCurve attributes Svg.arc2d givenArc


quadraticSpline :
    List (Attribute units coordinates msg)
    -> QuadraticSpline2d units coordinates
    -> Entity units coordinates msg
quadraticSpline attributes givenSpline =
    drawCurve attributes Svg.quadraticSpline2d givenSpline


cubicSpline :
    List (Attribute units coordinates msg)
    -> CubicSpline2d units coordinates
    -> Entity units coordinates msg
cubicSpline attributes givenSpline =
    drawCurve attributes Svg.cubicSpline2d givenSpline


polyline :
    List (Attribute units coordinates msg)
    -> Polyline2d units coordinates
    -> Entity units coordinates msg
polyline attributes givenPolyline =
    drawCurve attributes Svg.polyline2d givenPolyline


polygon :
    List (Attribute units coordinates msg)
    -> Polygon2d units coordinates
    -> Entity units coordinates msg
polygon attributes givenPolygon =
    drawRegion attributes Svg.polygon2d givenPolygon


circle :
    List (Attribute units coordinates msg)
    -> Circle2d units coordinates
    -> Entity units coordinates msg
circle attributes givenCircle =
    drawRegion attributes Svg.circle2d givenCircle


ellipticalArc :
    List (Attribute units coordinates msg)
    -> EllipticalArc2d units coordinates
    -> Entity units coordinates msg
ellipticalArc attributes givenArc =
    drawCurve attributes Svg.ellipticalArc2d givenArc


unsafeCurve :
    List (Attribute units coordinates msg)
    -> String
    -> Entity units coordinates msg
unsafeCurve attributes pathString =
    group attributes
        [ drawCurve [] Svg.unsafePath pathString
            |> mirrorAcross Axis2d.x
        ]


ellipse :
    List (Attribute units coordinates msg)
    -> Ellipse2d units coordinates
    -> Entity units coordinates msg
ellipse attributes givenEllipse =
    drawRegion attributes Svg.ellipse2d givenEllipse


rectangle :
    List (Attribute units coordinates msg)
    -> Rectangle2d units coordinates
    -> Entity units coordinates msg
rectangle attributes givenRectangle =
    polygon attributes (Rectangle2d.toPolygon givenRectangle)


boundingBox :
    List (Attribute units coordinates msg)
    -> BoundingBox2d units coordinates
    -> Entity units coordinates msg
boundingBox attributes givenBox =
    rectangle attributes (Rectangle2d.fromBoundingBox givenBox)


unsafeRegion :
    List (Attribute units coordinates msg)
    -> String
    -> Entity units coordinates msg
unsafeRegion attributes pathString =
    group attributes
        [ drawRegion [] Svg.unsafePath pathString
            |> mirrorAcross Axis2d.x
        ]


text :
    List (Attribute units coordinates msg)
    -> Point2d units coordinates
    -> String
    -> Entity units coordinates msg
text attributes position string =
    let
        attributeValues =
            Attributes.collectAttributeValues attributes

        { x, y } =
            Point2d.unwrap position

        svgAttributes =
            RenderedSvg.merge
                [ Attributes.textAttributes attributeValues
                , RenderedSvg.attributes
                    [ Svg.Attributes.x (String.fromFloat x)
                    , Svg.Attributes.y (String.fromFloat -y)
                    ]
                ]

        svgElement =
            RenderedSvg.wrap Svg.text_ svgAttributes [ Svg.text string ]
    in
    Entity.simple svgElement


image :
    List (Attribute units coordinates msg)
    -> String
    -> Rectangle2d units coordinates
    -> Entity units coordinates msg
image attributes givenUrl givenRectangle =
    let
        attributeValues =
            Attributes.collectAttributeValues attributes

        ( Quantity rectangleWidth, Quantity rectangleHeight ) =
            Rectangle2d.dimensions givenRectangle

        svgAttributes =
            RenderedSvg.merge
                [ Attributes.imageAttributes attributeValues
                , RenderedSvg.attributes
                    [ Svg.Attributes.xlinkHref givenUrl
                    , Svg.Attributes.x (String.fromFloat (-rectangleWidth / 2))
                    , Svg.Attributes.y (String.fromFloat (-rectangleHeight / 2))
                    , Svg.Attributes.width (String.fromFloat rectangleWidth)
                    , Svg.Attributes.height (String.fromFloat rectangleHeight)
                    , placementTransform (Rectangle2d.axes givenRectangle)
                    ]
                ]

        svgElement =
            RenderedSvg.wrap Svg.image svgAttributes []
    in
    Entity.simple svgElement


placementTransform : Frame2d units coordinates defines -> Svg.Attribute a
placementTransform frame =
    let
        p =
            Point2d.unwrap (Frame2d.originPoint frame)

        i =
            Direction2d.unwrap (Frame2d.xDirection frame)

        j =
            Direction2d.unwrap (Frame2d.yDirection frame)

        matrixComponents =
            [ String.fromFloat i.x
            , String.fromFloat -i.y
            , String.fromFloat -j.x
            , String.fromFloat j.y
            , String.fromFloat p.x
            , String.fromFloat -p.y
            ]

        transform =
            "matrix(" ++ String.join " " matrixComponents ++ ")"
    in
    Svg.Attributes.transform transform


placeIn :
    Frame2d units globalCoordinates { defines : localCoordinates }
    -> Entity units localCoordinates msg
    -> Entity units globalCoordinates msg
placeIn frame entity =
    placeImpl Frame2d.atOrigin frame entity


placeImpl :
    Frame2d units localCoordinates { defines : localCoordinates }
    -> Frame2d units globalCoordinates { defines : localCoordinates }
    -> Entity units localCoordinates msg
    -> Entity units globalCoordinates msg
placeImpl transformationFrame coordinateConversionFrame entity =
    Entity.contextual <|
        \currentContext ->
            let
                localContext =
                    currentContext
                        |> RenderContext.relativeTo
                            (Frame2d.placeIn coordinateConversionFrame transformationFrame)

                localSvgElement =
                    Entity.render localContext entity

                localElement =
                    RenderedSvg.wrap Svg.g (RenderContext.render localContext) [ localSvgElement ]

                transform =
                    placementTransform
                        (Frame2d.placeIn coordinateConversionFrame transformationFrame)

                groupElement =
                    Svg.g [ transform ] [ localElement ]

                transformEvent event =
                    Rectangle2d.relativeTo coordinateConversionFrame >> event
            in
            Svg.map transformEvent groupElement


scaleAbout :
    Point2d units coordinates
    -> Float
    -> Entity units coordinates msg
    -> Entity units coordinates msg
scaleAbout point factor entity =
    scaleImpl point factor (Quantity 1) entity


scaleTransform : Point2d units coordinates -> Float -> Svg.Attribute a
scaleTransform point factor =
    let
        { x, y } =
            Point2d.unwrap point

        matrixComponents =
            [ String.fromFloat factor
            , String.fromFloat 0
            , String.fromFloat 0
            , String.fromFloat factor
            , String.fromFloat (-(factor - 1) * x)
            , String.fromFloat ((factor - 1) * y)
            ]

        transformMatrixString =
            "matrix(" ++ String.join " " matrixComponents ++ ")"
    in
    Svg.Attributes.transform transformMatrixString


scaleImpl :
    Point2d units1 coordinates
    -> Float
    -> Quantity Float (Rate units2 units1)
    -> Entity units1 coordinates msg
    -> Entity units2 coordinates msg
scaleImpl centerPoint scaleFactor rate entity =
    Entity.contextual <|
        \currentContext ->
            let
                updatedContext =
                    currentContext
                        |> RenderContext.at_ rate
                        |> RenderContext.scaleAbout centerPoint (1 / scaleFactor)

                childSvgElement =
                    Entity.render updatedContext entity

                childElement =
                    RenderedSvg.wrap Svg.g (RenderContext.render updatedContext) [ childSvgElement ]

                transform =
                    scaleTransform centerPoint (scaleFactor * Quantity.unwrap rate)

                groupElement =
                    Svg.g [ transform ] [ childElement ]

                transformEvent event =
                    Rectangle2d.at_ rate >> event
            in
            Svg.map transformEvent groupElement


relativeTo :
    Frame2d units globalCoordinates { defines : localCoordinates }
    -> Entity units globalCoordinates msg
    -> Entity units localCoordinates msg
relativeTo frame entity =
    entity |> placeIn (Frame2d.atOrigin |> Frame2d.relativeTo frame)


translateBy :
    Vector2d units coordinates
    -> Entity units coordinates msg
    -> Entity units coordinates msg
translateBy displacement entity =
    placeImpl (Frame2d.atOrigin |> Frame2d.translateBy displacement) Frame2d.atOrigin entity


translateIn :
    Direction2d coordinates
    -> Quantity Float units
    -> Entity units coordinates msg
    -> Entity units coordinates msg
translateIn direction distance entity =
    entity |> translateBy (Vector2d.withLength distance direction)


rotateAround :
    Point2d units coordinates
    -> Angle
    -> Entity units coordinates msg
    -> Entity units coordinates msg
rotateAround centerPoint angle entity =
    placeImpl (Frame2d.atOrigin |> Frame2d.rotateAround centerPoint angle) Frame2d.atOrigin entity


mirrorAcross :
    Axis2d units coordinates
    -> Entity units coordinates msg
    -> Entity units coordinates msg
mirrorAcross axis entity =
    placeImpl (Frame2d.atOrigin |> Frame2d.mirrorAcross axis) Frame2d.atOrigin entity


at :
    Quantity Float (Rate units2 units1)
    -> Entity units1 coordinates msg
    -> Entity units2 coordinates msg
at rate entity =
    scaleImpl Point2d.origin 1 rate entity


at_ :
    Quantity Float (Rate units1 units2)
    -> Entity units1 coordinates msg
    -> Entity units2 coordinates msg
at_ rate entity =
    at (Quantity.inverse rate) entity


mapEvent : (a -> b) -> Event units coordinates a -> Event units coordinates b
mapEvent function event =
    event >> function


map : (a -> b) -> Entity units coordinates a -> Entity units coordinates b
map function entity =
    Entity.contextual (\context -> Svg.map (mapEvent function) (Entity.render context entity))


fillColor : Color -> Attribute units coordinates msg
fillColor color =
    Attributes.Fill (FillStyle.color color)


noFill : Attribute units coordinates msg
noFill =
    Attributes.Fill FillStyle.none


transparentFill : Attribute units coordinates msg
transparentFill =
    Attributes.Fill FillStyle.transparent


blackFill : Attribute units coordinates msg
blackFill =
    Attributes.Fill FillStyle.black


whiteFill : Attribute units coordinates msg
whiteFill =
    Attributes.Fill FillStyle.white


fillGradient : Gradient units coordinates -> Attribute units coordinates msg
fillGradient gradient =
    Attributes.Fill (FillStyle.gradient gradient)


hatchFill :
    { angle : Angle
    , spacing : Quantity Float units
    , strokeWidth : Quantity Float units
    , strokeColor : Color
    , fillColor : Maybe Color
    , dashPattern : List (Quantity Float units)
    , origin : Point2d units coordinates
    }
    -> Attribute units coordinates msg
hatchFill properties =
    let
        hatchPattern =
            HatchPattern.with
                { frame = Frame2d.atPoint properties.origin |> Frame2d.rotateBy properties.angle
                , spacing = Quantity.abs properties.spacing
                , strokeWidth = Quantity.abs properties.strokeWidth
                , strokeColor = properties.strokeColor
                , fillColor = properties.fillColor
                , dashPattern = properties.dashPattern
                }
    in
    Attributes.Fill (FillStyle.hatchPattern hatchPattern)


strokeColor : Color -> Attribute units coordinates msg
strokeColor color =
    Attributes.Stroke (StrokeStyle.color color)


blackStroke : Attribute units coordinates msg
blackStroke =
    Attributes.Stroke StrokeStyle.black


whiteStroke : Attribute units coordinates msg
whiteStroke =
    Attributes.Stroke StrokeStyle.white


strokeGradient : Gradient units coordinates -> Attribute units coordinates msg
strokeGradient gradient =
    Attributes.Stroke (StrokeStyle.gradient gradient)


dashedStroke : List (Quantity Float units) -> Attribute units coordinates msg
dashedStroke dashPattern =
    Attributes.DashPattern (StrokeDashPattern.fromList dashPattern)


solidStroke : Attribute units coordinates msg
solidStroke =
    Attributes.DashPattern StrokeDashPattern.none


noBorder : Attribute units coordinates msg
noBorder =
    Attributes.BorderVisibility False


strokedBorder : Attribute units coordinates msg
strokedBorder =
    Attributes.BorderVisibility True


strokeWidth : Quantity Float units -> Attribute units coordinates msg
strokeWidth givenWidth =
    Attributes.StrokeWidth givenWidth


roundStrokeJoins : Attribute units coordinates msg
roundStrokeJoins =
    Attributes.StrokeLineJoin LineJoin.round


bevelStrokeJoins : Attribute units coordinates msg
bevelStrokeJoins =
    Attributes.StrokeLineJoin LineJoin.bevel


miterStrokeJoins : Attribute units coordinates msg
miterStrokeJoins =
    Attributes.StrokeLineJoin LineJoin.miter


noStrokeCaps : Attribute units coordinates msg
noStrokeCaps =
    Attributes.StrokeLineCap LineCap.none


roundStrokeCaps : Attribute units coordinates msg
roundStrokeCaps =
    Attributes.StrokeLineCap LineCap.round


squareStrokeCaps : Attribute units coordinates msg
squareStrokeCaps =
    Attributes.StrokeLineCap LineCap.square


opacity : Float -> Attribute units coordinates msg
opacity value =
    Attributes.Opacity value


dropShadow :
    { radius : Quantity Float units
    , offset : Vector2d units coordinates
    , color : Color
    }
    -> Attribute units coordinates msg
dropShadow properties =
    Attributes.DropShadow (Shadow.with properties)


anchorAtStart : Attribute units coordinates msg
anchorAtStart =
    Attributes.TextAnchor "start"


anchorAtMiddle : Attribute units coordinates msg
anchorAtMiddle =
    Attributes.TextAnchor "middle"


anchorAtEnd : Attribute units coordinates msg
anchorAtEnd =
    Attributes.TextAnchor "end"


alphabeticBaseline : Attribute units coordinates msg
alphabeticBaseline =
    Attributes.DominantBaseline "alphabetic"


centralBaseline : Attribute units coordinates msg
centralBaseline =
    Attributes.DominantBaseline "central"


hangingBaseline : Attribute units coordinates msg
hangingBaseline =
    Attributes.DominantBaseline "hanging"


ideographicBaseline : Attribute units coordinates msg
ideographicBaseline =
    Attributes.DominantBaseline "ideographic"


mathematicalBaseline : Attribute units coordinates msg
mathematicalBaseline =
    Attributes.DominantBaseline "mathematical"


middleBaseline : Attribute units coordinates msg
middleBaseline =
    Attributes.DominantBaseline "middle"


textAfterEdgeBaseline : Attribute units coordinates msg
textAfterEdgeBaseline =
    Attributes.DominantBaseline "textAfterEdge"


textBeforeEdgeBaseline : Attribute units coordinates msg
textBeforeEdgeBaseline =
    Attributes.DominantBaseline "textBeforeEdge"


blackText : Attribute units coordinates msg
blackText =
    Attributes.TextColor Color.black


whiteText : Attribute units coordinates msg
whiteText =
    Attributes.TextColor Color.white


textColor : Color -> Attribute units coordinates msg
textColor color =
    Attributes.TextColor color


fontSize : Quantity Float units -> Attribute units coordinates msg
fontSize givenSize =
    Attributes.FontSize givenSize


{-| Generic font family names: <https://developer.mozilla.org/en-US/docs/Web/CSS/font-family#Values>
-}
fontFamily : List String -> Attribute units coordinates msg
fontFamily fonts =
    Attributes.FontFamily (FontFamily.fromNames fonts)


{-| -}
autoCursor : Attribute units coordinates msg
autoCursor =
    Attributes.Cursor Cursor.auto


{-| -}
defaultCursor : Attribute units coordinates msg
defaultCursor =
    Attributes.Cursor Cursor.default


{-| -}
noCursor : Attribute units coordinates msg
noCursor =
    Attributes.Cursor Cursor.none


{-| -}
contextMenuCursor : Attribute units coordinates msg
contextMenuCursor =
    Attributes.Cursor Cursor.contextMenu


{-| -}
helpCursor : Attribute units coordinates msg
helpCursor =
    Attributes.Cursor Cursor.help


{-| -}
pointerCursor : Attribute units coordinates msg
pointerCursor =
    Attributes.Cursor Cursor.pointer


{-| -}
progressCursor : Attribute units coordinates msg
progressCursor =
    Attributes.Cursor Cursor.progress


{-| -}
waitCursor : Attribute units coordinates msg
waitCursor =
    Attributes.Cursor Cursor.wait


{-| -}
cellCursor : Attribute units coordinates msg
cellCursor =
    Attributes.Cursor Cursor.cell


{-| -}
crosshairCursor : Attribute units coordinates msg
crosshairCursor =
    Attributes.Cursor Cursor.crosshair


{-| -}
textCursor : Attribute units coordinates msg
textCursor =
    Attributes.Cursor Cursor.text


{-| -}
verticalTextCursor : Attribute units coordinates msg
verticalTextCursor =
    Attributes.Cursor Cursor.verticalText


{-| -}
aliasCursor : Attribute units coordinates msg
aliasCursor =
    Attributes.Cursor Cursor.alias_


{-| -}
copyCursor : Attribute units coordinates msg
copyCursor =
    Attributes.Cursor Cursor.copy


{-| -}
moveCursor : Attribute units coordinates msg
moveCursor =
    Attributes.Cursor Cursor.move


{-| -}
noDropCursor : Attribute units coordinates msg
noDropCursor =
    Attributes.Cursor Cursor.noDrop


{-| -}
notAllowedCursor : Attribute units coordinates msg
notAllowedCursor =
    Attributes.Cursor Cursor.notAllowed


{-| -}
grabCursor : Attribute units coordinates msg
grabCursor =
    Attributes.Cursor Cursor.grab


{-| -}
grabbingCursor : Attribute units coordinates msg
grabbingCursor =
    Attributes.Cursor Cursor.grabbing


{-| -}
allScrollCursor : Attribute units coordinates msg
allScrollCursor =
    Attributes.Cursor Cursor.allScroll


{-| -}
colResizeCursor : Attribute units coordinates msg
colResizeCursor =
    Attributes.Cursor Cursor.colResize


{-| -}
rowResizeCursor : Attribute units coordinates msg
rowResizeCursor =
    Attributes.Cursor Cursor.rowResize


{-| -}
nResizeCursor : Attribute units coordinates msg
nResizeCursor =
    Attributes.Cursor Cursor.nResize


{-| -}
eResizeCursor : Attribute units coordinates msg
eResizeCursor =
    Attributes.Cursor Cursor.eResize


{-| -}
sResizeCursor : Attribute units coordinates msg
sResizeCursor =
    Attributes.Cursor Cursor.sResize


{-| -}
wResizeCursor : Attribute units coordinates msg
wResizeCursor =
    Attributes.Cursor Cursor.wResize


{-| -}
neResizeCursor : Attribute units coordinates msg
neResizeCursor =
    Attributes.Cursor Cursor.neResize


{-| -}
nwResizeCursor : Attribute units coordinates msg
nwResizeCursor =
    Attributes.Cursor Cursor.nwResize


{-| -}
seResizeCursor : Attribute units coordinates msg
seResizeCursor =
    Attributes.Cursor Cursor.seResize


{-| -}
swResizeCursor : Attribute units coordinates msg
swResizeCursor =
    Attributes.Cursor Cursor.swResize


{-| -}
ewResizeCursor : Attribute units coordinates msg
ewResizeCursor =
    Attributes.Cursor Cursor.ewResize


{-| -}
nsResizeCursor : Attribute units coordinates msg
nsResizeCursor =
    Attributes.Cursor Cursor.nsResize


{-| -}
neswResizeCursor : Attribute units coordinates msg
neswResizeCursor =
    Attributes.Cursor Cursor.neswResize


{-| -}
nwseResizeCursor : Attribute units coordinates msg
nwseResizeCursor =
    Attributes.Cursor Cursor.nwseResize


{-| -}
zoomInCursor : Attribute units coordinates msg
zoomInCursor =
    Attributes.Cursor Cursor.zoomIn


{-| -}
zoomOutCursor : Attribute units coordinates msg
zoomOutCursor =
    Attributes.Cursor Cursor.zoomOut


cursor : Cursor -> Attribute units coordinates msg
cursor givenCursor =
    Attributes.Cursor givenCursor


dinosaurCursor : Attribute units coordinates msg
dinosaurCursor =
    cursor <|
        Cursor.image
            { url = "https://ianmackenzie.github.io/elm-2d-drawing/cursors/cursor-dino.png"
            , hotspot = Point2d.pixels 8 8
            , fallback = Cursor.crosshair
            }


with : Context units coordinates a -> (a -> Entity units coordinates msg) -> Entity units coordinates msg
with context callback =
    let
        (Context access) =
            context
    in
    Entity.contextual
        (\renderContext ->
            Entity.render renderContext <|
                callback (access renderContext)
        )


type Context units coordinates a
    = Context (RenderContext units coordinates -> a)


pixelSize : Context units coordinates (Quantity Float units)
pixelSize =
    Context RenderContext.pixelSize


currentFontSize : Context units coordinates (Quantity Float units)
currentFontSize =
    Context RenderContext.fontSize


currentStrokeWidth : Context units coordinates (Quantity Float units)
currentStrokeWidth =
    Context RenderContext.strokeWidth


ems : Context units coordinates (Float -> Quantity Float units)
ems =
    Context (\renderContext value -> RenderContext.ems value renderContext)


pixels : Context units coordinates (Float -> Quantity Float units)
pixels =
    Context (\renderContext value -> RenderContext.pixels value renderContext)


resolution : Context units coordinates (Quantity Float (Rate units Pixels))
resolution =
    Context RenderContext.resolution


leftButton : Int
leftButton =
    0


middleButton : Int
middleButton =
    1


rightButton : Int
rightButton =
    2


onLeftClick : (Point2d units coordinates -> msg) -> Attribute units coordinates msg
onLeftClick callback =
    decodeLeftClick (Decode.succeed callback)


onRightClick : (Point2d units coordinates -> msg) -> Attribute units coordinates msg
onRightClick callback =
    decodeRightClick (Decode.succeed callback)


onLeftMouseDown :
    (Point2d units coordinates -> MouseInteraction units coordinates -> msg)
    -> Attribute units coordinates msg
onLeftMouseDown callback =
    decodeLeftMouseDown (Decode.succeed callback)


onRightMouseDown :
    (Point2d units coordinates -> MouseInteraction units coordinates -> msg)
    -> Attribute units coordinates msg
onRightMouseDown callback =
    decodeRightMouseDown (Decode.succeed callback)


onMiddleMouseDown :
    (Point2d units coordinates -> MouseInteraction units coordinates -> msg)
    -> Attribute units coordinates msg
onMiddleMouseDown callback =
    decodeMiddleMouseDown (Decode.succeed callback)


onLeftMouseUp : msg -> Attribute units coordinates msg
onLeftMouseUp message =
    decodeLeftMouseUp (Decode.succeed message)


onRightMouseUp : msg -> Attribute units coordinates msg
onRightMouseUp message =
    decodeRightMouseUp (Decode.succeed message)


onMiddleMouseUp : msg -> Attribute units coordinates msg
onMiddleMouseUp message =
    decodeMiddleMouseUp (Decode.succeed message)


onTouchStart :
    (Dict Int (Point2d units coordinates) -> TouchInteraction units coordinates -> msg)
    -> Attribute units coordinates msg
onTouchStart callback =
    decodeTouchStart (Decode.succeed callback)


decodeLeftClick : Decoder (Point2d units coordinates -> msg) -> Attribute units coordinates msg
decodeLeftClick decoder =
    Attributes.EventHandlers [ ( "click", clickDecoder decoder ) ]


decodeRightClick : Decoder (Point2d units coordinates -> msg) -> Attribute units coordinates msg
decodeRightClick decoder =
    Attributes.EventHandlers [ ( "contextmenu", clickDecoder decoder ) ]


decodeLeftMouseDown :
    Decoder (Point2d units coordinates -> MouseInteraction units coordinates -> msg)
    -> Attribute units coordinates msg
decodeLeftMouseDown decoder =
    Attributes.EventHandlers [ ( "mousedown", mouseDownDecoder leftButton decoder ) ]


decodeMiddleMouseDown :
    Decoder (Point2d units coordinates -> MouseInteraction units coordinates -> msg)
    -> Attribute units coordinates msg
decodeMiddleMouseDown decoder =
    Attributes.EventHandlers [ ( "mousedown", mouseDownDecoder middleButton decoder ) ]


decodeRightMouseDown :
    Decoder (Point2d units coordinates -> MouseInteraction units coordinates -> msg)
    -> Attribute units coordinates msg
decodeRightMouseDown decoder =
    Attributes.EventHandlers [ ( "mousedown", mouseDownDecoder rightButton decoder ) ]


decodeLeftMouseUp : Decoder msg -> Attribute units coordinates msg
decodeLeftMouseUp decoder =
    Attributes.EventHandlers [ ( "mouseup", mouseUpDecoder leftButton decoder ) ]


decodeMiddleMouseUp : Decoder msg -> Attribute units coordinates msg
decodeMiddleMouseUp decoder =
    Attributes.EventHandlers [ ( "mouseup", mouseUpDecoder middleButton decoder ) ]


decodeRightMouseUp : Decoder msg -> Attribute units coordinates msg
decodeRightMouseUp decoder =
    Attributes.EventHandlers [ ( "mouseup", mouseUpDecoder rightButton decoder ) ]


decodeTouchStart :
    Decoder (Dict Int (Point2d units coordinates) -> TouchInteraction units coordinates -> msg)
    -> Attribute units coordinates msg
decodeTouchStart decoder =
    Attributes.EventHandlers [ ( "touchstart", touchStartDecoder decoder ) ]


filterByButton : Int -> Decoder a -> Decoder a
filterByButton whichButton decoder =
    Decode.button
        |> Decode.andThen
            (\button ->
                if button == whichButton then
                    decoder

                else
                    Decode.wrongButton
            )


clickDecoder : Decoder (Point2d units coordinates -> msg) -> Decoder (Event units coordinates msg)
clickDecoder givenDecoder =
    Decode.map2 handleClick MouseStartEvent.decoder givenDecoder


handleClick : MouseStartEvent -> (Point2d units coordinates -> msg) -> Event units coordinates msg
handleClick mouseStartEvent userCallback =
    \viewBox ->
        let
            drawingPoint =
                InteractionPoint.position mouseStartEvent viewBox mouseStartEvent.container
        in
        userCallback drawingPoint


mouseDownDecoder :
    Int
    -> Decoder (Point2d units coordinates -> MouseInteraction units coordinates -> msg)
    -> Decoder (Event units coordinates msg)
mouseDownDecoder givenButton givenDecoder =
    filterByButton givenButton (Decode.map2 handleMouseDown MouseStartEvent.decoder givenDecoder)


handleMouseDown :
    MouseStartEvent
    -> (Point2d units coordinates -> MouseInteraction units coordinates -> msg)
    -> Event units coordinates msg
handleMouseDown mouseStartEvent userCallback =
    \viewBox ->
        let
            drawingPoint =
                InteractionPoint.position mouseStartEvent viewBox mouseStartEvent.container

            mouseInteraction =
                MouseInteraction.start mouseStartEvent viewBox
        in
        userCallback drawingPoint mouseInteraction


mouseUpDecoder : Int -> Decoder msg -> Decoder (Event units coordinates msg)
mouseUpDecoder givenButton givenDecoder =
    filterByButton givenButton (Decode.map always givenDecoder)


touchStartDecoder :
    Decoder (Dict Int (Point2d units coordinates) -> TouchInteraction units coordinates -> msg)
    -> Decoder (Event units coordinates msg)
touchStartDecoder givenDecoder =
    Decode.map2 handleTouchStart TouchStartEvent.decoder givenDecoder


handleTouchStart :
    TouchStartEvent
    -> (Dict Int (Point2d units coordinates) -> TouchInteraction units coordinates -> msg)
    -> Event units coordinates msg
handleTouchStart touchStartEvent userCallback =
    \viewBox ->
        let
            ( touchInteraction, initialPoints ) =
                TouchInteraction.start touchStartEvent viewBox
        in
        userCallback initialPoints touchInteraction


gradientFrom :
    ( Point2d units coordinates, Color )
    -> ( Point2d units coordinates, Color )
    -> Gradient units coordinates
gradientFrom start end =
    Gradient.from start end


gradientAlong :
    Axis2d units coordinates
    -> List ( Quantity Float units, Color )
    -> Gradient units coordinates
gradientAlong axis stops =
    Gradient.along axis stops


circularGradient :
    ( Point2d units coordinates, Color )
    -> ( Circle2d units coordinates, Color )
    -> Gradient units coordinates
circularGradient start end =
    Gradient.circular start end
