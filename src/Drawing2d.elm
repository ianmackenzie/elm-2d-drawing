module Drawing2d exposing
    ( Attribute
    , Element
    , arc
    , circle
    , cubicSpline
    , ellipse
    , ellipticalArc
    , empty
    , group
    , image
    , lineSegment
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
    , with
    )

import Angle exposing (Angle)
import Arc2d exposing (Arc2d)
import Axis2d exposing (Axis2d)
import BoundingBox2d exposing (BoundingBox2d)
import Circle2d exposing (Circle2d)
import Color exposing (Color)
import CubicSpline2d exposing (CubicSpline2d)
import Direction2d exposing (Direction2d)
import Drawing2d.Attributes as Attributes
import Drawing2d.Gradient as Gradient
import Drawing2d.Stops as Stops
import Drawing2d.Svg as Svg
import Drawing2d.Text as Text
import Drawing2d.Types as Types exposing (Attribute(..), Fill(..), Gradient(..), Stop, Stops(..), Stroke(..))
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
import Quantity exposing (Quantity(..))
import Rectangle2d exposing (Rectangle2d)
import Svg exposing (Svg)
import Svg.Attributes
import Triangle2d exposing (Triangle2d)
import Vector2d exposing (Vector2d)
import VirtualDom


type Element units coordinates
    = Element
        (Bool -- borders visible
         -> Float -- pixel size in current units
         -> Float -- stroke width in current units
         -> Float -- font size in current units
         -> String -- encoded gradient fill in current units
         -> String -- encoded gradient stroke in current units
         -> Svg Never
        )


type alias Attribute units coordinates =
    Types.Attribute units coordinates


leaf : Svg Never -> Element units coordinates
leaf svgElement =
    Element (\_ _ _ _ _ _ -> svgElement)


{-| TODO pass 'screen' argument?
-}
custom : ((Float -> Quantity Float units) -> Element units coordinates) -> Element units coordinates
custom givenFunction =
    Element
        (\bordersVisible pixelSize strokeWidth fontSize gradientFill gradientStroke ->
            let
                (Element renderFunction) =
                    givenFunction (\numPixels -> Quantity (numPixels * pixelSize))
            in
            renderFunction bordersVisible pixelSize strokeWidth fontSize gradientFill gradientStroke
        )


toHtml : BoundingBox2d Pixels coordinates -> List (Attribute Pixels coordinates) -> List (Element Pixels coordinates) -> Html msg
toHtml boundingBox attributes elements =
    let
        ( width, height ) =
            BoundingBox2d.dimensions boundingBox

        { minX, maxY } =
            BoundingBox2d.extrema boundingBox

        defaultAttributes =
            [ Attributes.blackStroke
            , Attributes.strokeWidth (pixels 1)
            , Attributes.whiteFill
            , Attributes.strokedBorder
            , Attributes.fontSize (pixels 20)
            , Attributes.textColor Color.black
            , Attributes.textAnchor Text.bottomLeft
            ]

        (Element rootElement) =
            group defaultAttributes [ group attributes elements ]

        viewBoxString =
            String.join " "
                [ String.fromFloat (inPixels minX)
                , String.fromFloat -(inPixels maxY)
                , String.fromFloat (inPixels width)
                , String.fromFloat (inPixels height)
                ]
    in
    Html.div
        [ Html.Attributes.style "border" "0"
        , Html.Attributes.style "padding" "0"
        , Html.Attributes.style "margin" "0"
        , Html.Attributes.style "display" "inline-block"
        ]
        [ Svg.svg
            [ Svg.Attributes.width (String.fromFloat (inPixels width))
            , Svg.Attributes.height (String.fromFloat (inPixels height))
            , Svg.Attributes.viewBox viewBoxString
            , Html.Attributes.style "display" "block"
            ]
            [ rootElement False 1 0 0 "" "" ]
        ]
        |> Html.map never


empty : Element units coordinates
empty =
    leaf (Svg.text "")


drawCurve :
    List (Attribute units coordinates)
    -> (List (Svg.Attribute Never) -> a -> Svg Never)
    -> a
    -> Element units coordinates
