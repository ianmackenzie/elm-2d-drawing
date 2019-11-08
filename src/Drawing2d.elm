module Drawing2d exposing
    ( Attribute
    , DrawingCoordinates
    , Element
    , Size
    , arc
    , at
    , at_
    , circle
    , cubicSpline
    , ellipse
    , ellipticalArc
    , empty
    , fit
    , fitWidth
    , fixed
    , group
    , image
    , lineSegment
    , map
    , mirrorAcross
    , onLeftClick
    , onLeftMouseDown
    , onLeftMouseUp
    , onRightMouseDown
    , onRightMouseUp
    , placeIn
    , polygon
    , polyline
    , quadraticSpline
    , rectangle
    , relativeTo
    , rotateAround
    , scaleAbout
    , text
    , toHtml
    , translateBy
    , translateIn
    , triangle
    , with
    )

import Angle exposing (Angle)
import Arc2d exposing (Arc2d)
import Axis2d exposing (Axis2d)
import BoundingBox2d exposing (BoundingBox2d)
import Circle2d exposing (Circle2d)
import Color exposing (Color)
import CubicSpline2d exposing (CubicSpline2d)
import DOM
import Direction2d exposing (Direction2d)
import Drawing2d.Attributes as Attributes
import Drawing2d.Gradient as Gradient
import Drawing2d.Stops as Stops
import Drawing2d.Svg as Svg
import Drawing2d.Text as Text
import Drawing2d.Types as Types exposing (Attribute(..), ClickHandler, DownHandler, Fill(..), Gradient(..), Stop, Stops(..), Stroke(..), UpHandler)
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


type Element units coordinates msg
    = Element
        (Bool -- borders visible
         -> Float -- pixel size in current units
         -> Float -- stroke width in current units
         -> Float -- font size in current units
         -> String -- encoded gradient fill in current units
         -> String -- encoded gradient stroke in current units
         -> Float -- viewBox minX
         -> Float -- viewBox maxX
         -> Float -- viewBox minY
         -> Float -- viewBox maxY
         -> Svg msg
        )


type Size
    = Fixed
    | Fit
    | FitWidth


type alias DrawingCoordinates =
    Types.DrawingCoordinates


type DrawingAttribute msg
    = OnDrawingLeftClick (ClickHandler msg)
    | OnDrawingMouseDown Int (DownHandler msg)
    | OnDrawingMouseUp Int (UpHandler msg)


type alias Attribute units coordinates msg =
    Types.Attribute units coordinates msg


type alias ViewBox =
    BoundingBox2d Pixels DrawingCoordinates


{-| TODO pass 'screen' argument?
-}
custom : ((Float -> Quantity Float units) -> Element units coordinates msg) -> Element units coordinates msg
custom givenFunction =
    Element
        (\bordersVisible pixelSize strokeWidth fontSize gradientFill gradientStroke ->
            let
                (Element renderFunction) =
                    givenFunction (\numPixels -> Quantity (numPixels * pixelSize))
            in
            renderFunction bordersVisible pixelSize strokeWidth fontSize gradientFill gradientStroke
        )


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


defaultShapeAttributes : List (Attribute Pixels DrawingCoordinates msg)
defaultShapeAttributes =
    [ Attributes.blackStroke
    , Attributes.strokeWidth (pixels 1)
    , Attributes.whiteFill
    , Attributes.strokedBorder
    , Attributes.fontSize (pixels 20)
    , Attributes.textColor Color.black
    , Attributes.textAnchor Text.bottomLeft
    ]


onLeftClick : (Point2d Pixels DrawingCoordinates -> msg) -> DrawingAttribute msg
onLeftClick =
    OnDrawingLeftClick


onLeftMouseDown : (Point2d Pixels DrawingCoordinates -> Decoder (Point2d Pixels DrawingCoordinates) -> msg) -> DrawingAttribute msg
onLeftMouseDown =
    OnDrawingMouseDown leftButton


onRightMouseDown : (Point2d Pixels DrawingCoordinates -> Decoder (Point2d Pixels DrawingCoordinates) -> msg) -> DrawingAttribute msg
onRightMouseDown =
    OnDrawingMouseDown rightButton


onLeftMouseUp : (Point2d Pixels DrawingCoordinates -> msg) -> DrawingAttribute msg
onLeftMouseUp =
    OnDrawingMouseUp leftButton


onRightMouseUp : (Point2d Pixels DrawingCoordinates -> msg) -> DrawingAttribute msg
onRightMouseUp =
    OnDrawingMouseUp rightButton


toHtml :
    { viewBox : ViewBox
    , size : Size
    }
    -> List (DrawingAttribute msg)
    -> List (Attribute Pixels DrawingCoordinates msg)
    -> List (Element Pixels DrawingCoordinates msg)
    -> Html msg
