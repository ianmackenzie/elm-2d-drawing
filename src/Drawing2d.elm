module Drawing2d exposing
    ( Entity, Attribute
    , draw, custom
    , Size, fixed, scale, width, height, fit, fitWidth
    , empty, group, lineSegment, polyline, triangle, rectangle, boundingBox, polygon, arc, circle, ellipticalArc, ellipse, quadraticSpline, cubicSpline, text, image
    , add
    , noFill, transparentFill, blackFill, whiteFill, fillColor, fillGradient
    , Gradient, gradientFrom, gradientAlong, circularGradient
    , strokeWidth, blackStroke, whiteStroke, strokeColor, strokeGradient, dashedStroke, solidStroke
    , miterStrokeJoins, roundStrokeJoins, bevelStrokeJoins
    , noStrokeCaps, roundStrokeCaps, squareStrokeCaps
    , opacity
    , dropShadow
    , noBorder, strokedBorder
    , fontSize, fontFamily, blackText, whiteText, textColor
    , anchorAtTopLeft, anchorAtTopCenter, anchorAtTopRight, anchorAtCenterLeft, anchorAtCenter, anchorAtCenterRight, anchorAtBottomLeft, anchorAtBottomCenter, anchorAtBottomRight
    , autoCursor, defaultCursor, noCursor
    , contextMenuCursor, helpCursor, pointerCursor, progressCursor, waitCursor
    , cellCursor, crosshairCursor, textCursor, verticalTextCursor
    , aliasCursor, copyCursor, moveCursor, noDropCursor, notAllowedCursor, grabCursor, grabbingCursor
    , allScrollCursor, colResizeCursor, rowResizeCursor
    , nResizeCursor, eResizeCursor, sResizeCursor, wResizeCursor, neResizeCursor, nwResizeCursor, seResizeCursor, swResizeCursor, ewResizeCursor, nsResizeCursor, neswResizeCursor, nwseResizeCursor
    , zoomInCursor, zoomOutCursor
    , cursor
    , bestCursorEver
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

@docs empty, group, lineSegment, polyline, triangle, rectangle, boundingBox, polygon, arc, circle, ellipticalArc, ellipse, quadraticSpline, cubicSpline, text, image


# Attributes

@docs add


## Fill

@docs noFill, transparentFill, blackFill, whiteFill, fillColor, fillGradient


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


## Anchors

@docs anchorAtTopLeft, anchorAtTopCenter, anchorAtTopRight, anchorAtCenterLeft, anchorAtCenter, anchorAtCenterRight, anchorAtBottomLeft, anchorAtBottomCenter, anchorAtBottomRight


## Cursors

@docs autoCursor, defaultCursor, noCursor

@docs contextMenuCursor, helpCursor, pointerCursor, progressCursor, waitCursor

@docs cellCursor, crosshairCursor, textCursor, verticalTextCursor

@docs aliasCursor, copyCursor, moveCursor, noDropCursor, notAllowedCursor, grabCursor, grabbingCursor

@docs allScrollCursor, colResizeCursor, rowResizeCursor

@docs nResizeCursor, eResizeCursor, sResizeCursor, wResizeCursor, neResizeCursor, nwResizeCursor, seResizeCursor, swResizeCursor, ewResizeCursor, nsResizeCursor, neswResizeCursor, nwseResizeCursor

@docs zoomInCursor, zoomOutCursor

@docs cursor

@docs bestCursorEver


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
import DOM
import Dict exposing (Dict)
import Direction2d exposing (Direction2d)
import Drawing2d.Attributes as Attributes
    exposing
        ( Attribute(..)
        , AttributeValues
        , Event(..)
        , Fill(..)
        , LineCap(..)
        , LineJoin(..)
        , Stroke(..)
        )
import Drawing2d.Cursor as Cursor exposing (Cursor)
import Drawing2d.Decode as Decode
import Drawing2d.Gradient as Gradient
import Drawing2d.InteractionPoint as InteractionPoint
import Drawing2d.MouseInteraction as MouseInteraction exposing (MouseInteraction)
import Drawing2d.MouseInteraction.Protected as MouseInteraction
import Drawing2d.MouseMoveEvent as MouseMoveEvent exposing (MouseMoveEvent)
import Drawing2d.MouseStartEvent as MouseStartEvent exposing (MouseStartEvent)
import Drawing2d.Shadow as Shadow
import Drawing2d.Svg as Svg
import Drawing2d.TouchChangeEvent as TouchChangeEvent exposing (TouchChangeEvent)
import Drawing2d.TouchEndEvent as TouchEndEvent
import Drawing2d.TouchInteraction as TouchInteraction exposing (TouchInteraction)
import Drawing2d.TouchInteraction.Protected as TouchInteraction
import Drawing2d.TouchStartEvent as TouchStartEvent exposing (TouchStart, TouchStartEvent)
import Ellipse2d exposing (Ellipse2d)
import EllipticalArc2d exposing (EllipticalArc2d)
import Frame2d exposing (Frame2d)
import Html exposing (Html)
import Html.Attributes
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode exposing (Value)
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
import VirtualDom


type Entity units coordinates msg
    = Entity
        (Bool -- borders visible
         -> Float -- stroke width in current units
         -> Float -- font size in current units
         -> String -- encoded gradient fill in current units
         -> String -- encoded gradient stroke in current units
         -> String -- encoded dash pattern in current units
         -> Svg (Event units coordinates msg)
        )


type Size units
    = Scale (Quantity Float (Rate Pixels units))
    | Width (Quantity Float Pixels)
    | Height (Quantity Float Pixels)
    | Fit
    | FitWidth


type alias Attribute units coordinates msg =
    Attributes.Attribute units coordinates msg


type alias Gradient units coordinates =
    Gradient.Gradient units coordinates


type alias Renderer a units coordinates msg =
    List (Svg.Attribute (Event units coordinates msg)) -> a -> Svg (Event units coordinates msg)


topLevelRectangle : Rectangle2d units1 coordinates1 -> Rectangle2d units2 coordinates2
topLevelRectangle =
    Rectangle2d.placeIn Frame2d.atOrigin >> Rectangle2d.at (Quantity 1)


topLevelPoint : Point2d units1 coordinates1 -> Point2d units2 coordinates2
topLevelPoint =
    Point2d.unwrap >> Point2d.unsafe


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
    , strokeWidth : Quantity Float units
    , fontSize : Quantity Float units
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

        -- Based on https://css-tricks.com/scale-svg/
        containerSizeCss =
            case given.size of
                Scale factor ->
                    [ Html.Attributes.style "width" (px (viewBoxWidth |> Quantity.at factor))
                    , Html.Attributes.style "height" (px (viewBoxHeight |> Quantity.at factor))
                    ]

                Width value ->
                    let
                        factor =
                            value |> Quantity.per viewBoxWidth

                        computedHeight =
                            viewBoxHeight |> Quantity.at factor
                    in
                    [ Html.Attributes.style "width" (px value)
                    , Html.Attributes.style "height" (px computedHeight)
                    ]

                Height value ->
                    let
                        factor =
                            value |> Quantity.per viewBoxHeight

                        computedWidth =
                            viewBoxWidth |> Quantity.at factor
                    in
                    [ Html.Attributes.style "width" (px computedWidth)
                    , Html.Attributes.style "height" (px value)
                    ]

                Fit ->
                    [ Html.Attributes.style "width" "100%"
                    , Html.Attributes.style "height" "100%"
                    ]

                FitWidth ->
                    let
                        dummyHeight =
                            "1px"

                        heightAsPercentOfWidth =
                            String.fromFloat (100 * Quantity.ratio viewBoxHeight viewBoxWidth) ++ "%"

                        bottomPadding =
                            "calc(" ++ heightAsPercentOfWidth ++ " - " ++ dummyHeight ++ ")"
                    in
                    [ Html.Attributes.style "width" "100%"
                    , Html.Attributes.style "height" dummyHeight
                    , Html.Attributes.style "padding-bottom" bottomPadding
                    , Html.Attributes.style "overflow" "visible"
                    ]

        defaultAttributes =
            [ blackStroke
            , strokeWidth given.strokeWidth
            , bevelStrokeJoins
            , noStrokeCaps
            , noFill
            , strokedBorder
            , fontSize given.fontSize
            , blackText
            , anchorAtBottomLeft
            ]

        rootAttributeValues =
            Attributes.emptyAttributeValues
                |> Attributes.assignAttributes defaultAttributes

        (Entity svgElement) =
            groupLike "svg" (viewBoxAttribute :: svgStaticCss) rootAttributeValues <|
                [ group [] given.entities |> relativeTo (Rectangle2d.axes given.viewBox)
                ]

        topLevelViewBox =
            given.viewBox |> Rectangle2d.relativeTo (Rectangle2d.axes given.viewBox)
    in
    Html.div (containerStaticCss ++ containerSizeCss)
        [ svgElement False 0 0 "" "" "[]" |> Svg.map (\(Event callback) -> callback topLevelViewBox) ]


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


fit : Size units
fit =
    Fit


fitWidth : Size units
fitWidth =
    FitWidth


empty : Entity units coordinates msg
empty =
    Entity (\_ _ _ _ _ _ -> Svg.text "")


drawCurve :
    List (Attribute units coordinates msg)
    -> Renderer curve units coordinates msg
    -> curve
    -> Entity units coordinates msg
drawCurve attributes renderer curve =
    let
        attributeValues =
            Attributes.collectAttributeValues attributes
    in
    Entity <|
        \_ _ _ _ _ _ ->
            let
                svgAttributes =
                    Attributes.curveAttributes attributeValues

                curveElement =
                    renderer svgAttributes curve

                defs =
                    []
                        |> addStrokeGradient attributeValues
                        |> addDropShadow attributeValues
            in
            curveElement |> addDefs defs


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
    Entity <|
        \currentBordersVisible _ _ _ _ _ ->
            let
                bordersVisible =
                    attributeValues.borderVisibility
                        |> Maybe.withDefault currentBordersVisible

                svgAttributes =
                    Attributes.regionAttributes bordersVisible attributeValues

                fillGradientElement =
                    addFillGradient attributeValues []

                regionElement =
                    renderer svgAttributes region

                gradientElements =
                    if bordersVisible then
                        fillGradientElement
                            |> addStrokeGradient attributeValues

                    else
                        fillGradientElement

                defs =
                    gradientElements |> addDropShadow attributeValues
            in
            regionElement |> addDefs defs


lineSegment :
    List (Attribute units coordinates msg)
    -> LineSegment2d units coordinates
    -> Entity units coordinates msg
lineSegment attributes givenSegment =
    drawCurve attributes Svg.lineSegment2d givenSegment


triangle :
    List (Attribute units coordinates msg)
    -> Triangle2d units coordinates
    -> Entity units coordinates msg
triangle attributes givenTriangle =
    drawRegion attributes Svg.triangle2d givenTriangle


render :
    Bool
    -> Float
    -> Float
    -> String
    -> String
    -> String
    -> Entity units coordinates msg
    -> Svg (Event units coordinates msg)
render arg1 arg2 arg3 arg4 arg5 arg6 (Entity function) =
    function arg1 arg2 arg3 arg4 arg5 arg6


group :
    List (Attribute units coordinates msg)
    -> List (Entity units coordinates msg)
    -> Entity units coordinates msg
group attributes childEntities =
    groupLike "g" [] (Attributes.collectAttributeValues attributes) childEntities


encodeDashPattern : List Float -> String
encodeDashPattern dashPattern =
    Encode.list Encode.float dashPattern
        |> Encode.encode 0


dashPatternDecoder : Decoder (List Float)
dashPatternDecoder =
    Decode.list Decode.float


decodeDashPattern : String -> List Float
decodeDashPattern json =
    Decode.decodeString dashPatternDecoder json
        |> Result.withDefault []


groupLike :
    String
    -> List (Svg.Attribute (Event units coordinates msg))
    -> AttributeValues units coordinates msg
    -> List (Entity units coordinates msg)
    -> Entity units coordinates msg
groupLike tag extraSvgAttributes attributeValues childEntities =
    Entity <|
        \currentBordersVisible currentStrokeWidth currentFontSize currentFillGradient currentStrokeGradient currentDashPattern ->
            let
                updatedBordersVisible =
                    attributeValues.borderVisibility
                        |> Maybe.withDefault currentBordersVisible

                updatedStrokeWidth =
                    attributeValues.strokeWidth
                        |> Maybe.withDefault currentStrokeWidth

                updatedFontSize =
                    attributeValues.fontSize
                        |> Maybe.withDefault currentFontSize

                updatedFillGradient =
                    case attributeValues.fillStyle of
                        Nothing ->
                            currentFillGradient

                        Just NoFill ->
                            ""

                        Just TransparentFill ->
                            ""

                        Just (FillColor _) ->
                            ""

                        Just (FillGradient gradient) ->
                            Gradient.encode gradient

                updatedStrokeGradient =
                    case attributeValues.strokeStyle of
                        Nothing ->
                            currentStrokeGradient

                        Just (StrokeColor _) ->
                            ""

                        Just (StrokeGradient gradient) ->
                            Gradient.encode gradient

                updatedDashPattern =
                    case attributeValues.strokeDashPattern of
                        Nothing ->
                            currentDashPattern

                        Just dashPattern ->
                            encodeDashPattern dashPattern

                childSvgElements =
                    childEntities
                        |> List.map
                            (render
                                updatedBordersVisible
                                updatedStrokeWidth
                                updatedFontSize
                                updatedFillGradient
                                updatedStrokeGradient
                                updatedDashPattern
                            )

                defs =
                    []
                        |> addStrokeGradient attributeValues
                        |> addFillGradient attributeValues
                        |> addDropShadow attributeValues

                groupAttributes =
                    Attributes.groupAttributes attributeValues
            in
            Svg.node tag
                (groupAttributes ++ extraSvgAttributes)
                (defs ++ childSvgElements)


add :
    List (Attribute units coordinates msg)
    -> Entity units coordinates msg
    -> Entity units coordinates msg
add attributes entity =
    group attributes [ entity ]


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
    drawRegion attributes Svg.rectangle2d givenRectangle


boundingBox :
    List (Attribute units coordinates msg)
    -> BoundingBox2d units coordinates
    -> Entity units coordinates msg
boundingBox attributes givenBox =
    drawRegion attributes Svg.boundingBox2d givenBox


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
    in
    Entity <|
        \_ _ _ _ _ _ ->
            let
                svgAttributes =
                    Svg.Attributes.x (String.fromFloat x)
                        :: Svg.Attributes.y (String.fromFloat -y)
                        :: Attributes.textAttributes attributeValues
            in
            Svg.text_ svgAttributes [ Svg.text string ]
                |> addDefs (addDropShadow attributeValues [])


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
    in
    Entity <|
        \_ _ _ _ _ _ ->
            let
                svgAttributes =
                    Svg.Attributes.xlinkHref givenUrl
                        :: Svg.Attributes.x (String.fromFloat (-rectangleWidth / 2))
                        :: Svg.Attributes.y (String.fromFloat (-rectangleHeight / 2))
                        :: Svg.Attributes.width (String.fromFloat rectangleWidth)
                        :: Svg.Attributes.height (String.fromFloat rectangleHeight)
                        :: placementTransform (Rectangle2d.axes givenRectangle)
                        :: Attributes.imageAttributes attributeValues
            in
            Svg.image svgAttributes []
                |> addDefs (addDropShadow attributeValues [])


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
placeImpl transformationFrame coordinateConversionFrame (Entity function) =
    Entity <|
        \currentBordersVisible currentStrokeWidth currentFontSize currentFillGradient currentStrokeGradient currentDashPattern ->
            let
                toLocalGradient =
                    Gradient.relativeTo coordinateConversionFrame
                        >> Gradient.relativeTo transformationFrame

                localFillGradient =
                    Gradient.decode currentFillGradient
                        |> Maybe.map toLocalGradient

                localStrokeGradient =
                    Gradient.decode currentStrokeGradient
                        |> Maybe.map toLocalGradient

                updatedFillGradient =
                    localFillGradient
                        |> Maybe.map Gradient.encode
                        |> Maybe.withDefault ""

                updatedStrokeGradient =
                    localStrokeGradient
                        |> Maybe.map Gradient.encode
                        |> Maybe.withDefault ""

                localGradientReferences =
                    []
                        |> addTransformedFillGradientReference
                            localFillGradient
                        |> addTransformedStrokeGradientReference
                            localStrokeGradient

                localGradientElements =
                    []
                        |> addGradientElements localFillGradient
                        |> addGradientElements localStrokeGradient

                localSvgElement =
                    function
                        currentBordersVisible
                        currentStrokeWidth
                        currentFontSize
                        updatedFillGradient
                        updatedStrokeGradient
                        currentDashPattern

                localElement =
                    case localGradientElements of
                        [] ->
                            localSvgElement

                        _ ->
                            Svg.g localGradientReferences (localSvgElement :: localGradientElements)

                groupElement =
                    Svg.g [ placementTransform (Frame2d.placeIn coordinateConversionFrame transformationFrame) ]
                        [ localElement ]

                transformEvent (Event callback) =
                    Event (Rectangle2d.relativeTo coordinateConversionFrame >> callback)
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
scaleImpl centerPoint scaleFactor rate (Entity function) =
    Entity <|
        \currentBordersVisible currentStrokeWidth currentFontSize currentFillGradient currentStrokeGradient currentDashPattern ->
            let
                gradientTransformation =
                    Gradient.scaleAbout centerPoint scaleFactor >> Gradient.at rate

                transformedFillGradient =
                    Gradient.decode currentFillGradient
                        |> Maybe.map gradientTransformation

                transformedStrokeGradient =
                    Gradient.decode currentStrokeGradient
                        |> Maybe.map gradientTransformation

                updatedFillGradient =
                    transformedFillGradient
                        |> Maybe.map Gradient.encode
                        |> Maybe.withDefault ""

                updatedStrokeGradient =
                    transformedStrokeGradient
                        |> Maybe.map Gradient.encode
                        |> Maybe.withDefault ""

                (Quantity rateFactor) =
                    rate

                overallFactor =
                    scaleFactor * rateFactor

                updatedStrokeWidth =
                    currentStrokeWidth / overallFactor

                updatedFontSize =
                    currentFontSize / overallFactor

                scaledDashPattern =
                    decodeDashPattern currentDashPattern
                        |> List.map (\value -> value / overallFactor)

                updatedDashPattern =
                    encodeDashPattern scaledDashPattern

                svgAttributes =
                    [ scaleTransform centerPoint overallFactor
                    , Svg.Attributes.fontSize (String.fromFloat updatedFontSize)
                    , Svg.Attributes.strokeWidth (String.fromFloat updatedStrokeWidth)
                    ]
                        |> addTransformedFillGradientReference transformedFillGradient
                        |> addTransformedStrokeGradientReference transformedStrokeGradient
                        |> addScaledStrokeDashPattern scaledDashPattern

                transformedGradientElements =
                    []
                        |> addGradientElements transformedFillGradient
                        |> addGradientElements transformedStrokeGradient

                transformEvent (Event callback) =
                    Event (Rectangle2d.at_ rate >> callback)

                childSvgElement =
                    Svg.map transformEvent <|
                        function
                            currentBordersVisible
                            updatedStrokeWidth
                            updatedFontSize
                            updatedFillGradient
                            updatedStrokeGradient
                            updatedDashPattern
            in
            Svg.g svgAttributes (childSvgElement :: transformedGradientElements)


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
mapEvent function (Event callback) =
    Event (callback >> function)


map : (a -> b) -> Entity units coordinates a -> Entity units coordinates b
map function entity =
    mapImpl (mapEvent function) entity


mapImpl : (Event units1 coordinates1 msg1 -> Event units2 coordinates2 msg2) -> Entity units1 coordinates1 msg1 -> Entity units2 coordinates2 msg2
mapImpl function (Entity drawFunction) =
    Entity <|
        \arg1 arg2 arg3 arg4 arg5 arg6 ->
            Svg.map function (drawFunction arg1 arg2 arg3 arg4 arg5 arg6)


addStrokeGradient :
    AttributeValues units coordinates msg
    -> List (Svg (Event units coordinates msg))
    -> List (Svg (Event units coordinates msg))
addStrokeGradient attributeValues svgElements =
    case attributeValues.strokeStyle of
        Nothing ->
            svgElements

        Just (StrokeColor _) ->
            svgElements

        Just (StrokeGradient gradient) ->
            Gradient.render gradient svgElements


addFillGradient :
    AttributeValues units coordinates msg
    -> List (Svg (Event units coordinates msg))
    -> List (Svg (Event units coordinates msg))
addFillGradient attributeValues svgElements =
    case attributeValues.fillStyle of
        Nothing ->
            svgElements

        Just NoFill ->
            svgElements

        Just TransparentFill ->
            svgElements

        Just (FillColor _) ->
            svgElements

        Just (FillGradient gradient) ->
            Gradient.render gradient svgElements


addGradientElements :
    Maybe (Gradient units coordinates)
    -> List (Svg (Event units coordinates msg))
    -> List (Svg (Event units coordinates msg))
addGradientElements maybeGradient svgElements =
    case maybeGradient of
        Nothing ->
            svgElements

        Just gradient ->
            Gradient.render gradient svgElements


addTransformedFillGradientReference :
    Maybe (Gradient units gradientCoordinates)
    -> List (Svg.Attribute (Event units coordinates msg))
    -> List (Svg.Attribute (Event units coordinates msg))
addTransformedFillGradientReference maybeGradient svgAttributes =
    case maybeGradient of
        Nothing ->
            svgAttributes

        Just gradient ->
            Svg.Attributes.fill (Gradient.reference gradient) :: svgAttributes


addTransformedStrokeGradientReference :
    Maybe (Gradient units gradientCoordinates)
    -> List (Svg.Attribute (Event units coordinates msg))
    -> List (Svg.Attribute (Event units coordinates msg))
addTransformedStrokeGradientReference maybeGradient svgAttributes =
    case maybeGradient of
        Nothing ->
            svgAttributes

        Just gradient ->
            Svg.Attributes.stroke (Gradient.reference gradient) :: svgAttributes


addScaledStrokeDashPattern :
    List Float
    -> List (Svg.Attribute (Event units coordinates msg))
    -> List (Svg.Attribute (Event units coordinates msg))
addScaledStrokeDashPattern dashPattern svgAttributes =
    case dashPattern of
        [] ->
            -- No need to set dash pattern to 'none' again
            svgAttributes

        _ ->
            Attributes.dashPatternSvgAttribute dashPattern :: svgAttributes


addDropShadow :
    AttributeValues units coordinates msg
    -> List (Svg (Event units coordinates msg))
    -> List (Svg (Event units coordinates msg))
addDropShadow attributeValues svgElements =
    case attributeValues.dropShadow of
        Nothing ->
            svgElements

        Just shadow ->
            Shadow.element shadow :: svgElements


addDefs :
    List (Svg (Event units coordinates msg))
    -> Svg (Event units coordinates msg)
    -> Svg (Event units coordinates msg)
addDefs defs svgElement =
    case defs of
        [] ->
            svgElement

        _ ->
            Svg.g [] (svgElement :: defs)


fillColor : Color -> Attribute units coordinates msg
fillColor color =
    FillStyle (FillColor (Color.toCssString color))


noFill : Attribute units coordinates msg
noFill =
    FillStyle (FillColor "none")


transparentFill : Attribute units coordinates msg
transparentFill =
    FillStyle TransparentFill


blackFill : Attribute units coordinates msg
blackFill =
    FillStyle (FillColor "black")


whiteFill : Attribute units coordinates msg
whiteFill =
    FillStyle (FillColor "white")


fillGradient : Gradient units coordinates -> Attribute units coordinates msg
fillGradient gradient =
    FillStyle (FillGradient gradient)


strokeColor : Color -> Attribute units coordinates msg
strokeColor color =
    StrokeStyle (StrokeColor (Color.toCssString color))


blackStroke : Attribute units coordinates msg
blackStroke =
    StrokeStyle (StrokeColor "black")


whiteStroke : Attribute units coordinates msg
whiteStroke =
    StrokeStyle (StrokeColor "white")


strokeGradient : Gradient units coordinates -> Attribute units coordinates msg
strokeGradient gradient =
    StrokeStyle (StrokeGradient gradient)


dashedStroke : List (Quantity Float units) -> Attribute units coordinates msg
dashedStroke dashPattern =
    StrokeDashPattern (List.map Quantity.unwrap dashPattern)


solidStroke : Attribute units coordinates msg
solidStroke =
    StrokeDashPattern []


noBorder : Attribute units coordinates msg
noBorder =
    BorderVisibility False


strokedBorder : Attribute units coordinates msg
strokedBorder =
    BorderVisibility True


strokeWidth : Quantity Float units -> Attribute units coordinates msg
strokeWidth (Quantity size) =
    StrokeWidth size


roundStrokeJoins : Attribute units coordinates msg
roundStrokeJoins =
    StrokeLineJoin RoundJoin


bevelStrokeJoins : Attribute units coordinates msg
bevelStrokeJoins =
    StrokeLineJoin BevelJoin


miterStrokeJoins : Attribute units coordinates msg
miterStrokeJoins =
    StrokeLineJoin MiterJoin


noStrokeCaps : Attribute units coordinates msg
noStrokeCaps =
    StrokeLineCap NoCap


roundStrokeCaps : Attribute units coordinates msg
roundStrokeCaps =
    StrokeLineCap RoundCap


squareStrokeCaps : Attribute units coordinates msg
squareStrokeCaps =
    StrokeLineCap SquareCap


opacity : Float -> Attribute units coordinates msg
opacity value =
    Opacity value


dropShadow :
    { radius : Quantity Float units
    , offset : Vector2d units coordinates
    , color : Color
    }
    -> Attribute units coordinates msg
dropShadow properties =
    DropShadow (Shadow.with properties)


anchorAtTopLeft : Attribute units coordinates msg
anchorAtTopLeft =
    TextAnchor { x = "start", y = "hanging" }


anchorAtTopCenter : Attribute units coordinates msg
anchorAtTopCenter =
    TextAnchor { x = "middle", y = "hanging" }


anchorAtTopRight : Attribute units coordinates msg
anchorAtTopRight =
    TextAnchor { x = "end", y = "hanging" }


anchorAtCenterLeft : Attribute units coordinates msg
anchorAtCenterLeft =
    TextAnchor { x = "start", y = "middle" }


anchorAtCenter : Attribute units coordinates msg
anchorAtCenter =
    TextAnchor { x = "middle", y = "middle" }


anchorAtCenterRight : Attribute units coordinates msg
anchorAtCenterRight =
    TextAnchor { x = "end", y = "middle" }


anchorAtBottomLeft : Attribute units coordinates msg
anchorAtBottomLeft =
    TextAnchor { x = "start", y = "alphabetic" }


anchorAtBottomCenter : Attribute units coordinates msg
anchorAtBottomCenter =
    TextAnchor { x = "middle", y = "alphabetic" }


anchorAtBottomRight : Attribute units coordinates msg
anchorAtBottomRight =
    TextAnchor { x = "end", y = "alphabetic" }


blackText : Attribute units coordinates msg
blackText =
    TextColor "black"


whiteText : Attribute units coordinates msg
whiteText =
    TextColor "white"


textColor : Color -> Attribute units coordinates msg
textColor color =
    TextColor (Color.toCssString color)


fontSize : Quantity Float units -> Attribute units coordinates msg
fontSize (Quantity size) =
    FontSize size


normalizeFont : String -> String
normalizeFont font =
    if String.contains " " font then
        -- Font family name has spaces, should be quoted
        if
            (String.startsWith "\"" font && String.endsWith "\"" font)
                || (String.startsWith "'" font && String.endsWith "'" font)
        then
            -- Font family name is already quoted, don't need to do anything
            font

        else
            -- Font family name is not already quoted, add quotes
            "\"" ++ font ++ "\""

    else
        -- Font family name has no spaces, don't need quotes (note that generic
        -- font family names like 'sans-serif' *must not* be quoted, so we can't
        -- just always add quotes)
        font


