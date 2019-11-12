module Drawing2d exposing
    ( Attribute
    , AttributeIn
    , Element
    , ElementIn
    , Size
    , add
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
    )

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
import Drawing2d.Gradient as Gradient
import Drawing2d.Stops as Stops
import Drawing2d.Svg as Svg
import Drawing2d.Text as Text
import Drawing2d.Types as Types exposing (AttributeIn(..), ClickDecoder, Fill(..), Gradient(..), MouseDownDecoder, MouseEvent, MouseInteraction(..), Stop, Stops(..), Stroke(..))
import Drawing2d.Utils exposing (decodeMouseEvent, drawingScale, toDrawingPoint, wrongButton)
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



---------- TYPES ----------


type Event drawingCoordinates msg
    = Event (BoundingBox2d Pixels drawingCoordinates -> msg)


type ElementIn units coordinates drawingCoordinates msg
    = Element
        (Bool -- borders visible
         -> Float -- pixel size in current units
         -> Float -- stroke width in current units
         -> Float -- font size in current units
         -> String -- encoded gradient fill in current units
         -> String -- encoded gradient stroke in current units
         -> Svg (Event drawingCoordinates msg)
        )


type alias Element drawingCoordinates msg =
    ElementIn Pixels drawingCoordinates drawingCoordinates msg


type Size
    = Fixed
    | Fit
    | FitWidth


type alias AttributeIn units coordinates drawingCoordinates msg =
    Types.AttributeIn units coordinates drawingCoordinates msg


type alias Attribute drawingCoordinates msg =
    AttributeIn Pixels drawingCoordinates drawingCoordinates msg


type alias AttributeValues units coordinates drawingCoordinates msg =
    { fillStyle : Maybe (Fill units coordinates)
    , strokeStyle : Maybe (Stroke units coordinates)
    , fontSize : Maybe Float
    , strokeWidth : Maybe Float
    , borderVisibility : Maybe Bool
    , textColor : Maybe String
    , fontFamily : Maybe String
    , textAnchor : Maybe { x : String, y : String }
    , onLeftClick : Maybe (ClickDecoder drawingCoordinates msg)
    , onRightClick : Maybe (ClickDecoder drawingCoordinates msg)
    , onLeftMouseDown : Maybe (MouseDownDecoder drawingCoordinates msg)
    , onMiddleMouseDown : Maybe (MouseDownDecoder drawingCoordinates msg)
    , onRightMouseDown : Maybe (MouseDownDecoder drawingCoordinates msg)
    , onLeftMouseUp : Maybe (Decoder msg)
    , onMiddleMouseUp : Maybe (Decoder msg)
    , onRightMouseUp : Maybe (Decoder msg)
    }


type alias Renderer a drawingCoordinates msg =
    List (Svg.Attribute (Event drawingCoordinates msg)) -> a -> Svg (Event drawingCoordinates msg)



---------- CONSTANTS ----------


emptyAttributeValues : AttributeValues units coordinates drawingCoordinates msg
emptyAttributeValues =
    { fillStyle = Nothing
    , strokeStyle = Nothing
    , fontSize = Nothing
    , strokeWidth = Nothing
    , borderVisibility = Nothing
    , textColor = Nothing
    , fontFamily = Nothing
    , textAnchor = Nothing
    , onLeftClick = Nothing
    , onRightClick = Nothing
    , onLeftMouseDown = Nothing
    , onMiddleMouseDown = Nothing
    , onRightMouseDown = Nothing
    , onLeftMouseUp = Nothing
    , onMiddleMouseUp = Nothing
    , onRightMouseUp = Nothing
    }


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


defaultAttributes : List (Attribute drawingCoordinates msg)
defaultAttributes =
    [ Attributes.blackStroke
    , Attributes.strokeWidth (pixels 1)
    , Attributes.whiteFill
    , Attributes.strokedBorder
    , Attributes.fontSize (pixels 20)
    , Attributes.textColor Color.black
    , Attributes.textAnchor Text.bottomLeft
    ]



---------- FUNCTIONS ----------