toHtml { viewBox, size } drawingAttributes shapeAttributes elements =
    let
        ( width, height ) =
            BoundingBox2d.dimensions viewBox

        { minX, maxX, minY, maxY } =
            BoundingBox2d.extrema viewBox

        (Element rootElement) =
            group defaultShapeAttributes [ group shapeAttributes elements ]

        viewBoxAttribute =
            Svg.Attributes.viewBox <|
                String.join " "
                    [ String.fromFloat (inPixels minX)
                    , String.fromFloat -(inPixels maxY)
                    , String.fromFloat (inPixels width)
                    , String.fromFloat (inPixels height)
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
                            String.fromFloat (inPixels width) ++ "px"

                        heightString =
                            String.fromFloat (inPixels height) ++ "px"
                    in
                    [ Html.Attributes.style "width" widthString
                    , Html.Attributes.style "height" heightString
                    ]

                FitWidth ->
                    let
                        heightPercent =
                            String.fromFloat (100 * Quantity.ratio height width)

                        padding =
                            "calc(" ++ heightPercent ++ "% - 1px)"
                    in
                    [ Html.Attributes.style "width" "100%"
                    , Html.Attributes.style "height" "1px"
                    , Html.Attributes.style "overflow" "visible"
                    , Html.Attributes.style "padding-bottom" padding
                    ]

        topLevelAttributes =
            viewBoxAttribute
                :: List.map (topLevelAttribute viewBox) drawingAttributes
    in
    Html.div (containerStaticCss ++ containerSizeCss)
        [ Svg.svg (topLevelAttributes ++ svgStaticCss)
            [ rootElement
                False
                1
                0
                0
                ""
                ""
                (inPixels minX)
                (inPixels maxX)
                (inPixels minY)
                (inPixels maxY)
            ]
        ]


topLevelAttribute : ViewBox -> DrawingAttribute msg -> Svg.Attribute msg
topLevelAttribute viewBox drawingAttribute =
    case drawingAttribute of
        OnDrawingLeftClick toMessage ->
            Svg.Events.on "click" (handleMouseClick viewBox toMessage)

        OnDrawingMouseDown whichButton toMessage ->
            Svg.Events.on "mousedown" (handleMouseDown whichButton viewBox toMessage)

        OnDrawingMouseUp whichButton toMessage ->
            svgOnMouseUp whichButton viewBox toMessage


type alias MouseEvent =
    { container : DOM.Rectangle
    , clientX : Float
    , clientY : Float
    , pageX : Float
    , pageY : Float
    , button : Int
    }


decodeBoundingClientRect : Decoder DOM.Rectangle
decodeBoundingClientRect =
    DOM.boundingClientRect


decodeContainer : Decoder DOM.Rectangle
decodeContainer =
    Decode.field "target" <|
        Decode.oneOf
            [ Decode.at [ "ownerSVGElement", "parentNode" ]
                decodeBoundingClientRect
            , Decode.at [ "parentNode" ]
                decodeBoundingClientRect
            ]


decodeMouseEvent : Decoder MouseEvent
decodeMouseEvent =
    Decode.map6 MouseEvent
        decodeContainer
        (Decode.field "clientX" Decode.float)
        (Decode.field "clientY" Decode.float)
        (Decode.field "pageX" Decode.float)
        (Decode.field "pageY" Decode.float)
        (Decode.field "button" Decode.int)


drawingScale : ViewBox -> DOM.Rectangle -> Float
drawingScale viewBox container =
    let
        ( drawingWidth, drawingHeight ) =
            BoundingBox2d.dimensions viewBox

        xScale =
            container.width / inPixels drawingWidth

        yScale =
            container.height / inPixels drawingHeight
    in
    min xScale yScale


toDrawingPoint : ViewBox -> MouseEvent -> Point2d Pixels DrawingCoordinates
toDrawingPoint viewBox event =
    let
        scale =
            drawingScale viewBox event.container

        containerMidX =
            event.container.left + event.container.width / 2

        containerMidY =
            event.container.top + event.container.height / 2

        containerDeltaX =
            event.clientX - containerMidX

        containerDeltaY =
            event.clientY - containerMidY

        drawingDeltaX =
            pixels (containerDeltaX / scale)

        drawingDeltaY =
            pixels (-containerDeltaY / scale)
    in
    BoundingBox2d.centerPoint viewBox
        |> Point2d.translateBy (Vector2d.xy drawingDeltaX drawingDeltaY)


futurePointDecoder : Int -> MouseEvent -> Point2d Pixels DrawingCoordinates -> Float -> Decoder (Point2d Pixels DrawingCoordinates)
futurePointDecoder whichButton initialMouseEvent initialPoint scale =
    Decode.field "type" Decode.string
        |> Decode.andThen
            (\eventType ->
                if eventType == "mouseup" then
                    -- For mouse up events, only succeed decoding (fire a
                    -- message) if the button released is the one that was
                    -- initially pressed down; this makes using this decoder
                    -- more reliable when used with mouse up events to end a
                    -- drag operation or similar
                    Decode.field "button" Decode.int
                        |> Decode.andThen
                            (\button ->
                                if button == whichButton then
                                    decodeFuturePosition initialMouseEvent initialPoint scale

                                else
                                    wrongButton
                            )

                else
                    -- For all other events such as move events, just always
                    -- succeed (move events don't have a reliable 'button'
                    -- field anyways, and the 'buttons' field is not supported
                    -- cross browser - besides, people should be ending any
                    -- move subscriptions by listening to mouse up events)
                    decodeFuturePosition initialMouseEvent initialPoint scale
            )


decodeFuturePosition : MouseEvent -> Point2d Pixels DrawingCoordinates -> Float -> Decoder (Point2d Pixels DrawingCoordinates)
decodeFuturePosition initialMouseEvent initialPoint scale =
    Decode.map2
        (\pageX pageY ->
            let
                displacement =
                    Vector2d.pixels
                        ((pageX - initialMouseEvent.pageX) / scale)
                        ((initialMouseEvent.pageY - pageY) / scale)
            in
            initialPoint |> Point2d.translateBy displacement
        )
        (Decode.field "pageX" Decode.float)
        (Decode.field "pageY" Decode.float)


handleMouseDown : Int -> ViewBox -> DownHandler msg -> Decoder msg
handleMouseDown whichButton viewBox toMessage =
    decodeMouseEvent
        |> Decode.andThen (processMouseDown whichButton viewBox toMessage)


wrongButton : Decoder msg
wrongButton =
    Decode.fail "Ignoring non-matching button"


processMouseDown : Int -> ViewBox -> DownHandler msg -> MouseEvent -> Decoder msg
processMouseDown whichButton viewBox toMessage mouseEvent =
    if Debug.log "mouseEvent.button" mouseEvent.button == Debug.log "whichButton" whichButton then
        let
            point =
                toDrawingPoint viewBox mouseEvent

            scale =
                drawingScale viewBox mouseEvent.container
        in
        Decode.succeed (toMessage point (futurePointDecoder whichButton mouseEvent point scale))

    else
        wrongButton


processMouseUp : Int -> ViewBox -> UpHandler msg -> MouseEvent -> Decoder msg
processMouseUp whichButton viewBox toMessage mouseEvent =
    if mouseEvent.button == whichButton then
        Decode.succeed (toMessage (toDrawingPoint viewBox mouseEvent))

    else
        wrongButton


handleMouseUp : Int -> ViewBox -> UpHandler msg -> Decoder { message : msg, preventDefault : Bool, stopPropagation : Bool }
handleMouseUp whichButton viewBox toMessage =
    decodeMouseEvent
        |> Decode.andThen (processMouseUp whichButton viewBox toMessage)
        |> Decode.map
            (\message -> { message = message, preventDefault = True, stopPropagation = True })


handleMouseClick : ViewBox -> ClickHandler msg -> Decoder msg
handleMouseClick viewBox toMessage =
    decodeMouseEvent
        |> Decode.map (toDrawingPoint viewBox)
        |> Decode.map toMessage


fit : Size
fit =
    Fit


fitWidth : Size
fitWidth =
    FitWidth


fixed : Size
fixed =
    Fixed


empty : Element units coordinates msg
empty =
    Element (\_ _ _ _ _ _ _ _ _ _ -> Svg.text "")


drawCurve :
    List (Attribute units coordinates msg)
    -> (List (Svg.Attribute msg) -> a -> Svg msg)
    -> a
    -> Element units coordinates msg
drawCurve attributes toSvg curve =
    let
        attributeValues =
            collectAttributeValues attributes
    in
    Element <|
        \_ _ _ _ _ _ viewMinX viewMaxX viewMinY viewMaxY ->
            let
                givenAttributes =
                    []
                        |> addStrokeStyle attributeValues
                        |> addStrokeWidth attributeValues
                        |> addEventHandlers
                            viewMinX
                            viewMaxX
                            viewMinY
                            viewMaxY
                            attributeValues

                svgAttributes =
                    Svg.Attributes.fill "none" :: givenAttributes

                curveElement =
                    toSvg svgAttributes curve

                gradientElements =
                    [] |> addStrokeGradient attributeValues
            in
            case gradientElements of
                [] ->
                    curveElement

                _ ->
                    Svg.g []
                        [ Svg.defs [] gradientElements
                        , curveElement
                        ]


drawRegion :
    List (Attribute units coordinates msg)
    -> (List (Svg.Attribute msg) -> a -> Svg msg)
    -> a
    -> Element units coordinates msg
drawRegion attributes toSvg region =
    let
        attributeValues =
            collectAttributeValues attributes
    in
    Element <|
        \currentBordersVisible _ _ _ _ _ viewMinX viewMaxX viewMinY viewMaxY ->
            let
                commonAttributes =
                    []
                        |> addFillStyle attributeValues
                        |> addEventHandlers
                            viewMinX
                            viewMaxX
                            viewMinY
                            viewMaxY
                            attributeValues

                fillGradientElement =
                    [] |> addFillGradient attributeValues

                bordersVisible =
                    attributeValues.borderVisibility
                        |> Maybe.withDefault currentBordersVisible

                svgAttributes =
                    if bordersVisible then
                        commonAttributes
                            |> addStrokeStyle attributeValues
                            |> addStrokeWidth attributeValues

                    else
                        Svg.Attributes.stroke "none" :: commonAttributes

                regionElement =
                    toSvg svgAttributes region

                gradientElements =
                    if bordersVisible then
                        fillGradientElement
                            |> addStrokeGradient attributeValues

                    else
                        fillGradientElement
            in
            case gradientElements of
                [] ->
                    regionElement

                _ ->
                    Svg.g []
                        [ Svg.defs [] gradientElements
                        , regionElement
                        ]


lineSegment : List (Attribute units coordinates msg) -> LineSegment2d units coordinates -> Element units coordinates msg
lineSegment attributes givenSegment =
    drawCurve attributes Svg.lineSegment2d givenSegment


triangle : List (Attribute units coordinates msg) -> Triangle2d units coordinates -> Element units coordinates msg
triangle attributes givenTriangle =
    drawRegion attributes Svg.triangle2d givenTriangle


render : Bool -> Float -> Float -> Float -> String -> String -> Float -> Float -> Float -> Float -> Element units coordinates msg -> Svg msg
render bordersVisible pixelSize strokeWidth fontSize gradientFill gradientStroke viewMinX viewMaxX viewMinY viewMaxY (Element function) =
    function bordersVisible pixelSize strokeWidth fontSize gradientFill gradientStroke viewMinX viewMaxX viewMinY viewMaxY


with : List (Attribute units coordinates msg) -> Element units coordinates msg -> Element units coordinates msg
with attributes element =
    group attributes [ element ]


group : List (Attribute units coordinates msg) -> List (Element units coordinates msg) -> Element units coordinates msg
group attributes childElements =
    let
        attributeValues =
            collectAttributeValues attributes
    in
    Element <|
        \currentBordersVisible currentPixelSize currentStrokeWidth currentFontSize currentFillGradient currentStrokeGradient viewMinX viewMaxX viewMinY viewMaxY ->
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
                            encodeGradient gradient

                updatedStrokeGradient =
                    case attributeValues.strokeStyle of
                        Nothing ->
                            currentStrokeGradient

                        Just (StrokeColor _) ->
                            ""

                        Just (StrokeGradient gradient) ->
                            encodeGradient gradient

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
                                viewMinX
                                viewMaxX
                                viewMinY
                                viewMaxY
                            )

                gradientElements =
                    []
                        |> addStrokeGradient attributeValues
                        |> addFillGradient attributeValues

                groupAttributes =
                    []
                        |> addFillStyle attributeValues
                        |> addFontFamily attributeValues
                        |> addFontSize attributeValues
                        |> addStrokeStyle attributeValues
                        |> addStrokeWidth attributeValues
                        |> addTextAnchor attributeValues
                        |> addTextColor attributeValues
                        |> addEventHandlers
                            viewMinY
                            viewMaxX
                            viewMinY
                            viewMaxY
                            attributeValues

                groupSvgElement =
                    Svg.g groupAttributes childSvgElements
            in
            case gradientElements of
                [] ->
                    groupSvgElement

                _ ->
                    Svg.g []
                        [ Svg.defs [] gradientElements
                        , groupSvgElement
                        ]