{-| Generic font family names: <https://developer.mozilla.org/en-US/docs/Web/CSS/font-family#Values>
-}
fontFamily : List String -> Attribute units coordinates msg
fontFamily fonts =
    FontFamily (fonts |> List.map normalizeFont |> String.join ",")


{-| -}
autoCursor : Attribute units coordinates msg
autoCursor =
    Attributes.Cursor Attributes.AutoCursor


{-| -}
defaultCursor : Attribute units coordinates msg
defaultCursor =
    Attributes.Cursor Attributes.DefaultCursor


{-| -}
noCursor : Attribute units coordinates msg
noCursor =
    Attributes.Cursor Attributes.NoCursor


{-| -}
contextMenuCursor : Attribute units coordinates msg
contextMenuCursor =
    Attributes.Cursor Attributes.ContextMenuCursor


{-| -}
helpCursor : Attribute units coordinates msg
helpCursor =
    Attributes.Cursor Attributes.HelpCursor


{-| -}
pointerCursor : Attribute units coordinates msg
pointerCursor =
    Attributes.Cursor Attributes.PointerCursor


{-| -}
progressCursor : Attribute units coordinates msg
progressCursor =
    Attributes.Cursor Attributes.ProgressCursor


{-| -}
waitCursor : Attribute units coordinates msg
waitCursor =
    Attributes.Cursor Attributes.WaitCursor