drawCurve attributes toSvg curve =
    let
        attributeValues =
            collectAttributeValues attributes

        givenAttributes =
            []
                |> addStrokeStyle attributeValues
                |> addStrokeWidth attributeValues

        svgAttributes =
            Svg.Attributes.fill "none" :: givenAttributes

        curveElement =
            toSvg svgAttributes curve

        gradientElements =
            [] |> addStrokeGradient attributeValues

        svgElement =
            case gradientElements of
                [] ->
                    curveElement

                _ ->
                    Svg.g []
                        [ Svg.defs [] gradientElements
                        , curveElement
                        ]
    in
    leaf svgElement


drawRegion :
    List (Attribute units coordinates)
    -> (List (Svg.Attribute Never) -> a -> Svg Never)
    -> a
    -> Element units coordinates
drawRegion attributes toSvg region =
    let
        attributeValues =
            collectAttributeValues attributes

        commonAttributes =
            [] |> addFillStyle attributeValues

        fillGradientElement =
            [] |> addFillGradient attributeValues
    in
    Element <|
        \currentBordersVisible _ _ _ _ _ ->
            let
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


lineSegment : List (Attribute units coordinates) -> LineSegment2d units coordinates -> Element units coordinates
lineSegment attributes givenSegment =
    drawCurve attributes Svg.lineSegment2d givenSegment


triangle : List (Attribute units coordinates) -> Triangle2d units coordinates -> Element units coordinates
triangle attributes givenTriangle =
    drawRegion attributes Svg.triangle2d givenTriangle


render : Bool -> Float -> Float -> Float -> String -> String -> Element units coordinates -> Svg Never
render bordersVisible pixelSize strokeWidth fontSize gradientFill gradientStroke (Element function) =
    function bordersVisible pixelSize strokeWidth fontSize gradientFill gradientStroke


with : List (Attribute units coordinates) -> Element units coordinates -> Element units coordinates
with attributes element =
    group attributes [ element ]


group : List (Attribute units coordinates) -> List (Element units coordinates) -> Element units coordinates
group attributes childElements =
    let
        attributeValues =
            collectAttributeValues attributes
    in
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
                            (render updatedBordersVisible currentPixelSize updatedStrokeWidth updatedFontSize updatedFillGradient updatedStrokeGradient)

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


arc : List (Attribute units coordinates) -> Arc2d units coordinates -> Element units coordinates
arc attributes givenArc =
    drawCurve attributes Svg.arc2d givenArc


quadraticSpline : List (Attribute units coordinates) -> QuadraticSpline2d units coordinates -> Element units coordinates
quadraticSpline attributes givenSpline =
    drawCurve attributes Svg.quadraticSpline2d givenSpline


cubicSpline : List (Attribute units coordinates) -> CubicSpline2d units coordinates -> Element units coordinates
cubicSpline attributes givenSpline =
    drawCurve attributes Svg.cubicSpline2d givenSpline


polyline : List (Attribute units coordinates) -> Polyline2d units coordinates -> Element units coordinates
polyline attributes givenPolyline =
    drawCurve attributes Svg.polyline2d givenPolyline


polygon : List (Attribute units coordinates) -> Polygon2d units coordinates -> Element units coordinates
polygon attributes givenPolygon =
    drawRegion attributes Svg.polygon2d givenPolygon


circle : List (Attribute units coordinates) -> Circle2d units coordinates -> Element units coordinates
circle attributes givenCircle =
    drawRegion attributes Svg.circle2d givenCircle


ellipticalArc : List (Attribute units coordinates) -> EllipticalArc2d units coordinates -> Element units coordinates
ellipticalArc attributes givenArc =
    drawCurve attributes Svg.ellipticalArc2d givenArc


ellipse : List (Attribute units coordinates) -> Ellipse2d units coordinates -> Element units coordinates
ellipse attributes givenEllipse =
    drawRegion attributes Svg.ellipse2d givenEllipse


rectangle : List (Attribute units coordinates) -> Rectangle2d units coordinates -> Element units coordinates
rectangle attributes givenRectangle =
    drawRegion attributes Svg.rectangle2d givenRectangle


text : List (Attribute units coordinates) -> Point2d units coordinates -> String -> Element units coordinates
text attributes position string =
    let
        attributeValues =
            collectAttributeValues attributes

        { x, y } =
            Point2d.unwrap position

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

        svgElement =
            Svg.text_ svgAttributes [ Svg.text string ]
    in
    leaf svgElement