arc : List (Attribute units coordinates msg) -> Arc2d units coordinates -> Element units coordinates msg
arc attributes givenArc =
    drawCurve attributes Svg.arc2d givenArc


quadraticSpline : List (Attribute units coordinates msg) -> QuadraticSpline2d units coordinates -> Element units coordinates msg
quadraticSpline attributes givenSpline =
    drawCurve attributes Svg.quadraticSpline2d givenSpline


cubicSpline : List (Attribute units coordinates msg) -> CubicSpline2d units coordinates -> Element units coordinates msg
cubicSpline attributes givenSpline =
    drawCurve attributes Svg.cubicSpline2d givenSpline


polyline : List (Attribute units coordinates msg) -> Polyline2d units coordinates -> Element units coordinates msg
polyline attributes givenPolyline =
    drawCurve attributes Svg.polyline2d givenPolyline


polygon : List (Attribute units coordinates msg) -> Polygon2d units coordinates -> Element units coordinates msg
polygon attributes givenPolygon =
    drawRegion attributes Svg.polygon2d givenPolygon


circle : List (Attribute units coordinates msg) -> Circle2d units coordinates -> Element units coordinates msg
circle attributes givenCircle =
    drawRegion attributes Svg.circle2d givenCircle


ellipticalArc : List (Attribute units coordinates msg) -> EllipticalArc2d units coordinates -> Element units coordinates msg
ellipticalArc attributes givenArc =
    drawCurve attributes Svg.ellipticalArc2d givenArc