toHtml :
    { viewBox : BoundingBox2d Pixels drawingCoordinates
    , size : Size
    }
    -> List (Attribute drawingCoordinates msg)
    -> List (Element drawingCoordinates msg)
    -> Html msg
toHtml { viewBox, size } attributes elements =
    let
        ( viewBoxWidth, viewBoxHeight ) =
            BoundingBox2d.dimensions viewBox

        { minX, maxX, minY, maxY } =
            BoundingBox2d.extrema viewBox

        viewBoxAttribute =
            Svg.Attributes.viewBox <|
                String.join " "
                    [ String.fromFloat (inPixels minX)
                    , String.fromFloat -(inPixels maxY)
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
            emptyAttributeValues
                |> assignAttributes defaultAttributes
                |> assignAttributes attributes

        (Element svgElement) =
            groupLike "svg" (viewBoxAttribute :: svgStaticCss) rootAttributeValues elements
    in
    Html.div (containerStaticCss ++ containerSizeCss)
        [ svgElement False 1 0 0 "" "" |> Svg.map (\(Event callback) -> callback viewBox) ]


wrapClick : MouseEvent -> (Point2d Pixels drawingCoordinates -> msg) -> Event drawingCoordinates msg
wrapClick mouseEvent userCallback =
    Event (\viewBox -> userCallback (toDrawingPoint viewBox mouseEvent))


handleClick : ClickDecoder drawingCoordinates msg -> Decoder (Event drawingCoordinates msg)
handleClick givenDecoder =
    Decode.map2 wrapClick decodeMouseEvent givenDecoder


preventDefaultAndStopPropagation :
    Decoder msg
    -> Decoder { message : msg, preventDefault : Bool, stopPropagation : Bool }
preventDefaultAndStopPropagation =
    Decode.map (\message -> { message = message, preventDefault = True, stopPropagation = True })


wrapMouseDown :
    MouseEvent
    -> (Point2d Pixels drawingCoordinates -> MouseInteraction drawingCoordinates -> msg)
    -> Event drawingCoordinates msg
wrapMouseDown mouseEvent userCallback =
    Event
        (\viewBox ->
            let
                drawingPoint =
                    toDrawingPoint viewBox mouseEvent

                mouseInteraction =
                    MouseInteraction
                        { initialEvent = mouseEvent
                        , viewBox = viewBox
                        , drawingScale = drawingScale viewBox mouseEvent.container
                        , initialPoint = drawingPoint
                        }
            in
            userCallback drawingPoint mouseInteraction
        )


handleMouseDown :
    Dict Int (MouseDownDecoder drawingCoordinates msg)
    -> Decoder (Event drawingCoordinates msg)
handleMouseDown decodersByButton =
    decodeMouseEvent
        |> Decode.andThen
            (\mouseEvent ->
                case Dict.get mouseEvent.button decodersByButton of
                    Just registeredDecoder ->
                        Decode.map (wrapMouseDown mouseEvent) registeredDecoder

                    Nothing ->
                        wrongButton
            )


wrapMessage : msg -> Event drawingCoordinates msg
wrapMessage message =
    Event (always message)


handleMouseUp : Dict Int (Decoder msg) -> Decoder (Event drawingCoordinates msg)
handleMouseUp decodersByButton =
    decodeMouseEvent
        |> Decode.andThen
            (\mouseEvent ->
                case Dict.get mouseEvent.button decodersByButton of
                    Just givenDecoder ->
                        Decode.map wrapMessage givenDecoder

                    Nothing ->
                        wrongButton
            )


fit : Size
fit =
    Fit


fitWidth : Size
fitWidth =
    FitWidth


fixed : Size
fixed =
    Fixed


empty : ElementIn units coordinates drawingCoordinates msg
empty =
    Element (\_ _ _ _ _ _ -> Svg.text "")


drawCurve :
    List (AttributeIn units coordinates drawingCoordinates msg)
    -> Renderer curve drawingCoordinates msg
    -> curve
    -> ElementIn units coordinates drawingCoordinates msg
drawCurve attributes renderer curve =
    let
        attributeValues =
            collectAttributeValues attributes
    in
    Element <|
        \_ _ _ _ _ _ ->
            let
                givenAttributes =
                    []
                        |> addStrokeStyle attributeValues
                        |> addStrokeWidth attributeValues
                        |> addEventHandlers attributeValues

                svgAttributes =
                    Svg.Attributes.fill "none" :: givenAttributes

                curveElement =
                    renderer svgAttributes curve

                gradientElements =
                    addStrokeGradient attributeValues []
            in
            case gradientElements of
                [] ->
                    curveElement

                _ ->
                    Svg.g [] (curveElement :: gradientElements)


drawRegion :
    List (AttributeIn units coordinates drawingCoordinates msg)
    -> Renderer region drawingCoordinates msg
    -> region
    -> ElementIn units coordinates drawingCoordinates msg
drawRegion attributes renderer region =
    let
        attributeValues =
            collectAttributeValues attributes
    in
    Element <|
        \currentBordersVisible _ _ _ _ _ ->
            let
                commonAttributes =
                    []
                        |> addFillStyle attributeValues
                        |> addEventHandlers attributeValues

                fillGradientElement =
                    addFillGradient attributeValues []

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
                    renderer svgAttributes region

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
                    Svg.g [] (regionElement :: gradientElements)


lineSegment :
    List (AttributeIn units coordinates drawingCoordinates msg)
    -> LineSegment2d units coordinates
    -> ElementIn units coordinates drawingCoordinates msg
lineSegment attributes givenSegment =
    drawCurve attributes Svg.lineSegment2d givenSegment


triangle :
    List (AttributeIn units coordinates drawingCoordinates msg)
    -> Triangle2d units coordinates
    -> ElementIn units coordinates drawingCoordinates msg
triangle attributes givenTriangle =
    drawRegion attributes Svg.triangle2d givenTriangle


render :
    Bool
    -> Float
    -> Float
    -> Float
    -> String
    -> String
    -> ElementIn units coordinates drawingCoordinates msg
    -> Svg (Event drawingCoordinates msg)
render bordersVisible pixelSize strokeWidth fontSize gradientFill gradientStroke (Element function) =
    function bordersVisible pixelSize strokeWidth fontSize gradientFill gradientStroke


group :
    List (AttributeIn units coordinates drawingCoordinates msg)
    -> List (ElementIn units coordinates drawingCoordinates msg)
    -> ElementIn units coordinates drawingCoordinates msg
group attributes childElements =
    groupLike "g" [] (collectAttributeValues attributes) childElements


groupLike :
    String
    -> List (Svg.Attribute (Event drawingCoordinates msg))
    -> AttributeValues units coordinates drawingCoordinates msg
    -> List (ElementIn units coordinates drawingCoordinates msg)
    -> ElementIn units coordinates drawingCoordinates msg
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
                        |> addEventHandlers attributeValues
            in
            Svg.node tag
                (groupAttributes ++ extraSvgAttributes)
                (gradientElements ++ childSvgElements)


add :
    List (AttributeIn units coordinates drawingCoordinates msg)
    -> ElementIn units coordinates drawingCoordinates msg
    -> ElementIn units coordinates drawingCoordinates msg
add attributes element =
    group attributes [ element ]


arc :
    List (AttributeIn units coordinates drawingCoordinates msg)
    -> Arc2d units coordinates
    -> ElementIn units coordinates drawingCoordinates msg
arc attributes givenArc =
    drawCurve attributes Svg.arc2d givenArc


quadraticSpline :
    List (AttributeIn units coordinates drawingCoordinates msg)
    -> QuadraticSpline2d units coordinates
    -> ElementIn units coordinates drawingCoordinates msg
quadraticSpline attributes givenSpline =
    drawCurve attributes Svg.quadraticSpline2d givenSpline


cubicSpline :
    List (AttributeIn units coordinates drawingCoordinates msg)
    -> CubicSpline2d units coordinates
    -> ElementIn units coordinates drawingCoordinates msg
cubicSpline attributes givenSpline =
    drawCurve attributes Svg.cubicSpline2d givenSpline


polyline :
    List (AttributeIn units coordinates drawingCoordinates msg)
    -> Polyline2d units coordinates
    -> ElementIn units coordinates drawingCoordinates msg
polyline attributes givenPolyline =
    drawCurve attributes Svg.polyline2d givenPolyline


polygon :
    List (AttributeIn units coordinates drawingCoordinates msg)
    -> Polygon2d units coordinates
    -> ElementIn units coordinates drawingCoordinates msg
polygon attributes givenPolygon =
    drawRegion attributes Svg.polygon2d givenPolygon


circle :
    List (AttributeIn units coordinates drawingCoordinates msg)
    -> Circle2d units coordinates
    -> ElementIn units coordinates drawingCoordinates msg
circle attributes givenCircle =
    drawRegion attributes Svg.circle2d givenCircle


ellipticalArc :
    List (AttributeIn units coordinates drawingCoordinates msg)
    -> EllipticalArc2d units coordinates
    -> ElementIn units coordinates drawingCoordinates msg
ellipticalArc attributes givenArc =
    drawCurve attributes Svg.ellipticalArc2d givenArc


ellipse :
    List (AttributeIn units coordinates drawingCoordinates msg)
    -> Ellipse2d units coordinates
    -> ElementIn units coordinates drawingCoordinates msg
ellipse attributes givenEllipse =
    drawRegion attributes Svg.ellipse2d givenEllipse


rectangle :
    List (AttributeIn units coordinates drawingCoordinates msg)
    -> Rectangle2d units coordinates
    -> ElementIn units coordinates drawingCoordinates msg
rectangle attributes givenRectangle =
    drawRegion attributes Svg.rectangle2d givenRectangle


text :
    List (AttributeIn units coordinates drawingCoordinates msg)
    -> Point2d units coordinates
    -> String
    -> ElementIn units coordinates drawingCoordinates msg
text attributes position string =
    let
        attributeValues =
            collectAttributeValues attributes

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
                        |> addFontFamily attributeValues
                        |> addFontSize attributeValues
                        |> addTextAnchor attributeValues
                        |> addTextColor attributeValues
                        |> addEventHandlers attributeValues
            in
            Svg.text_ svgAttributes [ Svg.text string ]


image :
    List (AttributeIn units coordinates drawingCoordinates msg)
    -> String
    -> Rectangle2d units coordinates
    -> ElementIn units coordinates drawingCoordinates msg
image attributes givenUrl givenRectangle =
    let
        attributeValues =
            collectAttributeValues attributes

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
                        |> addEventHandlers attributeValues
            in
            Svg.image svgAttributes []


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
    -> ElementIn units localCoordinates drawingCoordinates msg
    -> ElementIn units globalCoordinates drawingCoordinates msg
placeIn frame (Element function) =
    Element
        (\currentBordersVisible currentPixelSize currentStrokeWidth currentFontSize currentFillGradient currentStrokeGradient ->
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
    -> ElementIn units coordinates drawingCoordinates msg
    -> ElementIn units coordinates drawingCoordinates msg
scaleAbout point scale element =
    scaleImpl point scale element


scaleImpl :
    Point2d units1 coordinates
    -> Float
    -> ElementIn units1 coordinates drawingCoordinates msg
    -> ElementIn units2 coordinates drawingCoordinates msg
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
    -> ElementIn units globalCoordinates drawingCoordinates msg
    -> ElementIn units localCoordinates drawingCoordinates msg
relativeTo frame element =
    element |> placeIn (Frame2d.atOrigin |> Frame2d.relativeTo frame)


translateBy :
    Vector2d units coordinates
    -> ElementIn units coordinates drawingCoordinates msg
    -> ElementIn units coordinates drawingCoordinates msg
translateBy displacement element =
    element |> placeIn (Frame2d.atOrigin |> Frame2d.translateBy displacement)


translateIn :
    Direction2d coordinates
    -> Quantity Float units
    -> ElementIn units coordinates drawingCoordinates msg
    -> ElementIn units coordinates drawingCoordinates msg
translateIn direction distance element =
    element |> translateBy (Vector2d.withLength distance direction)


rotateAround :
    Point2d units coordinates
    -> Angle
    -> ElementIn units coordinates drawingCoordinates msg
    -> ElementIn units coordinates drawingCoordinates msg
rotateAround centerPoint angle element =
    element |> placeIn (Frame2d.atOrigin |> Frame2d.rotateAround centerPoint angle)


mirrorAcross :
    Axis2d units coordinates
    -> ElementIn units coordinates drawingCoordinates msg
    -> ElementIn units coordinates drawingCoordinates msg
mirrorAcross axis element =
    element |> placeIn (Frame2d.atOrigin |> Frame2d.mirrorAcross axis)


at :
    Quantity Float (Rate units2 units1)
    -> ElementIn units1 coordinates drawingCoordinates msg
    -> ElementIn units2 coordinates drawingCoordinates msg
at (Quantity scale) element =
    scaleImpl Point2d.origin scale element


at_ :
    Quantity Float (Rate units1 units2)
    -> ElementIn units1 coordinates drawingCoordinates msg
    -> ElementIn units2 coordinates drawingCoordinates msg
at_ (Quantity scale) element =
    scaleImpl Point2d.origin (1 / scale) element


mapEvent : (a -> b) -> Event drawingCoordinates a -> Event drawingCoordinates b
mapEvent function (Event callback) =
    Event (callback >> function)


map :
    (a -> b)
    -> ElementIn units coordinates drawingCoordinates a
    -> ElementIn units coordinates drawingCoordinates b
map mapFunction (Element drawFunction) =
    Element
        (\arg1 arg2 arg3 arg4 arg5 arg6 ->
            Svg.map (mapEvent mapFunction) (drawFunction arg1 arg2 arg3 arg4 arg5 arg6)
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


rebuildLinearGradient :
    Float
    -> Float
    -> Float
    -> Float
    -> String
    -> Gradient units coordinates
rebuildLinearGradient x1 y1 x2 y2 stopsId =
    LinearGradient
        { id = ""
        , start = Point2d.unsafe { x = x1, y = y1 }
        , end = Point2d.unsafe { x = x2, y = y2 }
        , stops = StopsReference stopsId
        }


rebuildRadialGradient :
    Float
    -> Float
    -> Float
    -> Float
    -> Float
    -> String
    -> Gradient units coordinates
rebuildRadialGradient fx fy cx cy r stopsId =
    RadialGradient
        { id = ""
        , start = Point2d.unsafe { x = fx, y = fy }
        , end = Circle2d.withRadius (Quantity r) (Point2d.unsafe { x = cx, y = cy })
        , stops = StopsReference stopsId
        }


decodeGradient : String -> Maybe (Gradient units coordinates)
decodeGradient string =
    if String.isEmpty string then
        Nothing

    else
        Decode.decodeString gradientDecoder string |> Result.withDefault Nothing


addGradientElements :
    Gradient units coordinates
    -> List (Svg (Event drawingCoordinates msg))
    -> List (Svg (Event drawingCoordinates msg))
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


stopElement : Stop -> Svg (Event drawingCoordinates msg)
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


setAttribute :
    AttributeIn units coordinates drawingCoordinates msg
    -> AttributeValues units coordinates drawingCoordinates msg
    -> AttributeValues units coordinates drawingCoordinates msg
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

        OnLeftClick decoder ->
            { attributeValues | onLeftClick = Just decoder }

        OnRightClick decoder ->
            { attributeValues | onRightClick = Just decoder }

        OnLeftMouseDown decoder ->
            { attributeValues | onLeftMouseDown = Just decoder }

        OnMiddleMouseDown decoder ->
            { attributeValues | onMiddleMouseDown = Just decoder }

        OnRightMouseDown decoder ->
            { attributeValues | onRightMouseDown = Just decoder }

        OnLeftMouseUp decoder ->
            { attributeValues | onLeftMouseUp = Just decoder }

        OnMiddleMouseUp decoder ->
            { attributeValues | onMiddleMouseUp = Just decoder }

        OnRightMouseUp decoder ->
            { attributeValues | onRightMouseUp = Just decoder }


collectAttributeValues :
    List (AttributeIn units coordinates drawingCoordinates msg)
    -> AttributeValues units coordinates drawingCoordinates msg
collectAttributeValues attributeList =
    assignAttributes attributeList emptyAttributeValues


assignAttributes :
    List (AttributeIn units coordinates drawingCoordinates msg)
    -> AttributeValues units coordinates drawingCoordinates msg
    -> AttributeValues units coordinates drawingCoordinates msg
assignAttributes attributeList attributeValues =
    List.foldr setAttribute attributeValues attributeList


addFillStyle :
    AttributeValues units coordinates drawingCoordinates msg
    -> List (Svg.Attribute a)
    -> List (Svg.Attribute a)
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


addStrokeStyle :
    AttributeValues units coordinates drawingCoordinates msg
    -> List (Svg.Attribute a)
    -> List (Svg.Attribute a)
addStrokeStyle attributeValues svgAttributes =
    case attributeValues.strokeStyle of
        Nothing ->
            svgAttributes

        Just (StrokeColor string) ->
            Svg.Attributes.stroke string :: svgAttributes

        Just (StrokeGradient gradient) ->
            Svg.Attributes.stroke (gradientReference gradient) :: svgAttributes


addFontSize :
    AttributeValues units coordinates drawingCoordinates msg
    -> List (Svg.Attribute a)
    -> List (Svg.Attribute a)
addFontSize attributeValues svgAttributes =
    case attributeValues.fontSize of
        Nothing ->
            svgAttributes

        Just size ->
            Svg.Attributes.fontSize (String.fromFloat size) :: svgAttributes


addStrokeWidth :
    AttributeValues units coordinates drawingCoordinates msg
    -> List (Svg.Attribute a)
    -> List (Svg.Attribute a)
addStrokeWidth attributeValues svgAttributes =
    case attributeValues.strokeWidth of
        Nothing ->
            svgAttributes

        Just width ->
            Svg.Attributes.strokeWidth (String.fromFloat width) :: svgAttributes


addTextColor :
    AttributeValues units coordinates drawingCoordinates msg
    -> List (Svg.Attribute a)
    -> List (Svg.Attribute a)
addTextColor attributeValues svgAttributes =
    case attributeValues.textColor of
        Nothing ->
            svgAttributes

        Just string ->
            Svg.Attributes.color string :: svgAttributes


addFontFamily :
    AttributeValues units coordinates drawingCoordinates msg
    -> List (Svg.Attribute a)
    -> List (Svg.Attribute a)
addFontFamily attributeValues svgAttributes =
    case attributeValues.fontFamily of
        Nothing ->
            svgAttributes

        Just string ->
            Svg.Attributes.fontFamily string :: svgAttributes


addTextAnchor :
    AttributeValues units coordinates drawingCoordinates msg
    -> List (Svg.Attribute a)
    -> List (Svg.Attribute a)
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


addEventHandlers :
    AttributeValues units coordinates drawingCoordinates msg
    -> List (Svg.Attribute (Event drawingCoordinates msg))
    -> List (Svg.Attribute (Event drawingCoordinates msg))
addEventHandlers attributeValues svgAttributes =
    svgAttributes
        |> addOnLeftClick attributeValues.onLeftClick
        |> addOnRightClick attributeValues.onRightClick
        |> addOnMouseDown attributeValues
        |> addOnMouseUp attributeValues


on :
    String
    -> Decoder (Event drawingCoordinates msg)
    -> Svg.Attribute (Event drawingCoordinates msg)
on eventName decoder =
    Svg.Events.custom eventName (preventDefaultAndStopPropagation decoder)


addOnLeftClick :
    Maybe (ClickDecoder drawingCoordinates msg)
    -> List (Svg.Attribute (Event drawingCoordinates msg))
    -> List (Svg.Attribute (Event drawingCoordinates msg))
addOnLeftClick registeredDecoder svgAttributes =
    case registeredDecoder of
        Nothing ->
            svgAttributes

        Just decoder ->
            on "click" (handleClick decoder) :: svgAttributes


addOnRightClick :
    Maybe (ClickDecoder drawingCoordinates msg)
    -> List (Svg.Attribute (Event drawingCoordinates msg))
    -> List (Svg.Attribute (Event drawingCoordinates msg))
addOnRightClick registeredDecoder svgAttributes =
    case registeredDecoder of
        Nothing ->
            svgAttributes

        Just decoder ->
            on "contextmenu" (handleClick decoder) :: svgAttributes


registerDecoder : Int -> Maybe a -> Dict Int a -> Dict Int a
registerDecoder whichButton maybeDecoder dict =
    case maybeDecoder of
        Just decoder ->
            dict |> Dict.insert whichButton decoder

        Nothing ->
            dict


addOnMouseDown :
    AttributeValues units coordinates drawingCoordinates msg
    -> List (Svg.Attribute (Event drawingCoordinates msg))
    -> List (Svg.Attribute (Event drawingCoordinates msg))
addOnMouseDown attributeValues svgAttributes =
    let
        decodersByButton =
            Dict.empty
                |> registerDecoder leftButton attributeValues.onLeftMouseDown
                |> registerDecoder rightButton attributeValues.onRightMouseDown
                |> registerDecoder middleButton attributeValues.onMiddleMouseDown
    in
    if Dict.isEmpty decodersByButton then
        svgAttributes

    else
        on "mousedown" (handleMouseDown decodersByButton) :: svgAttributes


addOnMouseUp :
    AttributeValues units coordinates drawingCoordinates msg
    -> List (Svg.Attribute (Event drawingCoordinates msg))
    -> List (Svg.Attribute (Event drawingCoordinates msg))
addOnMouseUp attributeValues svgAttributes =
    let
        decodersByButton =
            Dict.empty
                |> registerDecoder leftButton attributeValues.onLeftMouseUp
                |> registerDecoder rightButton attributeValues.onRightMouseUp
                |> registerDecoder middleButton attributeValues.onMiddleMouseUp
    in
    if Dict.isEmpty decodersByButton then
        svgAttributes

    else
        on "mouseup" (handleMouseUp decodersByButton) :: svgAttributes


addStrokeGradient :
    AttributeValues units coordinates drawingCoordinates msg
    -> List (Svg (Event drawingCoordinates msg))
    -> List (Svg (Event drawingCoordinates msg))
addStrokeGradient attributeValues svgElements =
    case attributeValues.strokeStyle of
        Nothing ->
            svgElements

        Just (StrokeColor _) ->
            svgElements

        Just (StrokeGradient gradient) ->
            addGradientElements gradient svgElements


addFillGradient :
    AttributeValues units coordinates drawingCoordinates msg
    -> List (Svg (Event drawingCoordinates msg))
    -> List (Svg (Event drawingCoordinates msg))
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


addGradientElement :
    Maybe (Gradient units coordinates)
    -> List (Svg (Event drawingCoordinates msg))
    -> List (Svg (Event drawingCoordinates msg))
addGradientElement maybeGradient svgElements =
    case maybeGradient of
        Nothing ->
            svgElements

        Just gradient ->
            addGradientElements gradient svgElements


addTransformedFillGradientReference :
    Maybe (Gradient units gradientCoordinates)
    -> List (Svg.Attribute a)
    -> List (Svg.Attribute a)
addTransformedFillGradientReference maybeGradient svgAttributes =
    case maybeGradient of
        Nothing ->
            svgAttributes

        Just gradient ->
            Svg.Attributes.fill (gradientReference gradient) :: svgAttributes


addTransformedStrokeGradientReference :
    Maybe (Gradient units gradientCoordinates)
    -> List (Svg.Attribute a)
    -> List (Svg.Attribute a)
addTransformedStrokeGradientReference maybeGradient svgAttributes =
    case maybeGradient of
        Nothing ->
            svgAttributes

        Just gradient ->
            Svg.Attributes.stroke (gradientReference gradient) :: svgAttributes