{-| -}
cellCursor : Attribute units coordinates msg
cellCursor =
    Attributes.Cursor Attributes.CellCursor


{-| -}
crosshairCursor : Attribute units coordinates msg
crosshairCursor =
    Attributes.Cursor Attributes.CrosshairCursor


{-| -}
textCursor : Attribute units coordinates msg
textCursor =
    Attributes.Cursor Attributes.TextCursor


{-| -}
verticalTextCursor : Attribute units coordinates msg
verticalTextCursor =
    Attributes.Cursor Attributes.VerticalTextCursor


{-| -}
aliasCursor : Attribute units coordinates msg
aliasCursor =
    Attributes.Cursor Attributes.AliasCursor


{-| -}
copyCursor : Attribute units coordinates msg
copyCursor =
    Attributes.Cursor Attributes.CopyCursor


{-| -}
moveCursor : Attribute units coordinates msg
moveCursor =
    Attributes.Cursor Attributes.MoveCursor


{-| -}
noDropCursor : Attribute units coordinates msg
noDropCursor =
    Attributes.Cursor Attributes.NoDropCursor


{-| -}
notAllowedCursor : Attribute units coordinates msg
notAllowedCursor =
    Attributes.Cursor Attributes.NotAllowedCursor


{-| -}
grabCursor : Attribute units coordinates msg
grabCursor =
    Attributes.Cursor Attributes.GrabCursor


