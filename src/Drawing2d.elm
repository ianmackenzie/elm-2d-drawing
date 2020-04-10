module Drawing2d exposing
    ( Element, Attribute
    , toHtml, Size, fixed, fit, fitWidth
    , empty, group, lineSegment, polyline, triangle, rectangle, boundingBox, polygon, arc, circle, ellipticalArc, ellipse, quadraticSpline, cubicSpline, text, image
    , add
    , noFill, blackFill, whiteFill, fillColor, fillGradient
    , Gradient, gradientFrom, gradientAlong, circularGradient
    , strokeWidth, blackStroke, whiteStroke, strokeColor, strokeGradient
    , miterStrokeJoins, roundStrokeJoins, bevelStrokeJoins
    , noStrokeCaps, roundStrokeCaps, squareStrokeCaps
    , dropShadow
    , noBorder, strokedBorder
    , fontSize, blackText, whiteText, textColor, fontFamily, textAnchor
    , Anchor, topLeft, topCenter, topRight, centerLeft, center, centerRight, bottomLeft, bottomCenter, bottomRight
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
    , Event
    )

{-|

@docs Element, Attribute

@docs toHtml, Size, fixed, fit, fitWidth


# Drawing

@docs empty, group, lineSegment, polyline, triangle, rectangle, boundingBox, polygon, arc, circle, ellipticalArc, ellipse, quadraticSpline, cubicSpline, text, image


# Attributes

@docs add


## Fill

@docs noFill, blackFill, whiteFill, fillColor, fillGradient


## Gradients

@docs Gradient, gradientFrom, gradientAlong, circularGradient


## Stroke

@docs strokeWidth, blackStroke, whiteStroke, strokeColor, strokeGradient


### Stroke joins

@docs miterStrokeJoins, roundStrokeJoins, bevelStrokeJoins


### Stroke caps

@docs noStrokeCaps, roundStrokeCaps, squareStrokeCaps


## Shadows

@docs dropShadow


## Borders

@docs noBorder, strokedBorder


## Text

@docs fontSize, blackText, whiteText, textColor, fontFamily, textAnchor


## Anchors

@docs Anchor, topLeft, topCenter, topRight, centerLeft, center, centerRight, bottomLeft, bottomCenter, bottomRight


# Events

All `Drawing2d` event handlers give you the event position in **drawing
coordinates**. For example, if you draw a circle at the point (200,300), then if
you click the center of the circle you'll get an event containing the point
(200,300) regardless of where on the page your drawing is, whether it's been
scaled to fit its container, or what `viewBox` you provided when calling
[`toHtml`](#toHtml).

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
import Pixels exposing (Pixels, inPixels, pixels)
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


type Element units coordinates event
    = Element
        (Bool -- borders visible
         -> Float -- pixel size in current units
         -> Float -- stroke width in current units
         -> Float -- font size in current units
         -> String -- encoded gradient fill in current units
         -> String -- encoded gradient stroke in current units
         -> Svg event
        )


type Size
    = Fixed
    | Fit
    | FitWidth


type alias Attribute units coordinates event =
    Attributes.Attribute units coordinates event


type alias Event drawingCoordinates msg =
    Attributes.Event drawingCoordinates msg


type alias Gradient units coordinates =
    Gradient.Gradient units coordinates


type alias Renderer a event =
    List (Svg.Attribute event) -> a -> Svg event


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


defaultAttributes : List (Attribute Pixels coordinates event)
defaultAttributes =
    [ blackStroke
    , strokeWidth (pixels 1)
    , bevelStrokeJoins
    , noStrokeCaps
    , whiteFill
    , strokedBorder
    , fontSize (pixels 20)
    , textColor Color.black
    , textAnchor bottomLeft
    ]


toHtml :
    { viewBox : Rectangle2d Pixels drawingCoordinates
    , size : Size
    }
    -> List (Attribute Pixels drawingCoordinates (Event drawingCoordinates msg))
    -> List (Element Pixels drawingCoordinates (Event drawingCoordinates msg))
    -> Html msg
toHtml { viewBox, size } attributes elements =
    let
        ( viewBoxWidth, viewBoxHeight ) =
            Rectangle2d.dimensions viewBox

        viewBoxAttribute =
            Svg.Attributes.viewBox <|
                String.join " "
                    [ String.fromFloat (-0.5 * inPixels viewBoxWidth)
                    , String.fromFloat (-0.5 * inPixels viewBoxHeight)
                    , String.fromFloat (inPixels viewBoxWidth)
                    , String.fromFloat (inPixels viewBoxHeight)
                    ]

        -- Based on https://css-tricks.com/scale-svg/
        containerSizeCss =
            case size of
                Fit ->
                    [ Html.Attributes.style "width" "100%"
                    , Html.Attributes.style "height" "100%"
                    ]

                Fixed ->
                    let
                        widthString =
                            String.fromFloat (inPixels viewBoxWidth) ++ "px"

                        heightString =
                            String.fromFloat (inPixels viewBoxHeight) ++ "px"
                    in
                    [ Html.Attributes.style "width" widthString
                    , Html.Attributes.style "height" heightString
                    ]

                FitWidth ->
                    let
                        dummyHeight =
                            "1px"

                        heightAsPercentOfWidth =
                            String.fromFloat (100 * Quantity.ratio viewBoxHeight viewBoxWidth)
                                ++ "%"

                        bottomPadding =
                            "calc(" ++ heightAsPercentOfWidth ++ " - " ++ dummyHeight ++ ")"
                    in
                    [ Html.Attributes.style "width" "100%"
                    , Html.Attributes.style "height" dummyHeight
                    , Html.Attributes.style "padding-bottom" bottomPadding
                    , Html.Attributes.style "overflow" "visible"
                    ]

        rootAttributeValues =
            Attributes.emptyAttributeValues
                |> Attributes.assignAttributes defaultAttributes
                |> Attributes.assignAttributes attributes

        (Element svgElement) =
            groupLike "svg" (viewBoxAttribute :: svgStaticCss) rootAttributeValues <|
                [ group [] elements |> relativeTo (Rectangle2d.axes viewBox)
                ]
    in
    Html.div (containerStaticCss ++ containerSizeCss)
        [ svgElement False 1 0 0 "" "" |> Svg.map (\(Event callback) -> callback viewBox) ]


fit : Size
fit =
    Fit


fitWidth : Size
fitWidth =
    FitWidth


fixed : Size
fixed =
    Fixed


empty : Element units coordinates event
empty =
    Element (\_ _ _ _ _ _ -> Svg.text "")


drawCurve :
    List (Attribute units coordinates event)
    -> Renderer curve event
    -> curve
    -> Element units coordinates event
drawCurve attributes renderer curve =
    let
        attributeValues =
            Attributes.collectAttributeValues attributes
    in
    Element <|
        \_ _ _ _ _ _ ->
            let
                givenAttributes =
                    [] |> Attributes.addCurveAttributes attributeValues

                svgAttributes =
                    Svg.Attributes.fill "none" :: givenAttributes

                curveElement =
                    renderer svgAttributes curve

                defs =
                    []
                        |> addStrokeGradient attributeValues
                        |> addDropShadow attributeValues
            in
            curveElement |> addDefs defs


drawRegion :
    List (Attribute units coordinates event)
    -> Renderer region event
    -> region
    -> Element units coordinates event
drawRegion attributes renderer region =
    let
        attributeValues =
            Attributes.collectAttributeValues attributes
    in
    Element <|
        \currentBordersVisible _ _ _ _ _ ->
            let
                bordersVisible =
                    attributeValues.borderVisibility
                        |> Maybe.withDefault currentBordersVisible

                svgAttributes =
                    [] |> Attributes.addRegionAttributes bordersVisible attributeValues

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
    List (Attribute units coordinates event)
    -> LineSegment2d units coordinates
    -> Element units coordinates event
lineSegment attributes givenSegment =
    drawCurve attributes Svg.lineSegment2d givenSegment


triangle :
    List (Attribute units coordinates event)
    -> Triangle2d units coordinates
    -> Element units coordinates event
triangle attributes givenTriangle =
    drawRegion attributes Svg.triangle2d givenTriangle


render :
    Bool
    -> Float
    -> Float
    -> Float
    -> String
    -> String
    -> Element units coordinates event
    -> Svg event
render arg1 arg2 arg3 arg4 arg5 arg6 (Element function) =
    function arg1 arg2 arg3 arg4 arg5 arg6


group :
    List (Attribute units coordinates event)
    -> List (Element units coordinates event)
    -> Element units coordinates event
group attributes childElements =
    groupLike "g" [] (Attributes.collectAttributeValues attributes) childElements


groupLike :
    String
    -> List (Svg.Attribute event)
    -> AttributeValues units coordinates event
    -> List (Element units coordinates event)
    -> Element units coordinates event
groupLike tag extraSvgAttributes attributeValues childElements =
    Element <|
        \currentBordersVisible currentPixelSize currentStrokeWidth currentFontSize currentFillGradient currentStrokeGradient ->
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

                childSvgElements =
                    childElements
                        |> List.map
                            (render
                                updatedBordersVisible
                                currentPixelSize
                                updatedStrokeWidth
                                updatedFontSize
                                updatedFillGradient
                                updatedStrokeGradient
                            )

                defs =
                    []
                        |> addStrokeGradient attributeValues
                        |> addFillGradient attributeValues
                        |> addDropShadow attributeValues

                groupAttributes =
                    Attributes.addGroupAttributes attributeValues []
            in
            Svg.node tag
                (groupAttributes ++ extraSvgAttributes)
                (defs ++ childSvgElements)


add :
    List (Attribute units coordinates event)
    -> Element units coordinates event
    -> Element units coordinates event
add attributes element =
    group attributes [ element ]


arc :
    List (Attribute units coordinates event)
    -> Arc2d units coordinates
    -> Element units coordinates event
arc attributes givenArc =
    drawCurve attributes Svg.arc2d givenArc


quadraticSpline :
    List (Attribute units coordinates event)
    -> QuadraticSpline2d units coordinates
    -> Element units coordinates event
quadraticSpline attributes givenSpline =
    drawCurve attributes Svg.quadraticSpline2d givenSpline


cubicSpline :
    List (Attribute units coordinates event)
    -> CubicSpline2d units coordinates
    -> Element units coordinates event
cubicSpline attributes givenSpline =
    drawCurve attributes Svg.cubicSpline2d givenSpline


polyline :
    List (Attribute units coordinates event)
    -> Polyline2d units coordinates
    -> Element units coordinates event
polyline attributes givenPolyline =
    drawCurve attributes Svg.polyline2d givenPolyline


polygon :
    List (Attribute units coordinates event)
    -> Polygon2d units coordinates
    -> Element units coordinates event
polygon attributes givenPolygon =
    drawRegion attributes Svg.polygon2d givenPolygon


circle :
    List (Attribute units coordinates event)
    -> Circle2d units coordinates
    -> Element units coordinates event
circle attributes givenCircle =
    drawRegion attributes Svg.circle2d givenCircle


ellipticalArc :
    List (Attribute units coordinates event)
    -> EllipticalArc2d units coordinates
    -> Element units coordinates event
ellipticalArc attributes givenArc =
    drawCurve attributes Svg.ellipticalArc2d givenArc


ellipse :
    List (Attribute units coordinates event)
    -> Ellipse2d units coordinates
    -> Element units coordinates event
ellipse attributes givenEllipse =
    drawRegion attributes Svg.ellipse2d givenEllipse


rectangle :
    List (Attribute units coordinates event)
    -> Rectangle2d units coordinates
    -> Element units coordinates event
rectangle attributes givenRectangle =
    drawRegion attributes Svg.rectangle2d givenRectangle


boundingBox :
    List (Attribute units coordinates event)
    -> BoundingBox2d units coordinates
    -> Element units coordinates event
boundingBox attributes givenBox =
    drawRegion attributes Svg.boundingBox2d givenBox


text :
    List (Attribute units coordinates event)
    -> Point2d units coordinates
    -> String
    -> Element units coordinates event
text attributes position string =
    let
        attributeValues =
            Attributes.collectAttributeValues attributes

        { x, y } =
            Point2d.unwrap position
    in
    Element <|
        \_ _ _ _ _ _ ->
            let
                svgAttributes =
                    [ Svg.Attributes.x (String.fromFloat x)
                    , Svg.Attributes.y (String.fromFloat -y)
                    , Svg.Attributes.fill "currentColor"
                    , Svg.Attributes.stroke "none"
                    ]
                        |> Attributes.addTextAttributes attributeValues
            in
            Svg.text_ svgAttributes [ Svg.text string ]
                |> addDefs (addDropShadow attributeValues [])


image :
    List (Attribute units coordinates event)
    -> String
    -> Rectangle2d units coordinates
    -> Element units coordinates event
image attributes givenUrl givenRectangle =
    let
        attributeValues =
            Attributes.collectAttributeValues attributes

        ( Quantity width, Quantity height ) =
            Rectangle2d.dimensions givenRectangle
    in
    Element <|
        \_ _ _ _ _ _ ->
            let
                svgAttributes =
                    [ Svg.Attributes.xlinkHref givenUrl
                    , Svg.Attributes.x (String.fromFloat (-width / 2))
                    , Svg.Attributes.y (String.fromFloat (-height / 2))
                    , Svg.Attributes.width (String.fromFloat width)
                    , Svg.Attributes.height (String.fromFloat height)
                    , placementTransform (Rectangle2d.axes givenRectangle)
                    ]
                        |> Attributes.addShadowFilter attributeValues
                        |> Attributes.addEventHandlers attributeValues
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
    -> Element units localCoordinates event
    -> Element units globalCoordinates event
placeIn frame (Element function) =
    Element
        (\currentBordersVisible currentPixelSize currentStrokeWidth currentFontSize currentFillGradient currentStrokeGradient ->
            let
                toLocalGradient =
                    Gradient.relativeTo frame

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
                        currentPixelSize
                        currentStrokeWidth
                        currentFontSize
                        updatedFillGradient
                        updatedStrokeGradient

                localElement =
                    case localGradientElements of
                        [] ->
                            localSvgElement

                        _ ->
                            Svg.g localGradientReferences (localSvgElement :: localGradientElements)
            in
            Svg.g [ placementTransform frame ] [ localElement ]
        )


scaleAbout :
    Point2d units coordinates
    -> Float
    -> Element units coordinates event
    -> Element units coordinates event
scaleAbout point scale element =
    scaleImpl point scale element


scaleImpl :
    Point2d units1 coordinates
    -> Float
    -> Element units1 coordinates event
    -> Element units2 coordinates event
scaleImpl point scale (Element function) =
    let
        { x, y } =
            Point2d.unwrap point

        matrixComponents =
            [ String.fromFloat scale
            , String.fromFloat 0
            , String.fromFloat 0
            , String.fromFloat scale
            , String.fromFloat (-(scale - 1) * x)
            , String.fromFloat ((scale - 1) * y)
            ]

        transform =
            "matrix(" ++ String.join " " matrixComponents ++ ")"
    in
    Element
        (\currentBordersVisible currentPixelSize currentStrokeWidth currentFontSize currentFillGradient currentStrokeGradient ->
            let
                transformation =
                    Gradient.scaleAbout point (1 / scale)

                transformedFillGradient =
                    Gradient.decode currentFillGradient
                        |> Maybe.map transformation

                transformedStrokeGradient =
                    Gradient.decode currentStrokeGradient
                        |> Maybe.map transformation

                updatedFillGradient =
                    transformedFillGradient
                        |> Maybe.map Gradient.encode
                        |> Maybe.withDefault ""

                updatedStrokeGradient =
                    transformedStrokeGradient
                        |> Maybe.map Gradient.encode
                        |> Maybe.withDefault ""

                updatedPixelSize =
                    currentPixelSize / scale

                updatedStrokeWidth =
                    currentStrokeWidth / scale

                updatedFontSize =
                    currentFontSize / scale

                svgAttributes =
                    [ Svg.Attributes.transform transform
                    , Svg.Attributes.fontSize
                        (String.fromFloat updatedFontSize)
                    , Svg.Attributes.strokeWidth
                        (String.fromFloat updatedStrokeWidth)
                    ]
                        |> addTransformedFillGradientReference
                            transformedFillGradient
                        |> addTransformedStrokeGradientReference
                            transformedStrokeGradient

                transformedGradientElements =
                    []
                        |> addGradientElements transformedFillGradient
                        |> addGradientElements transformedStrokeGradient

                childSvgElement =
                    function
                        currentBordersVisible
                        updatedPixelSize
                        updatedStrokeWidth
                        updatedFontSize
                        updatedFillGradient
                        updatedStrokeGradient

                groupElement =
                    case transformedGradientElements of
                        [] ->
                            Svg.g svgAttributes [ childSvgElement ]

                        _ ->
                            Svg.g svgAttributes (childSvgElement :: transformedGradientElements)
            in
            groupElement
        )


relativeTo :
    Frame2d units globalCoordinates { defines : localCoordinates }
    -> Element units globalCoordinates event
    -> Element units localCoordinates event
relativeTo frame element =
    element |> placeIn (Frame2d.atOrigin |> Frame2d.relativeTo frame)


translateBy :
    Vector2d units coordinates
    -> Element units coordinates event
    -> Element units coordinates event
translateBy displacement element =
    element |> placeIn (Frame2d.atOrigin |> Frame2d.translateBy displacement)


translateIn :
    Direction2d coordinates
    -> Quantity Float units
    -> Element units coordinates event
    -> Element units coordinates event
translateIn direction distance element =
    element |> translateBy (Vector2d.withLength distance direction)


rotateAround :
    Point2d units coordinates
    -> Angle
    -> Element units coordinates event
    -> Element units coordinates event
rotateAround centerPoint angle element =
    element |> placeIn (Frame2d.atOrigin |> Frame2d.rotateAround centerPoint angle)


mirrorAcross :
    Axis2d units coordinates
    -> Element units coordinates event
    -> Element units coordinates event
mirrorAcross axis element =
    element |> placeIn (Frame2d.atOrigin |> Frame2d.mirrorAcross axis)


at :
    Quantity Float (Rate units2 units1)
    -> Element units1 coordinates event
    -> Element units2 coordinates event
at (Quantity scale) element =
    scaleImpl Point2d.origin scale element


at_ :
    Quantity Float (Rate units1 units2)
    -> Element units1 coordinates event
    -> Element units2 coordinates event
at_ (Quantity scale) element =
    scaleImpl Point2d.origin (1 / scale) element


mapEvent : (a -> b) -> Event drawingCoordinates a -> Event drawingCoordinates b
mapEvent function (Event callback) =
    Event (callback >> function)


map :
    (a -> b)
    -> Element units coordinates (Event drawingCoordinates a)
    -> Element units coordinates (Event drawingCoordinates b)
map mapFunction (Element drawFunction) =
    Element
        (\arg1 arg2 arg3 arg4 arg5 arg6 ->
            Svg.map (mapEvent mapFunction) (drawFunction arg1 arg2 arg3 arg4 arg5 arg6)
        )


addStrokeGradient : AttributeValues units coordinates event -> List (Svg event) -> List (Svg event)
addStrokeGradient attributeValues svgElements =
    case attributeValues.strokeStyle of
        Nothing ->
            svgElements

        Just (StrokeColor _) ->
            svgElements

        Just (StrokeGradient gradient) ->
            Gradient.render gradient svgElements


addFillGradient : AttributeValues units coordinates event -> List (Svg event) -> List (Svg event)
addFillGradient attributeValues svgElements =
    case attributeValues.fillStyle of
        Nothing ->
            svgElements

        Just NoFill ->
            svgElements

        Just (FillColor _) ->
            svgElements

        Just (FillGradient gradient) ->
            Gradient.render gradient svgElements


addGradientElements : Maybe (Gradient units coordinates) -> List (Svg event) -> List (Svg event)
addGradientElements maybeGradient svgElements =
    case maybeGradient of
        Nothing ->
            svgElements

        Just gradient ->
            Gradient.render gradient svgElements


addTransformedFillGradientReference :
    Maybe (Gradient units gradientCoordinates)
    -> List (Svg.Attribute event)
    -> List (Svg.Attribute event)
addTransformedFillGradientReference maybeGradient svgAttributes =
    case maybeGradient of
        Nothing ->
            svgAttributes

        Just gradient ->
            Svg.Attributes.fill (Gradient.reference gradient) :: svgAttributes


addTransformedStrokeGradientReference :
    Maybe (Gradient units gradientCoordinates)
    -> List (Svg.Attribute event)
    -> List (Svg.Attribute event)
addTransformedStrokeGradientReference maybeGradient svgAttributes =
    case maybeGradient of
        Nothing ->
            svgAttributes

        Just gradient ->
            Svg.Attributes.stroke (Gradient.reference gradient) :: svgAttributes


addDropShadow : AttributeValues units coordinates event -> List (Svg event) -> List (Svg event)
addDropShadow attributeValues svgElements =
    case attributeValues.dropShadow of
        Nothing ->
            svgElements

        Just shadow ->
            Shadow.element shadow :: svgElements


addDefs : List (Svg event) -> Svg event -> Svg event
addDefs defs svgElement =
    case defs of
        [] ->
            svgElement

        _ ->
            Svg.g [] (svgElement :: defs)


fillColor : Color -> Attribute units coordinates event
fillColor color =
    FillStyle (FillColor (Color.toCssString color))


noFill : Attribute units coordinates event
noFill =
    FillStyle (FillColor "none")


blackFill : Attribute units coordinates event
blackFill =
    FillStyle (FillColor "black")


whiteFill : Attribute units coordinates event
whiteFill =
    FillStyle (FillColor "white")


fillGradient : Gradient units coordinates -> Attribute units coordinates event
fillGradient gradient =
    FillStyle (FillGradient gradient)


strokeColor : Color -> Attribute units coordinates event
strokeColor color =
    StrokeStyle (StrokeColor (Color.toCssString color))


blackStroke : Attribute units coordinates event
blackStroke =
    StrokeStyle (StrokeColor "black")


whiteStroke : Attribute units coordinates event
whiteStroke =
    StrokeStyle (StrokeColor "white")


strokeGradient : Gradient units coordinates -> Attribute units coordinates event
strokeGradient gradient =
    StrokeStyle (StrokeGradient gradient)


noBorder : Attribute units coordinates event
noBorder =
    BorderVisibility False


strokedBorder : Attribute units coordinates event
strokedBorder =
    BorderVisibility True


strokeWidth : Quantity Float units -> Attribute units coordinates event
strokeWidth (Quantity size) =
    StrokeWidth size


roundStrokeJoins : Attribute units coordinates event
roundStrokeJoins =
    StrokeLineJoin RoundJoin


bevelStrokeJoins : Attribute units coordinates event
bevelStrokeJoins =
    StrokeLineJoin BevelJoin


miterStrokeJoins : Attribute units coordinates event
miterStrokeJoins =
    StrokeLineJoin MiterJoin


noStrokeCaps : Attribute units coordinates event
noStrokeCaps =
    StrokeLineCap NoCap


roundStrokeCaps : Attribute units coordinates event
roundStrokeCaps =
    StrokeLineCap RoundCap


squareStrokeCaps : Attribute units coordinates event
squareStrokeCaps =
    StrokeLineCap SquareCap


dropShadow :
    { radius : Quantity Float units
    , offset : Vector2d units coordinates
    , color : Color
    }
    -> Attribute units coordinates event
dropShadow properties =
    DropShadow (Shadow.with properties)


textAnchor : Anchor -> Attribute units coordinates event
textAnchor anchor =
    case anchor of
        TopLeft ->
            TextAnchor { x = "start", y = "hanging" }

        TopCenter ->
            TextAnchor { x = "middle", y = "hanging" }

        TopRight ->
            TextAnchor { x = "end", y = "hanging" }

        CenterLeft ->
            TextAnchor { x = "start", y = "middle" }

        Center ->
            TextAnchor { x = "middle", y = "middle" }

        CenterRight ->
            TextAnchor { x = "end", y = "middle" }

        BottomLeft ->
            TextAnchor { x = "start", y = "alphabetic" }

        BottomCenter ->
            TextAnchor { x = "middle", y = "alphabetic" }

        BottomRight ->
            TextAnchor { x = "end", y = "alphabetic" }


type Anchor
    = TopLeft
    | TopCenter
    | TopRight
    | CenterLeft
    | Center
    | CenterRight
    | BottomLeft
    | BottomCenter
    | BottomRight


topLeft : Anchor
topLeft =
    TopLeft


topCenter : Anchor
topCenter =
    TopCenter


topRight : Anchor
topRight =
    TopRight


centerLeft : Anchor
centerLeft =
    CenterLeft


center : Anchor
center =
    Center


centerRight : Anchor
centerRight =
    CenterRight


bottomLeft : Anchor
bottomLeft =
    BottomLeft


bottomCenter : Anchor
bottomCenter =
    BottomCenter


bottomRight : Anchor
bottomRight =
    BottomRight


blackText : Attribute units coordinates event
blackText =
    TextColor "black"


whiteText : Attribute units coordinates event
whiteText =
    TextColor "white"


textColor : Color -> Attribute units coordinates event
textColor color =
    TextColor (Color.toCssString color)


fontSize : Quantity Float units -> Attribute units coordinates event
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
fontFamily : List String -> Attribute units coordinates event
fontFamily fonts =
    FontFamily (fonts |> List.map normalizeFont |> String.join ",")


leftButton : Int
leftButton =
    0


middleButton : Int
middleButton =
    1


rightButton : Int
rightButton =
    2


onLeftClick :
    (Point2d Pixels drawingCoordinates -> msg)
    -> Attribute units coordinates (Event drawingCoordinates msg)
onLeftClick callback =
    decodeLeftClick (Decode.succeed callback)


onRightClick :
    (Point2d Pixels drawingCoordinates -> msg)
    -> Attribute units coordinates (Event drawingCoordinates msg)
onRightClick callback =
    decodeRightClick (Decode.succeed callback)


onLeftMouseDown :
    (Point2d Pixels drawingCoordinates -> MouseInteraction drawingCoordinates -> msg)
    -> Attribute units coordinates (Event drawingCoordinates msg)
onLeftMouseDown callback =
    decodeLeftMouseDown (Decode.succeed callback)


onRightMouseDown :
    (Point2d Pixels drawingCoordinates -> MouseInteraction drawingCoordinates -> msg)
    -> Attribute units coordinates (Event drawingCoordinates msg)
onRightMouseDown callback =
    decodeRightMouseDown (Decode.succeed callback)


onMiddleMouseDown :
    (Point2d Pixels drawingCoordinates -> MouseInteraction drawingCoordinates -> msg)
    -> Attribute units coordinates (Event drawingCoordinates msg)
onMiddleMouseDown callback =
    decodeMiddleMouseDown (Decode.succeed callback)


onLeftMouseUp : msg -> Attribute units coordinates (Event drawingCoordinates msg)
onLeftMouseUp message =
    decodeLeftMouseUp (Decode.succeed message)


onRightMouseUp : msg -> Attribute units coordinates (Event drawingCoordinates msg)
onRightMouseUp message =
    decodeRightMouseUp (Decode.succeed message)


onMiddleMouseUp : msg -> Attribute units coordinates (Event drawingCoordinates msg)
onMiddleMouseUp message =
    decodeMiddleMouseUp (Decode.succeed message)


onTouchStart :
    (Dict Int (Point2d Pixels drawingCoordinates) -> TouchInteraction drawingCoordinates -> msg)
    -> Attribute units coordinates (Event drawingCoordinates msg)
onTouchStart callback =
    decodeTouchStart (Decode.succeed callback)


decodeLeftClick :
    Decoder (Point2d Pixels drawingCoordinates -> msg)
    -> Attribute units coordinates (Event drawingCoordinates msg)
decodeLeftClick decoder =
    Attributes.EventHandlers [ ( "click", clickDecoder decoder ) ]


decodeRightClick :
    Decoder (Point2d Pixels drawingCoordinates -> msg)
    -> Attribute units coordinates (Event drawingCoordinates msg)
decodeRightClick decoder =
    Attributes.EventHandlers [ ( "contextmenu", clickDecoder decoder ) ]


decodeLeftMouseDown :
    Decoder (Point2d Pixels drawingCoordinates -> MouseInteraction drawingCoordinates -> msg)
    -> Attribute units coordinates (Event drawingCoordinates msg)
decodeLeftMouseDown decoder =
    Attributes.EventHandlers [ ( "mousedown", mouseDownDecoder leftButton decoder ) ]


decodeMiddleMouseDown :
    Decoder (Point2d Pixels drawingCoordinates -> MouseInteraction drawingCoordinates -> msg)
    -> Attribute units coordinates (Event drawingCoordinates msg)
decodeMiddleMouseDown decoder =
    Attributes.EventHandlers [ ( "mousedown", mouseDownDecoder middleButton decoder ) ]


decodeRightMouseDown :
    Decoder (Point2d Pixels drawingCoordinates -> MouseInteraction drawingCoordinates -> msg)
    -> Attribute units coordinates (Event drawingCoordinates msg)
decodeRightMouseDown decoder =
    Attributes.EventHandlers [ ( "mousedown", mouseDownDecoder rightButton decoder ) ]


decodeLeftMouseUp : Decoder msg -> Attribute units coordinates (Event drawingCoordinates msg)
decodeLeftMouseUp decoder =
    Attributes.EventHandlers [ ( "mouseup", mouseUpDecoder leftButton decoder ) ]


decodeMiddleMouseUp : Decoder msg -> Attribute units coordinates (Event drawingCoordinates msg)
decodeMiddleMouseUp decoder =
    Attributes.EventHandlers [ ( "mouseup", mouseUpDecoder middleButton decoder ) ]


decodeRightMouseUp : Decoder msg -> Attribute units coordinates (Event drawingCoordinates msg)
decodeRightMouseUp decoder =
    Attributes.EventHandlers [ ( "mouseup", mouseUpDecoder rightButton decoder ) ]


decodeTouchStart :
    Decoder
        (Dict Int (Point2d Pixels drawingCoordinates)
         -> TouchInteraction drawingCoordinates
         -> msg
        )
    -> Attribute units coordinates (Event drawingCoordinates msg)
decodeTouchStart decoder =
    Attributes.EventHandlers [ ( "touchstart", touchStartDecoder decoder ) ]


wrapMessage : msg -> Event drawingCoordinates msg
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


clickDecoder :
    Decoder (Point2d Pixels drawingCoordinates -> msg)
    -> Decoder (Event drawingCoordinates msg)
clickDecoder givenDecoder =
    Decode.map2 handleClick MouseStartEvent.decoder givenDecoder


handleClick :
    MouseStartEvent
    -> (Point2d Pixels drawingCoordinates -> msg)
    -> Event drawingCoordinates msg
handleClick mouseStartEvent userCallback =
    Event
        (\viewBox ->
            let
                drawingPoint =
                    InteractionPoint.position mouseStartEvent viewBox mouseStartEvent.container
            in
            userCallback drawingPoint
        )


mouseDownDecoder :
    Int
    -> Decoder (Point2d Pixels drawingCoordinates -> MouseInteraction drawingCoordinates -> msg)
    -> Decoder (Event drawingCoordinates msg)
mouseDownDecoder givenButton givenDecoder =
    filterByButton givenButton (Decode.map2 handleMouseDown MouseStartEvent.decoder givenDecoder)


handleMouseDown :
    MouseStartEvent
    -> (Point2d Pixels drawingCoordinates -> MouseInteraction drawingCoordinates -> msg)
    -> Event drawingCoordinates msg
handleMouseDown mouseStartEvent userCallback =
    Event
        (\viewBox ->
            let
                drawingPoint =
                    InteractionPoint.position mouseStartEvent viewBox mouseStartEvent.container

                mouseInteraction =
                    MouseInteraction.start mouseStartEvent viewBox
            in
            userCallback drawingPoint mouseInteraction
        )


mouseUpDecoder : Int -> Decoder msg -> Decoder (Event drawingCoordinates msg)
mouseUpDecoder givenButton givenDecoder =
    filterByButton givenButton (Decode.map wrapMessage givenDecoder)


touchStartDecoder :
    Decoder
        (Dict Int (Point2d Pixels drawingCoordinates)
         -> TouchInteraction drawingCoordinates
         -> msg
        )
    -> Decoder (Event drawingCoordinates msg)
touchStartDecoder givenDecoder =
    Decode.map2 handleTouchStart TouchStartEvent.decoder givenDecoder


handleTouchStart :
    TouchStartEvent
    -> (Dict Int (Point2d Pixels drawingCoordinates) -> TouchInteraction drawingCoordinates -> msg)
    -> Event drawingCoordinates msg
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
