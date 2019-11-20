module Drawing2d.Attributes.Protected exposing
    ( AttributeIn(..)
    , AttributeValues
    , ClickDecoder
    , Fill(..)
    , LineCap(..)
    , LineJoin(..)
    , MouseDownDecoder
    , Stroke(..)
    , TouchChangeDecoder
    , TouchEndDecoder
    , TouchStartDecoder
    , addCurveAttributes
    , addGroupAttributes
    , addRegionAttributes
    , addTextAttributes
    , assignAttributes
    , collectAttributeValues
    , emptyAttributeValues
    )

import Dict exposing (Dict)
import Drawing2d.Gradient.Protected as Gradient exposing (Gradient)
import Drawing2d.MouseInteraction.Protected exposing (MouseInteraction)
import Drawing2d.TouchInteraction.Protected exposing (TouchInteraction)
import Duration exposing (Duration)
import Json.Decode exposing (Decoder)
import Pixels exposing (Pixels)
import Point2d exposing (Point2d)
import Svg
import Svg.Attributes


type Fill units coordinates
    = NoFill
    | FillColor String
    | FillGradient (Gradient units coordinates)


type Stroke units coordinates
    = StrokeColor String
    | StrokeGradient (Gradient units coordinates)


type LineJoin
    = BevelJoin
    | MiterJoin
    | RoundJoin


type LineCap
    = ButtCap
    | SquareCap
    | RoundCap


type alias ClickDecoder drawingCoordinates msg =
    Decoder (Point2d Pixels drawingCoordinates -> msg)


type alias MouseDownDecoder drawingCoordinates msg =
    Decoder (Point2d Pixels drawingCoordinates -> MouseInteraction drawingCoordinates -> msg)


type alias TouchStartDecoder drawingCoordinates msg =
    Decoder (Dict Int (Point2d Pixels drawingCoordinates) -> TouchInteraction drawingCoordinates -> msg)


type alias TouchChangeDecoder drawingCoordinates msg =
    Decoder (Dict Int (Point2d Pixels drawingCoordinates) -> msg)


type alias TouchEndDecoder msg =
    Decoder (Duration -> msg)


type AttributeIn units coordinates drawingCoordinates msg
    = FillStyle (Fill units coordinates) -- Svg.Attributes.fill
    | StrokeStyle (Stroke units coordinates) -- Svg.Attributes.stroke
    | FontSize Float
    | StrokeWidth Float
    | StrokeLineJoin LineJoin
    | StrokeLineCap LineCap
    | BorderVisibility Bool
    | TextColor String -- Svg.Attributes.color
    | FontFamily String -- Svg.Attributes.fontFamily
    | TextAnchor { x : String, y : String } -- Svg.Attributes.textAnchor, Svg.Attributes.dominantBaseline
    | OnLeftClick (ClickDecoder drawingCoordinates msg)
    | OnRightClick (ClickDecoder drawingCoordinates msg)
    | OnLeftMouseDown (MouseDownDecoder drawingCoordinates msg)
    | OnMiddleMouseDown (MouseDownDecoder drawingCoordinates msg)
    | OnRightMouseDown (MouseDownDecoder drawingCoordinates msg)
    | OnLeftMouseUp (Decoder msg)
    | OnMiddleMouseUp (Decoder msg)
    | OnRightMouseUp (Decoder msg)
    | OnTouchStart (TouchStartDecoder drawingCoordinates msg)
    | OnTouchChange (TouchChangeDecoder drawingCoordinates msg) (TouchInteraction drawingCoordinates)
    | OnTouchEnd (TouchEndDecoder msg) (TouchInteraction drawingCoordinates)


type alias AttributeValues units coordinates drawingCoordinates msg =
    { fillStyle : Maybe (Fill units coordinates)
    , strokeStyle : Maybe (Stroke units coordinates)
    , fontSize : Maybe Float
    , strokeWidth : Maybe Float
    , strokeLineJoin : Maybe LineJoin
    , strokeLineCap : Maybe LineCap
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
    , onTouchStart : Maybe (TouchStartDecoder drawingCoordinates msg)
    , onTouchChange : Maybe ( TouchChangeDecoder drawingCoordinates msg, TouchInteraction drawingCoordinates )
    , onTouchEnd : Maybe ( TouchEndDecoder msg, TouchInteraction drawingCoordinates )
    }