{-| -}
grabbingCursor : Attribute units coordinates msg
grabbingCursor =
    Attributes.Cursor Attributes.GrabbingCursor


{-| -}
allScrollCursor : Attribute units coordinates msg
allScrollCursor =
    Attributes.Cursor Attributes.AllScrollCursor


{-| -}
colResizeCursor : Attribute units coordinates msg
colResizeCursor =
    Attributes.Cursor Attributes.ColResizeCursor


{-| -}
rowResizeCursor : Attribute units coordinates msg
rowResizeCursor =
    Attributes.Cursor Attributes.RowResizeCursor


{-| -}
nResizeCursor : Attribute units coordinates msg
nResizeCursor =
    Attributes.Cursor Attributes.NResizeCursor


{-| -}
eResizeCursor : Attribute units coordinates msg
eResizeCursor =
    Attributes.Cursor Attributes.EResizeCursor


{-| -}
sResizeCursor : Attribute units coordinates msg
sResizeCursor =
    Attributes.Cursor Attributes.SResizeCursor


{-| -}
wResizeCursor : Attribute units coordinates msg
wResizeCursor =
    Attributes.Cursor Attributes.WResizeCursor


{-| -}
neResizeCursor : Attribute units coordinates msg
neResizeCursor =
    Attributes.Cursor Attributes.NeResizeCursor