ellipse : List (Attribute units coordinates msg) -> Ellipse2d units coordinates -> Element units coordinates msg
ellipse attributes givenEllipse =
    drawRegion attributes Svg.ellipse2d givenEllipse


rectangle : List (Attribute units coordinates msg) -> Rectangle2d units coordinates -> Element units coordinates msg
rectangle attributes givenRectangle =
    drawRegion attributes Svg.rectangle2d givenRectangle


text : List (Attribute units coordinates msg) -> Point2d units coordinates -> String -> Element units coordinates msg
text attributes position string =
    let
        attributeValues =
            collectAttributeValues attributes

        { x, y } =
            Point2d.unwrap position
    in
    Element <|
        \_ _ _ _ _ _ viewMinX viewMaxX viewMinY viewMaxY ->
            let
                svgAttributes =
                    [ Svg.Attributes.x (String.fromFloat x)
                    , Svg.Attributes.y (String.fromFloat -y)
                    , Svg.Attributes.fill "currentColor"
                    , Svg.Attributes.stroke "none"
                    ]
                        |> addFontFamily attributeValues
                        |> addFontSize attributeValues
                        |> addTextAnchor attributeValues
                        |> addTextColor attributeValues
                        |> addEventHandlers
                            viewMinX
                            viewMaxX
                            viewMinY
                            viewMaxY
                            attributeValues
            in
            Svg.text_ svgAttributes [ Svg.text string ]


image : List (Attribute units coordinates msg) -> String -> Rectangle2d units coordinates -> Element units coordinates msg
image attributes givenUrl givenRectangle =
    let
        attributeValues =
            collectAttributeValues attributes

        ( Quantity width, Quantity height ) =
            Rectangle2d.dimensions givenRectangle
    in
    Element <|
        \_ _ _ _ _ _ viewMinX viewMaxX viewMinY viewMaxY ->
            let
                svgAttributes =
                    [ Svg.Attributes.xlinkHref givenUrl
                    , Svg.Attributes.x (String.fromFloat (-width / 2))
                    , Svg.Attributes.y (String.fromFloat (-height / 2))
                    , Svg.Attributes.width (String.fromFloat width)
                    , Svg.Attributes.height (String.fromFloat height)
                    , placementTransform (Rectangle2d.axes givenRectangle)
                    ]
                        |> addEventHandlers
                            viewMinX
                            viewMaxX
                            viewMinY
                            viewMaxY
                            attributeValues
            in
            Svg.image svgAttributes []


placementTransform : Frame2d units coordinates defines -> Svg.Attribute msg
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
    -> Element units localCoordinates msg
    -> Element units globalCoordinates msg
placeIn frame (Element function) =
    Element
        (\currentBordersVisible currentPixelSize currentStrokeWidth currentFontSize currentFillGradient currentStrokeGradient viewMinX viewMaxX viewMinY viewMaxY ->
            let
                toLocalGradient =
                    Gradient.relativeTo frame

                localFillGradient =
                    decodeGradient currentFillGradient
                        |> Maybe.map toLocalGradient

                localStrokeGradient =
                    decodeGradient currentStrokeGradient
                        |> Maybe.map toLocalGradient

                updatedFillGradient =
                    localFillGradient
                        |> Maybe.map encodeGradient
                        |> Maybe.withDefault ""

                updatedStrokeGradient =
                    localStrokeGradient
                        |> Maybe.map encodeGradient
                        |> Maybe.withDefault ""

                localGradientReferences =
                    []
                        |> addTransformedFillGradientReference
                            localFillGradient
                        |> addTransformedStrokeGradientReference
                            localStrokeGradient

                localGradientElements =
                    []
                        |> addGradientElement localFillGradient
                        |> addGradientElement localStrokeGradient

                localSvgElement =
                    function
                        currentBordersVisible
                        currentPixelSize
                        currentStrokeWidth
                        currentFontSize
                        updatedFillGradient
                        updatedStrokeGradient
                        viewMinX
                        viewMaxX
                        viewMinY
                        viewMaxY

                localElement =
                    case localGradientElements of
                        [] ->
                            localSvgElement

                        _ ->
                            Svg.g localGradientReferences
                                [ Svg.defs [] localGradientElements
                                , localSvgElement
                                ]
            in
            Svg.g [ placementTransform frame ] [ localElement ]
        )