image : String -> Rectangle2d units coordinates -> Element units coordinates
image givenUrl givenRectangle =
    let
        ( Quantity width, Quantity height ) =
            Rectangle2d.dimensions givenRectangle
    in
    leaf <|
        Svg.image
            [ Svg.Attributes.xlinkHref givenUrl
            , Svg.Attributes.x (String.fromFloat (-width / 2))
            , Svg.Attributes.y (String.fromFloat (-height / 2))
            , Svg.Attributes.width (String.fromFloat width)
            , Svg.Attributes.height (String.fromFloat height)
            , placementTransform (Rectangle2d.axes givenRectangle)
            ]
            []


placementTransform : Frame2d units coordinates defines -> Svg.Attribute msg
placementTransform frame =
    let
        p =
            Point2d.unwrap (Frame2d.originPoint frame)

        i =
            Direction2d.toRecord (Frame2d.xDirection frame)

        j =
            Direction2d.toRecord (Frame2d.yDirection frame)

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
    -> Element units localCoordinates
    -> Element units globalCoordinates
placeIn frame (Element function) =
    Element
        (\currentBordersVisible currentPixelSize currentStrokeWidth currentFontSize currentFillGradient currentStrokeGradient ->
            let
                transformation =
                    Gradient.relativeTo frame

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

                svgAttributes =
                    [ placementTransform frame ]
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
                        currentPixelSize
                        currentStrokeWidth
                        currentFontSize
                        updatedFillGradient
                        updatedStrokeGradient
            in
            case transformedGradientElements of
                [] ->
                    Svg.g svgAttributes [ childSvgElement ]

                _ ->
                    Svg.g svgAttributes
                        [ Svg.defs [] transformedGradientElements
                        , childSvgElement
                        ]
        )


scaleAbout : Point2d units coordinates -> Float -> Element units coordinates -> Element units coordinates
scaleAbout point scale (Element function) =
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
            in
            case transformedGradientElements of
                [] ->
                    Svg.g svgAttributes [ childSvgElement ]

                _ ->
                    Svg.g svgAttributes
                        [ Svg.defs [] transformedGradientElements
                        , childSvgElement
                        ]
        )


relativeTo : Frame2d units globalCoordinates { defines : localCoordinates } -> Element units globalCoordinates -> Element units localCoordinates
relativeTo frame element =
    element |> placeIn (Frame2d.atOrigin |> Frame2d.relativeTo frame)


translateBy : Vector2d units coordinates -> Element units coordinates -> Element units coordinates
translateBy displacement element =
    element |> placeIn (Frame2d.atOrigin |> Frame2d.translateBy displacement)


translateIn : Direction2d coordinates -> Quantity Float units -> Element units coordinates -> Element units coordinates
translateIn direction distance element =
    element |> translateBy (Vector2d.withLength distance direction)


rotateAround : Point2d units coordinates -> Angle -> Element units coordinates -> Element units coordinates
rotateAround centerPoint angle element =
    element
        |> placeIn (Frame2d.atOrigin |> Frame2d.rotateAround centerPoint angle)


mirrorAcross : Axis2d units coordinates -> Element units coordinates -> Element units coordinates
mirrorAcross axis element =
    element |> placeIn (Frame2d.atOrigin |> Frame2d.mirrorAcross axis)



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


addGradientElements : Gradient units coordinates -> List (Svg Never) -> List (Svg Never)
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


stopElement : Stop -> Svg Never
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


type alias AttributeValues units coordinates =
    { fillStyle : Maybe (Fill units coordinates)
    , strokeStyle : Maybe (Stroke units coordinates)
    , fontSize : Maybe Float
    , strokeWidth : Maybe Float
    , borderVisibility : Maybe Bool
    , textColor : Maybe String
    , fontFamily : Maybe String
    , textAnchor : Maybe { x : String, y : String }
    }


setAttribute : Attribute units coordinates -> AttributeValues units coordinates -> AttributeValues units coordinates
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


initialAttributeValues : AttributeValues units coordinates
initialAttributeValues =
    { fillStyle = Nothing
    , strokeStyle = Nothing
    , fontSize = Nothing
    , strokeWidth = Nothing
    , borderVisibility = Nothing
    , textColor = Nothing
    , fontFamily = Nothing
    , textAnchor = Nothing
    }