emptyAttributeValues : AttributeValues units coordinates drawingCoordinates msg
emptyAttributeValues =
    { fillStyle = Nothing
    , strokeStyle = Nothing
    , fontSize = Nothing
    , strokeWidth = Nothing
    , strokeLineJoin = Nothing
    , strokeLineCap = Nothing
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
    , onTouchStart = Nothing
    , onTouchChange = Nothing
    , onTouchEnd = Nothing
    }


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

        StrokeLineJoin lineJoin ->
            { attributeValues | strokeLineJoin = Just lineJoin }

        StrokeLineCap lineCap ->
            { attributeValues | strokeLineCap = Just lineCap }

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

        OnTouchStart decoder ->
            { attributeValues | onTouchStart = Just decoder }

        OnTouchChange decoder interaction ->
            { attributeValues | onTouchChange = Just ( decoder, interaction ) }

        OnTouchEnd decoder interaction ->
            { attributeValues | onTouchEnd = Just ( decoder, interaction ) }


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


noStroke : Svg.Attribute msg
noStroke =
    Svg.Attributes.stroke "none"


noFill : Svg.Attribute msg
noFill =
    Svg.Attributes.fill "none"


addFillStyle :
    AttributeValues units coordinates drawingCoordinates msg
    -> List (Svg.Attribute a)
    -> List (Svg.Attribute a)
addFillStyle attributeValues svgAttributes =
    case attributeValues.fillStyle of
        Nothing ->
            svgAttributes

        Just NoFill ->
            noFill :: svgAttributes

        Just (FillColor string) ->
            Svg.Attributes.fill string :: svgAttributes

        Just (FillGradient gradient) ->
            Svg.Attributes.fill (Gradient.reference gradient) :: svgAttributes


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
            Svg.Attributes.stroke (Gradient.reference gradient) :: svgAttributes


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


lineJoinString lineJoin =
    case lineJoin of
        BevelJoin ->
            "bevel"

        RoundJoin ->
            "round"

        MiterJoin ->
            "miter"


lineCapString lineJoin =
    case lineJoin of
        ButtCap ->
            "butt"

        SquareCap ->
            "square"

        RoundCap ->
            "round"


addStrokeLineJoin :
    AttributeValues units coordinates drawingCoordinates msg
    -> List (Svg.Attribute a)
    -> List (Svg.Attribute a)
addStrokeLineJoin attributeValues svgAttributes =
    case attributeValues.strokeLineJoin of
        Nothing ->
            svgAttributes

        Just lineJoin ->
            Svg.Attributes.strokeLinejoin (lineJoinString lineJoin) :: svgAttributes


addStrokeLineCap :
    AttributeValues units coordinates drawingCoordinates msg
    -> List (Svg.Attribute a)
    -> List (Svg.Attribute a)
addStrokeLineCap attributeValues svgAttributes =
    case attributeValues.strokeLineCap of
        Nothing ->
            svgAttributes

        Just lineCap ->
            Svg.Attributes.strokeLinecap (lineCapString lineCap) :: svgAttributes


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


addCurveAttributes :
    AttributeValues units coordinates drawingCoordinates msg
    -> List (Svg.Attribute a)
    -> List (Svg.Attribute a)
addCurveAttributes attributeValues svgAttributes =
    svgAttributes
        |> addStrokeStyle attributeValues
        |> addStrokeWidth attributeValues
        |> addStrokeLineJoin attributeValues
        |> addStrokeLineCap attributeValues


addRegionAttributes :
    Bool
    -> AttributeValues units coordinates drawingCoordinates msg
    -> List (Svg.Attribute a)
    -> List (Svg.Attribute a)
addRegionAttributes bordersVisible attributeValues svgAttributes =
    let
        attributesWithFillStyle =
            svgAttributes |> addFillStyle attributeValues
    in
    if bordersVisible then
        attributesWithFillStyle |> addCurveAttributes attributeValues

    else
        noStroke :: attributesWithFillStyle


addGroupAttributes :
    AttributeValues units coordinates drawingCoordinates msg
    -> List (Svg.Attribute a)
    -> List (Svg.Attribute a)
addGroupAttributes attributeValues svgAttributes =
    svgAttributes
        |> addFillStyle attributeValues
        |> addFontFamily attributeValues
        |> addFontSize attributeValues
        |> addStrokeStyle attributeValues
        |> addStrokeWidth attributeValues
        |> addStrokeLineJoin attributeValues
        |> addStrokeLineCap attributeValues
        |> addTextAnchor attributeValues
        |> addTextColor attributeValues


addTextAttributes :
    AttributeValues units coordinates drawingCoordinates msg
    -> List (Svg.Attribute a)
    -> List (Svg.Attribute a)
addTextAttributes attributeValues svgAttributes =
    svgAttributes
        |> addFontFamily attributeValues
        |> addFontSize attributeValues
        |> addTextAnchor attributeValues
        |> addTextColor attributeValues