scaleAbout : Point2d units coordinates -> Float -> Element units coordinates msg -> Element units coordinates msg
scaleAbout point scale element =
    scaleImpl point scale element


scaleImpl : Point2d units1 coordinates -> Float -> Element units1 coordinates msg -> Element units2 coordinates msg
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
        (\currentBordersVisible currentPixelSize currentStrokeWidth currentFontSize currentFillGradient currentStrokeGradient viewMinX viewMaxX viewMinY viewMaxY ->
            let
                transformation =
                    Gradient.scaleAbout point (1 / scale)

                transformedFillGradient =
                    decodeGradient currentFillGradient
                        |> Maybe.map transformation

                transformedStrokeGradient =
                    decodeGradient currentStrokeGradient
                        |> Maybe.map transformation

                updatedFillGradient =
                    transformedFillGradient
                        |> Maybe.map encodeGradient
                        |> Maybe.withDefault ""

                updatedStrokeGradient =
                    transformedStrokeGradient
                        |> Maybe.map encodeGradient
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
                        |> addGradientElement transformedFillGradient
                        |> addGradientElement transformedStrokeGradient

                childSvgElement =
                    function
                        currentBordersVisible
                        updatedPixelSize
                        updatedStrokeWidth
                        updatedFontSize
                        updatedFillGradient
                        updatedStrokeGradient
                        viewMinX
                        viewMaxX
                        viewMinY
                        viewMaxY

                groupElement =
                    case transformedGradientElements of
                        [] ->
                            Svg.g svgAttributes [ childSvgElement ]

                        _ ->
                            Svg.g svgAttributes
                                [ Svg.defs [] transformedGradientElements
                                , childSvgElement
                                ]
            in
            groupElement
        )


relativeTo : Frame2d units globalCoordinates { defines : localCoordinates } -> Element units globalCoordinates msg -> Element units localCoordinates msg
relativeTo frame element =
    element |> placeIn (Frame2d.atOrigin |> Frame2d.relativeTo frame)


translateBy : Vector2d units coordinates -> Element units coordinates msg -> Element units coordinates msg
translateBy displacement element =
    element |> placeIn (Frame2d.atOrigin |> Frame2d.translateBy displacement)


translateIn : Direction2d coordinates -> Quantity Float units -> Element units coordinates msg -> Element units coordinates msg
translateIn direction distance element =
    element |> translateBy (Vector2d.withLength distance direction)


rotateAround : Point2d units coordinates -> Angle -> Element units coordinates msg -> Element units coordinates msg
rotateAround centerPoint angle element =
    element
        |> placeIn (Frame2d.atOrigin |> Frame2d.rotateAround centerPoint angle)


mirrorAcross : Axis2d units coordinates -> Element units coordinates msg -> Element units coordinates msg
mirrorAcross axis element =
    element |> placeIn (Frame2d.atOrigin |> Frame2d.mirrorAcross axis)


at : Quantity Float (Rate units2 units1) -> Element units1 coordinates msg -> Element units2 coordinates msg
at rate element =
    let
        (Quantity scale) =
            rate
    in
    scaleImpl Point2d.origin scale element


at_ : Quantity Float (Rate units1 units2) -> Element units1 coordinates msg -> Element units2 coordinates msg
at_ rate element =
    let
        (Quantity scale) =
            rate
    in
    scaleImpl Point2d.origin (1 / scale) element


map : (a -> b) -> Element units coordinates a -> Element units coordinates b
map mapFunction (Element drawFunction) =
    Element
        (\arg1 arg2 arg3 arg4 arg5 arg6 arg7 arg8 arg9 arg10 ->
            Svg.map mapFunction (drawFunction arg1 arg2 arg3 arg4 arg5 arg6 arg7 arg8 arg9 arg10)
        )



----- GRADIENTS -----


encodeGradient : Gradient units coordinates -> String
encodeGradient gradient =
    Encode.encode 0 <|
        case gradient of
            LinearGradient linearGradient ->
                let
                    p1 =
                        Point2d.unwrap linearGradient.start

                    p2 =
                        Point2d.unwrap linearGradient.end
                in
                Encode.list identity
                    [ Encode.string "lg"
                    , Encode.float p1.x
                    , Encode.float p1.y
                    , Encode.float p2.x
                    , Encode.float p2.y
                    , Encode.string (Stops.id linearGradient.stops)
                    ]

            RadialGradient radialGradient ->
                let
                    f =
                        Point2d.unwrap radialGradient.start

                    c =
                        Point2d.unwrap (Circle2d.centerPoint radialGradient.end)

                    (Quantity r) =
                        Circle2d.radius radialGradient.end
                in
                Encode.list identity
                    [ Encode.string "rg"
                    , Encode.float f.x
                    , Encode.float f.y
                    , Encode.float c.x
                    , Encode.float c.y
                    , Encode.float r
                    , Encode.string (Stops.id radialGradient.stops)
                    ]