{-| -}
nwResizeCursor : Attribute units coordinates msg
nwResizeCursor =
    Attributes.Cursor Attributes.NwResizeCursor


{-| -}
seResizeCursor : Attribute units coordinates msg
seResizeCursor =
    Attributes.Cursor Attributes.SeResizeCursor


{-| -}
swResizeCursor : Attribute units coordinates msg
swResizeCursor =
    Attributes.Cursor Attributes.SwResizeCursor


{-| -}
ewResizeCursor : Attribute units coordinates msg
ewResizeCursor =
    Attributes.Cursor Attributes.EwResizeCursor


{-| -}
nsResizeCursor : Attribute units coordinates msg
nsResizeCursor =
    Attributes.Cursor Attributes.NsResizeCursor


{-| -}
neswResizeCursor : Attribute units coordinates msg
neswResizeCursor =
    Attributes.Cursor Attributes.NeswResizeCursor


{-| -}
nwseResizeCursor : Attribute units coordinates msg
nwseResizeCursor =
    Attributes.Cursor Attributes.NwseResizeCursor


{-| -}
zoomInCursor : Attribute units coordinates msg
zoomInCursor =
    Attributes.Cursor Attributes.ZoomInCursor


{-| -}
zoomOutCursor : Attribute units coordinates msg
zoomOutCursor =
    Attributes.Cursor Attributes.ZoomOutCursor