collectAttributeValues : List (Attribute units coordinates) -> AttributeValues units coordinates
collectAttributeValues attributeList =
    List.foldr setAttribute initialAttributeValues attributeList


addFillStyle : AttributeValues units coordinates -> List (Svg.Attribute Never) -> List (Svg.Attribute Never)
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


addStrokeStyle : AttributeValues units coordinates -> List (Svg.Attribute Never) -> List (Svg.Attribute Never)
addStrokeStyle attributeValues svgAttributes =
    case attributeValues.strokeStyle of
        Nothing ->
            svgAttributes

        Just (StrokeColor string) ->
            Svg.Attributes.stroke string :: svgAttributes

        Just (StrokeGradient gradient) ->
            Svg.Attributes.stroke (gradientReference gradient) :: svgAttributes


addFontSize : AttributeValues units coordinates -> List (Svg.Attribute Never) -> List (Svg.Attribute Never)
addFontSize attributeValues svgAttributes =
    case attributeValues.fontSize of
        Nothing ->
            svgAttributes

        Just size ->
            Svg.Attributes.fontSize (String.fromFloat size) :: svgAttributes


addStrokeWidth : AttributeValues units coordinates -> List (Svg.Attribute Never) -> List (Svg.Attribute Never)
addStrokeWidth attributeValues svgAttributes =
    case attributeValues.strokeWidth of
        Nothing ->
            svgAttributes

        Just width ->
            Svg.Attributes.strokeWidth (String.fromFloat width) :: svgAttributes


addTextColor : AttributeValues units coordinates -> List (Svg.Attribute Never) -> List (Svg.Attribute Never)
addTextColor attributeValues svgAttributes =
    case attributeValues.textColor of
        Nothing ->
            svgAttributes

        Just string ->
            Svg.Attributes.color string :: svgAttributes


addFontFamily : AttributeValues units coordinates -> List (Svg.Attribute Never) -> List (Svg.Attribute Never)
addFontFamily attributeValues svgAttributes =
    case attributeValues.fontFamily of
        Nothing ->
            svgAttributes

        Just string ->
            Svg.Attributes.fontFamily string :: svgAttributes


addTextAnchor : AttributeValues units coordinates -> List (Svg.Attribute Never) -> List (Svg.Attribute Never)
addTextAnchor attributeValues svgAttributes =
    case attributeValues.textAnchor of
        Nothing ->
            svgAttributes

        Just position ->
            Svg.Attributes.textAnchor position.x
                :: Svg.Attributes.dominantBaseline position.y
                :: svgAttributes


addStrokeGradient : AttributeValues units coordinates -> List (Svg Never) -> List (Svg Never)
addStrokeGradient attributeValues svgElements =
    case attributeValues.strokeStyle of
        Nothing ->
            svgElements

        Just (StrokeColor _) ->
            svgElements

        Just (StrokeGradient gradient) ->
            addGradientElements gradient svgElements


addFillGradient : AttributeValues units coordinates -> List (Svg Never) -> List (Svg Never)
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


addGradientElement : Maybe (Gradient units coordinates) -> List (Svg Never) -> List (Svg Never)
addGradientElement maybeGradient svgElements =
    case maybeGradient of
        Nothing ->
            svgElements

        Just gradient ->
            addGradientElements gradient svgElements


addTransformedFillGradientReference : Maybe (Gradient units coordinates) -> List (Svg.Attribute Never) -> List (Svg.Attribute Never)
addTransformedFillGradientReference maybeGradient svgAttributes =
    case maybeGradient of
        Nothing ->
            svgAttributes

        Just gradient ->
            Svg.Attributes.fill (gradientReference gradient) :: svgAttributes


addTransformedStrokeGradientReference : Maybe (Gradient units coordinates) -> List (Svg.Attribute Never) -> List (Svg.Attribute Never)
addTransformedStrokeGradientReference maybeGradient svgAttributes =
    case maybeGradient of
        Nothing ->
            svgAttributes

        Just gradient ->
            Svg.Attributes.stroke (gradientReference gradient) :: svgAttributes