gradientDecoder : Decoder (Maybe (Gradient units coordinates))
gradientDecoder =
    Decode.nullable
        (Decode.index 0 Decode.string
            |> Decode.andThen
                (\tag ->
                    case tag of
                        "lg" ->
                            Decode.map5 rebuildLinearGradient
                                (Decode.index 1 Decode.float)
                                (Decode.index 2 Decode.float)
                                (Decode.index 3 Decode.float)
                                (Decode.index 4 Decode.float)
                                (Decode.index 5 Decode.string)

                        "rg" ->
                            Decode.map6 rebuildRadialGradient
                                (Decode.index 1 Decode.float)
                                (Decode.index 2 Decode.float)
                                (Decode.index 3 Decode.float)
                                (Decode.index 4 Decode.float)
                                (Decode.index 5 Decode.float)
                                (Decode.index 6 Decode.string)

                        _ ->
                            Decode.fail ("Unexpected tag '" ++ tag ++ "'")
                )
        )


rebuildLinearGradient : Float -> Float -> Float -> Float -> String -> Gradient units coordinates
rebuildLinearGradient x1 y1 x2 y2 stopsId =
    LinearGradient
        { id = ""
        , start = Point2d.unsafe { x = x1, y = y1 }
        , end = Point2d.unsafe { x = x2, y = y2 }
        , stops = StopsReference stopsId
        }


rebuildRadialGradient : Float -> Float -> Float -> Float -> Float -> String -> Gradient units coordinates
rebuildRadialGradient fx fy cx cy r stopsId =
    RadialGradient
        { id = ""
        , start = Point2d.unsafe { x = fx, y = fy }
        , end =
            Circle2d.withRadius (Quantity r) (Point2d.unsafe { x = cx, y = cy })
        , stops = StopsReference stopsId
        }


decodeGradient : String -> Maybe (Gradient units coordinates)
decodeGradient string =
    if String.isEmpty string then
        Nothing

    else
        Decode.decodeString gradientDecoder string
            |> Result.withDefault Nothing


addGradientElements : Gradient units coordinates -> List (Svg msg) -> List (Svg msg)
addGradientElements gradient svgElements =
    case gradient of
        LinearGradient linearGradient ->
            let
                p1 =
                    Point2d.unwrap linearGradient.start

                p2 =
                    Point2d.unwrap linearGradient.end

                stopsId =
                    Stops.id linearGradient.stops

                gradientElement =
                    Svg.linearGradient
                        [ Svg.Attributes.id linearGradient.id
                        , Svg.Attributes.x1 (String.fromFloat p1.x)
                        , Svg.Attributes.y1 (String.fromFloat -p1.y)
                        , Svg.Attributes.x2 (String.fromFloat p2.x)
                        , Svg.Attributes.y2 (String.fromFloat -p2.y)
                        , Svg.Attributes.gradientUnits "userSpaceOnUse"
                        , Svg.Attributes.xlinkHref ("#" ++ stopsId)
                        ]
                        []
            in
            case linearGradient.stops of
                StopValues _ stopValues ->
                    let
                        stopsElement =
                            Svg.linearGradient [ Svg.Attributes.id stopsId ]
                                (List.map stopElement stopValues)
                    in
                    stopsElement :: gradientElement :: svgElements

                StopsReference _ ->
                    gradientElement :: svgElements

        RadialGradient radialGradient ->
            let
                f =
                    Point2d.unwrap radialGradient.start

                c =
                    Point2d.unwrap (Circle2d.centerPoint radialGradient.end)

                (Quantity r) =
                    Circle2d.radius radialGradient.end

                stopsId =
                    Stops.id radialGradient.stops

                gradientElement =
                    Svg.radialGradient
                        [ Svg.Attributes.id radialGradient.id
                        , Svg.Attributes.fx (String.fromFloat f.x)
                        , Svg.Attributes.fy (String.fromFloat -f.y)
                        , Svg.Attributes.cx (String.fromFloat c.x)
                        , Svg.Attributes.cy (String.fromFloat -c.y)
                        , Svg.Attributes.r (String.fromFloat r)
                        , Svg.Attributes.gradientUnits "userSpaceOnUse"
                        , Svg.Attributes.xlinkHref ("#" ++ stopsId)
                        ]
                        []
            in
            case radialGradient.stops of
                StopValues _ stopValues ->
                    let
                        stopsElement =
                            Svg.radialGradient [ Svg.Attributes.id stopsId ]
                                (List.map stopElement stopValues)
                    in
                    stopsElement :: gradientElement :: svgElements

                StopsReference _ ->
                    gradientElement :: svgElements


stopElement : Stop -> Svg msg
stopElement { offset, color } =
    Svg.stop
        [ Svg.Attributes.offset offset
        , Svg.Attributes.stopColor color
        ]
        []


gradientReference : Gradient units coordinates -> String
gradientReference gradient =
    let
        gradientId =
            case gradient of
                LinearGradient { id } ->
                    id

                RadialGradient { id } ->
                    id
    in
    "url(#" ++ gradientId ++ ")"


transformEncoded : String -> (Gradient units coordinates1 -> Gradient units coordinates2) -> String
transformEncoded gradient function =
    if gradient == "" then
        gradient

    else
        case decodeGradient gradient of
            Just decoded ->
                encodeGradient (function decoded)

            Nothing ->
                ""



----- ATTRIBUTES -----


type alias AttributeValues units coordinates msg =
    { fillStyle : Maybe (Fill units coordinates)
    , strokeStyle : Maybe (Stroke units coordinates)
    , fontSize : Maybe Float
    , strokeWidth : Maybe Float
    , borderVisibility : Maybe Bool
    , textColor : Maybe String
    , fontFamily : Maybe String
    , textAnchor : Maybe { x : String, y : String }
    , onLeftClick : Maybe (ClickHandler msg)
    , onLeftMouseDown : Maybe (DownHandler msg)
    , onMiddleMouseDown : Maybe (DownHandler msg)
    , onRightMouseDown : Maybe (DownHandler msg)
    , onLeftMouseUp : Maybe (UpHandler msg)
    , onMiddleMouseUp : Maybe (UpHandler msg)
    , onRightMouseUp : Maybe (UpHandler msg)
    }