cursor : Cursor -> Attribute units coordinates msg
cursor givenCursor =
    Attributes.Cursor givenCursor


{-| The best cursor ever.
-}
bestCursorEver : Attribute units coordinates msg
bestCursorEver =
    cursor <|
        Cursor.image
            { url = "https://ianmackenzie.github.io/elm-2d-drawing/cursors/cursor-dino.png"
            , hotspot = Point2d.pixels 8 8
            , fallback = Cursor.crosshair
            }


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


wrapMessage : msg -> Event units coordinates msg
wrapMessage message =
    Event (always message)


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
    Event
        (\viewBox ->
            let
                drawingPoint =
                    InteractionPoint.position mouseStartEvent viewBox mouseStartEvent.container
            in
            userCallback (topLevelPoint drawingPoint)
        )


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
    Event
        (\viewBox ->
            let
                drawingPoint =
                    InteractionPoint.position mouseStartEvent viewBox mouseStartEvent.container

                mouseInteraction =
                    MouseInteraction.start mouseStartEvent (topLevelRectangle viewBox)
            in
            userCallback (topLevelPoint drawingPoint) mouseInteraction
        )


mouseUpDecoder : Int -> Decoder msg -> Decoder (Event units coordinates msg)
mouseUpDecoder givenButton givenDecoder =
    filterByButton givenButton (Decode.map wrapMessage givenDecoder)


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
    Event
        (\viewBox ->
            let
                ( touchInteraction, initialPoints ) =
                    TouchInteraction.start touchStartEvent viewBox
            in
            userCallback initialPoints touchInteraction
        )


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
