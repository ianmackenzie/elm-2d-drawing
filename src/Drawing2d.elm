module Drawing2d exposing
    ( Attribute
    , Element
    , Event
    , Size
    , addAttributes
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
import Drawing2d.Attributes.Protected as Attributes
    exposing
        ( AttributeValues
        , Event(..)
        , Fill(..)
        , Stroke(..)
        )
import Drawing2d.Decode as Decode
import Drawing2d.Gradient as Gradient exposing (Gradient)
import Drawing2d.Gradient.Protected as Gradient
import Drawing2d.InteractionPoint as InteractionPoint
import Drawing2d.MouseInteraction as MouseInteraction exposing (MouseInteraction)
import Drawing2d.MouseInteraction.Protected as MouseInteraction
import Drawing2d.MouseMoveEvent as MouseMoveEvent exposing (MouseMoveEvent)
import Drawing2d.MouseStartEvent as MouseStartEvent exposing (MouseStartEvent)
import Drawing2d.Shadow as Shadow
import Drawing2d.Svg as Svg
import Drawing2d.Text as Text
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
    [ Attributes.blackStroke
    , Attributes.strokeWidth (pixels 1)
    , Attributes.bevelJoins
    , Attributes.buttCaps
    , Attributes.whiteFill
    , Attributes.strokedBorder
    , Attributes.fontSize (pixels 20)
    , Attributes.textColor Color.black
    , Attributes.textAnchor Text.bottomLeft
    ]


toHtml :
    { viewBox : BoundingBox2d Pixels drawingCoordinates
    , size : Size
    }
    -> List (Attribute Pixels drawingCoordinates (Event drawingCoordinates msg))
    -> List (Element Pixels drawingCoordinates (Event drawingCoordinates msg))
    -> Html msg
toHtml { viewBox, size } attributes elements =
    let
        ( viewBoxWidth, viewBoxHeight ) =
            BoundingBox2d.dimensions viewBox

        viewBoxExtrema =
            BoundingBox2d.extrema viewBox

        { minX, maxX, minY, maxY } =
            viewBoxExtrema

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
            Attributes.emptyAttributeValues
                |> Attributes.assignAttributes defaultAttributes
                |> Attributes.assignAttributes attributes

        (Element svgElement) =
            groupLike "svg" (viewBoxAttribute :: svgStaticCss) rootAttributeValues elements
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
render bordersVisible pixelSize strokeWidth fontSize gradientFill gradientStroke (Element function) =
    function bordersVisible pixelSize strokeWidth fontSize gradientFill gradientStroke


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


addAttributes :
    List (Attribute units coordinates event)
    -> Element units coordinates event
    -> Element units coordinates event
addAttributes attributes element =
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