setAttribute : Attribute units coordinates msg -> AttributeValues units coordinates msg -> AttributeValues units coordinates msg
setAttribute attribute attributeValues =
    case attribute of
        FillStyle fill ->
            { attributeValues | fillStyle = Just fill }

        StrokeStyle stroke ->
            { attributeValues | strokeStyle = Just stroke }

        FontSize size ->
            { attributeValues | fontSize = Just size }

        StrokeWidth width ->
            { attributeValues | strokeWidth = Just width }

        BorderVisibility bordersVisible ->
            { attributeValues | borderVisibility = Just bordersVisible }

        TextColor string ->
            { attributeValues | textColor = Just string }

        FontFamily string ->
            { attributeValues | fontFamily = Just string }

        TextAnchor position ->
            { attributeValues | textAnchor = Just position }

        OnLeftClick toMessage ->
            { attributeValues | onLeftClick = Just toMessage }

        OnLeftMouseDown toMessage ->
            { attributeValues | onLeftMouseDown = Just toMessage }

        OnMiddleMouseDown toMessage ->
            { attributeValues | onMiddleMouseDown = Just toMessage }

        OnRightMouseDown toMessage ->
            { attributeValues | onRightMouseDown = Just toMessage }

        OnLeftMouseUp toMessage ->
            { attributeValues | onLeftMouseUp = Just toMessage }

        OnMiddleMouseUp toMessage ->
            { attributeValues | onMiddleMouseUp = Just toMessage }

        OnRightMouseUp toMessage ->
            { attributeValues | onRightMouseUp = Just toMessage }


initialAttributeValues : AttributeValues units coordinates msg
initialAttributeValues =
    { fillStyle = Nothing
    , strokeStyle = Nothing
    , fontSize = Nothing
    , strokeWidth = Nothing
    , borderVisibility = Nothing
    , textColor = Nothing
    , fontFamily = Nothing
    , textAnchor = Nothing
    , onLeftClick = Nothing
    , onLeftMouseDown = Nothing
    , onMiddleMouseDown = Nothing
    , onRightMouseDown = Nothing
    , onLeftMouseUp = Nothing
    , onMiddleMouseUp = Nothing
    , onRightMouseUp = Nothing
    }


collectAttributeValues : List (Attribute units coordinates msg) -> AttributeValues units coordinates msg
collectAttributeValues attributeList =
    List.foldr setAttribute initialAttributeValues attributeList


addFillStyle : AttributeValues units coordinates msg -> List (Svg.Attribute msg) -> List (Svg.Attribute msg)
addFillStyle attributeValues svgAttributes =
    case attributeValues.fillStyle of
        Nothing ->
            svgAttributes

        Just NoFill ->
            Svg.Attributes.fill "none" :: svgAttributes

        Just (FillColor string) ->
            Svg.Attributes.fill string :: svgAttributes

        Just (FillGradient gradient) ->
            Svg.Attributes.fill (gradientReference gradient) :: svgAttributes


addStrokeStyle : AttributeValues units coordinates msg -> List (Svg.Attribute msg) -> List (Svg.Attribute msg)
addStrokeStyle attributeValues svgAttributes =
    case attributeValues.strokeStyle of
        Nothing ->
            svgAttributes

        Just (StrokeColor string) ->
            Svg.Attributes.stroke string :: svgAttributes

        Just (StrokeGradient gradient) ->
            Svg.Attributes.stroke (gradientReference gradient) :: svgAttributes


addFontSize : AttributeValues units coordinates msg -> List (Svg.Attribute msg) -> List (Svg.Attribute msg)
addFontSize attributeValues svgAttributes =
    case attributeValues.fontSize of
        Nothing ->
            svgAttributes

        Just size ->
            Svg.Attributes.fontSize (String.fromFloat size) :: svgAttributes


addStrokeWidth : AttributeValues units coordinates msg -> List (Svg.Attribute msg) -> List (Svg.Attribute msg)
addStrokeWidth attributeValues svgAttributes =
    case attributeValues.strokeWidth of
        Nothing ->
            svgAttributes

        Just width ->
            Svg.Attributes.strokeWidth (String.fromFloat width) :: svgAttributes


addTextColor : AttributeValues units coordinates msg -> List (Svg.Attribute msg) -> List (Svg.Attribute msg)
addTextColor attributeValues svgAttributes =
    case attributeValues.textColor of
        Nothing ->
            svgAttributes

        Just string ->
            Svg.Attributes.color string :: svgAttributes


addFontFamily : AttributeValues units coordinates msg -> List (Svg.Attribute msg) -> List (Svg.Attribute msg)
addFontFamily attributeValues svgAttributes =
    case attributeValues.fontFamily of
        Nothing ->
            svgAttributes

        Just string ->
            Svg.Attributes.fontFamily string :: svgAttributes


addTextAnchor : AttributeValues units coordinates msg -> List (Svg.Attribute msg) -> List (Svg.Attribute msg)
addTextAnchor attributeValues svgAttributes =
    case attributeValues.textAnchor of
        Nothing ->
            svgAttributes

        Just position ->
            Svg.Attributes.textAnchor position.x
                :: Svg.Attributes.dominantBaseline position.y
                :: svgAttributes


leftButton : Int
leftButton =
    0


middleButton : Int
middleButton =
    1


rightButton : Int
rightButton =
    2


addEventHandlers : Float -> Float -> Float -> Float -> AttributeValues units coordinates msg -> List (Svg.Attribute msg) -> List (Svg.Attribute msg)
addEventHandlers viewMinX viewMaxX viewMinY viewMaxY attributeValues svgAttributes =
    svgAttributes
        |> addOnLeftClick viewMinX viewMaxX viewMinY viewMaxY attributeValues.onLeftClick
        |> addOnMouseDown leftButton viewMinX viewMaxX viewMinY viewMaxY attributeValues.onLeftMouseDown
        |> addOnMouseDown middleButton viewMinX viewMaxX viewMinY viewMaxY attributeValues.onMiddleMouseDown
        |> addOnMouseDown rightButton viewMinX viewMaxX viewMinY viewMaxY attributeValues.onRightMouseDown
        |> addOnMouseUp leftButton viewMinX viewMaxX viewMinY viewMaxY attributeValues.onLeftMouseUp
        |> addOnMouseUp middleButton viewMinX viewMaxX viewMinY viewMaxY attributeValues.onMiddleMouseUp
        |> addOnMouseUp rightButton viewMinX viewMaxX viewMinY viewMaxY attributeValues.onRightMouseUp


addOnLeftClick : Float -> Float -> Float -> Float -> Maybe (ClickHandler msg) -> List (Svg.Attribute msg) -> List (Svg.Attribute msg)
addOnLeftClick viewMinX viewMaxX viewMinY viewMaxY registeredHandler svgAttributes =
    case registeredHandler of
        Nothing ->
            svgAttributes

        Just toMessage ->
            let
                viewBox =
                    BoundingBox2d.fromExtrema
                        { minX = pixels viewMinX
                        , maxX = pixels viewMaxX
                        , minY = pixels viewMinY
                        , maxY = pixels viewMaxY
                        }

                clickHandler =
                    Svg.Events.on "click" (handleMouseClick viewBox toMessage)
            in
            clickHandler :: svgAttributes


addOnMouseDown : Int -> Float -> Float -> Float -> Float -> Maybe (DownHandler msg) -> List (Svg.Attribute msg) -> List (Svg.Attribute msg)
addOnMouseDown whichButton viewMinX viewMaxX viewMinY viewMaxY registeredHandler svgAttributes =
    case registeredHandler of
        Nothing ->
            svgAttributes

        Just toMessage ->
            let
                viewBox =
                    BoundingBox2d.fromExtrema
                        { minX = pixels viewMinX
                        , maxX = pixels viewMaxX
                        , minY = pixels viewMinY
                        , maxY = pixels viewMaxY
                        }
            in
            Svg.Events.on "mousedown" (handleMouseDown whichButton viewBox toMessage)
                :: svgAttributes


addOnMouseUp : Int -> Float -> Float -> Float -> Float -> Maybe (UpHandler msg) -> List (Svg.Attribute msg) -> List (Svg.Attribute msg)
addOnMouseUp whichButton viewMinX viewMaxX viewMinY viewMaxY registeredHandler svgAttributes =
    case registeredHandler of
        Nothing ->
            svgAttributes

        Just toMessage ->
            let
                viewBox =
                    BoundingBox2d.fromExtrema
                        { minX = pixels viewMinX
                        , maxX = pixels viewMaxX
                        , minY = pixels viewMinY
                        , maxY = pixels viewMaxY
                        }
            in
            svgOnMouseUp whichButton viewBox toMessage :: svgAttributes


svgOnMouseUp : Int -> ViewBox -> UpHandler msg -> Svg.Attribute msg
svgOnMouseUp whichButton viewBox toMessage =
    let
        -- This is a bit of a hack to allow context menus to be
        -- suppressed on right mouse clicks; preventing default on a
        -- right button 'mouseup' event doesn't seem to prevent a
        -- context menu from being created, and releasing the right
        -- mouse button over a specific element reliably seems to
        -- trigger the 'contextmenu' event (even if, for example, the
        -- right mouse button is pressed elsewhere and then the cursor
        -- is moved over the element) so it seems safe to treat the two
        -- as largely interchangeable other than the effect on context
        -- menu creation
        whichEvent =
            if whichButton == rightButton then
                "contextmenu"

            else
                "mouseup"
    in
    Svg.Events.custom whichEvent (handleMouseUp whichButton viewBox toMessage)


addStrokeGradient : AttributeValues units coordinates msg -> List (Svg msg) -> List (Svg msg)
addStrokeGradient attributeValues svgElements =
    case attributeValues.strokeStyle of
        Nothing ->
            svgElements

        Just (StrokeColor _) ->
            svgElements

        Just (StrokeGradient gradient) ->
            addGradientElements gradient svgElements


addFillGradient : AttributeValues units coordinates msg -> List (Svg msg) -> List (Svg msg)
addFillGradient attributeValues svgElements =
    case attributeValues.fillStyle of
        Nothing ->
            svgElements

        Just NoFill ->
            svgElements

        Just (FillColor _) ->
            svgElements

        Just (FillGradient gradient) ->
            addGradientElements gradient svgElements


addGradientElement : Maybe (Gradient units coordinates) -> List (Svg msg) -> List (Svg msg)
addGradientElement maybeGradient svgElements =
    case maybeGradient of
        Nothing ->
            svgElements

        Just gradient ->
            addGradientElements gradient svgElements


addTransformedFillGradientReference : Maybe (Gradient units gradientCoordinates) -> List (Svg.Attribute msg) -> List (Svg.Attribute msg)
addTransformedFillGradientReference maybeGradient svgAttributes =
    case maybeGradient of
        Nothing ->
            svgAttributes

        Just gradient ->
            Svg.Attributes.fill (gradientReference gradient) :: svgAttributes


addTransformedStrokeGradientReference : Maybe (Gradient units gradientCoordinates) -> List (Svg.Attribute msg) -> List (Svg.Attribute msg)
addTransformedStrokeGradientReference maybeGradient svgAttributes =
    case maybeGradient of
        Nothing ->
            svgAttributes

        Just gradient ->
            Svg.Attributes.stroke (gradientReference gradient) :: svgAttributes
