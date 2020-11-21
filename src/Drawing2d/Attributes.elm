module Drawing2d.Attributes exposing
    ( Attribute(..)
    , AttributeValues
    , Event(..)
    , Fill(..)
    , LineCap(..)
    , LineJoin(..)
    , Stroke(..)
    , addCurveAttributes
    , addEventHandlers
    , addGroupAttributes
    , addRegionAttributes
    , addShadowFilter
    , addTextAttributes
    , assignAttributes
    , collectAttributeValues
    , dashPatternSvgAttribute
    , emptyAttributeValues
    )

import Dict exposing (Dict)
import Drawing2d.Gradient as Gradient exposing (Gradient)
import Drawing2d.MouseInteraction.Protected exposing (MouseInteraction(..))
import Drawing2d.Shadow as Shadow exposing (Shadow)
import Drawing2d.TouchInteraction.Protected exposing (TouchInteraction(..))
import Duration exposing (Duration)
import Html.Attributes
import Json.Decode as Decode exposing (Decoder)
import Pixels exposing (Pixels)
import Point2d exposing (Point2d)
import Quantity exposing (Quantity)
import Rectangle2d exposing (Rectangle2d)
import Svg
import Svg.Attributes
import Svg.Events
import Vector2d exposing (Vector2d)


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
    = NoCap
    | SquareCap
    | RoundCap


type Event units coordinates msg
    = Event (Rectangle2d units coordinates -> msg)


type Attribute units coordinates event
    = FillStyle (Fill units coordinates) -- Svg.Attributes.fill
    | StrokeStyle (Stroke units coordinates) -- Svg.Attributes.stroke
    | FontSize Float
    | StrokeWidth Float
    | StrokeLineJoin LineJoin
    | StrokeLineCap LineCap
    | StrokeDashPattern (List Float)
    | BorderVisibility Bool
    | DropShadow (Shadow units coordinates)
    | TextColor String -- Svg.Attributes.color
    | FontFamily String -- Svg.Attributes.fontFamily
    | TextAnchor { x : String, y : String } -- Svg.Attributes.textAnchor, Svg.Attributes.dominantBaseline
    | EventHandlers (List ( String, Decoder event ))


type alias AttributeValues units coordinates event =
    { fillStyle : Maybe (Fill units coordinates)
    , strokeStyle : Maybe (Stroke units coordinates)
    , fontSize : Maybe Float
    , strokeWidth : Maybe Float
    , strokeLineJoin : Maybe LineJoin
    , strokeLineCap : Maybe LineCap
    , strokeDashPattern : Maybe (List Float)
    , borderVisibility : Maybe Bool
    , dropShadow : Maybe (Shadow units coordinates)
    , textColor : Maybe String
    , fontFamily : Maybe String
    , textAnchor : Maybe { x : String, y : String }
    , eventHandlers : Dict String (List (Decoder event))
    }


emptyAttributeValues : AttributeValues units coordinates event
emptyAttributeValues =
    { fillStyle = Nothing
    , strokeStyle = Nothing
    , fontSize = Nothing
    , strokeWidth = Nothing
    , strokeLineJoin = Nothing
    , strokeLineCap = Nothing
    , strokeDashPattern = Nothing
    , borderVisibility = Nothing
    , dropShadow = Nothing
    , textColor = Nothing
    , fontFamily = Nothing
    , textAnchor = Nothing
    , eventHandlers = Dict.empty
    }


setAttribute :
    Attribute units coordinates event
    -> AttributeValues units coordinates event
    -> AttributeValues units coordinates event
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

        StrokeDashPattern dashPattern ->
            { attributeValues | strokeDashPattern = Just dashPattern }

        BorderVisibility bordersVisible ->
            { attributeValues | borderVisibility = Just bordersVisible }

        DropShadow shadow ->
            { attributeValues | dropShadow = Just shadow }

        TextColor string ->
            { attributeValues | textColor = Just string }

        FontFamily string ->
            { attributeValues | fontFamily = Just string }

        TextAnchor position ->
            { attributeValues | textAnchor = Just position }

        EventHandlers eventHandlers ->
            List.foldl registerEventHandler attributeValues eventHandlers


registerEventHandler : ( String, Decoder event ) -> AttributeValues units coordinates event -> AttributeValues units coordinates event
registerEventHandler ( eventName, handler ) attributeValues =
    { attributeValues
        | eventHandlers =
            attributeValues.eventHandlers
                |> Dict.update eventName
                    (\registeredHandlers ->
                        case registeredHandlers of
                            Nothing ->
                                Just [ handler ]

                            Just existingHandlers ->
                                Just (handler :: existingHandlers)
                    )
    }


collectAttributeValues :
    List (Attribute units coordinates event)
    -> AttributeValues units coordinates event
collectAttributeValues attributeList =
    assignAttributes attributeList emptyAttributeValues


assignAttributes :
    List (Attribute units coordinates event)
    -> AttributeValues units coordinates event
    -> AttributeValues units coordinates event
assignAttributes attributeList attributeValues =
    List.foldr setAttribute attributeValues attributeList


noStroke : Svg.Attribute event
noStroke =
    Svg.Attributes.stroke "none"


noFill : Svg.Attribute event
noFill =
    Svg.Attributes.fill "none"


addFillStyle :
    AttributeValues units coordinates event
    -> List (Svg.Attribute event)
    -> List (Svg.Attribute event)
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
    AttributeValues units coordinates event
    -> List (Svg.Attribute event)
    -> List (Svg.Attribute event)
addStrokeStyle attributeValues svgAttributes =
    case attributeValues.strokeStyle of
        Nothing ->
            svgAttributes

        Just (StrokeColor string) ->
            Svg.Attributes.stroke string :: svgAttributes

        Just (StrokeGradient gradient) ->
            Svg.Attributes.stroke (Gradient.reference gradient) :: svgAttributes


addFontSize :
    AttributeValues units coordinates event
    -> List (Svg.Attribute event)
    -> List (Svg.Attribute event)
addFontSize attributeValues svgAttributes =
    case attributeValues.fontSize of
        Nothing ->
            svgAttributes

        Just size ->
            Svg.Attributes.fontSize (String.fromFloat size) :: svgAttributes


addStrokeWidth :
    AttributeValues units coordinates event
    -> List (Svg.Attribute event)
    -> List (Svg.Attribute event)
addStrokeWidth attributeValues svgAttributes =
    case attributeValues.strokeWidth of
        Nothing ->
            svgAttributes

        Just width ->
            Svg.Attributes.strokeWidth (String.fromFloat width) :: svgAttributes


addShadowFilter :
    AttributeValues units coordinates event
    -> List (Svg.Attribute event)
    -> List (Svg.Attribute event)
addShadowFilter attributeValues svgAttributes =
    case attributeValues.dropShadow of
        Nothing ->
            svgAttributes

        Just shadow ->
            Svg.Attributes.filter (Shadow.reference shadow) :: svgAttributes


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
        NoCap ->
            "butt"

        SquareCap ->
            "square"

        RoundCap ->
            "round"


addStrokeLineJoin :
    AttributeValues units coordinates event
    -> List (Svg.Attribute event)
    -> List (Svg.Attribute event)
addStrokeLineJoin attributeValues svgAttributes =
    case attributeValues.strokeLineJoin of
        Nothing ->
            svgAttributes

        Just lineJoin ->
            Svg.Attributes.strokeLinejoin (lineJoinString lineJoin) :: svgAttributes


addStrokeLineCap :
    AttributeValues units coordinates event
    -> List (Svg.Attribute event)
    -> List (Svg.Attribute event)
addStrokeLineCap attributeValues svgAttributes =
    case attributeValues.strokeLineCap of
        Nothing ->
            svgAttributes

        Just lineCap ->
            Svg.Attributes.strokeLinecap (lineCapString lineCap) :: svgAttributes


addStrokeDashPattern :
    AttributeValues units coordinates event
    -> List (Svg.Attribute event)
    -> List (Svg.Attribute event)
addStrokeDashPattern attributeValues svgAttributes =
    case attributeValues.strokeDashPattern of
        Nothing ->
            svgAttributes

        Just dashPattern ->
            dashPatternSvgAttribute dashPattern :: svgAttributes


dashPatternSvgAttribute : List Float -> Svg.Attribute event
dashPatternSvgAttribute dashPattern =
    case dashPattern of
        [] ->
            Svg.Attributes.strokeDasharray "none"

        _ ->
            Svg.Attributes.strokeDasharray (String.join " " (List.map String.fromFloat dashPattern))


addTextColor :
    AttributeValues units coordinates event
    -> List (Svg.Attribute event)
    -> List (Svg.Attribute event)
addTextColor attributeValues svgAttributes =
    case attributeValues.textColor of
        Nothing ->
            svgAttributes

        Just string ->
            Svg.Attributes.color string :: svgAttributes


addFontFamily :
    AttributeValues units coordinates event
    -> List (Svg.Attribute event)
    -> List (Svg.Attribute event)
addFontFamily attributeValues svgAttributes =
    case attributeValues.fontFamily of
        Nothing ->
            svgAttributes

        Just string ->
            Svg.Attributes.fontFamily string :: svgAttributes


addTextAnchor :
    AttributeValues units coordinates event
    -> List (Svg.Attribute event)
    -> List (Svg.Attribute event)
addTextAnchor attributeValues svgAttributes =
    case attributeValues.textAnchor of
        Nothing ->
            svgAttributes

        Just position ->
            Svg.Attributes.textAnchor position.x
                :: Svg.Attributes.dominantBaseline position.y
                :: svgAttributes


addCurveAttributes :
    AttributeValues units coordinates event
    -> List (Svg.Attribute event)
    -> List (Svg.Attribute event)
addCurveAttributes attributeValues svgAttributes =
    svgAttributes
        |> addStrokeStyle attributeValues
        |> addStrokeWidth attributeValues
        |> addStrokeLineJoin attributeValues
        |> addStrokeLineCap attributeValues
        |> addStrokeDashPattern attributeValues
        |> addShadowFilter attributeValues
        |> addEventHandlers attributeValues


addRegionAttributes :
    Bool
    -> AttributeValues units coordinates event
    -> List (Svg.Attribute event)
    -> List (Svg.Attribute event)
addRegionAttributes bordersVisible attributeValues svgAttributes =
    let
        commonAttributes =
            svgAttributes
                |> addFillStyle attributeValues
                |> addShadowFilter attributeValues
                |> addEventHandlers attributeValues
    in
    if bordersVisible then
        commonAttributes |> addCurveAttributes attributeValues

    else
        noStroke :: commonAttributes


addGroupAttributes :
    AttributeValues units coordinates event
    -> List (Svg.Attribute event)
    -> List (Svg.Attribute event)
addGroupAttributes attributeValues svgAttributes =
    svgAttributes
        |> addFillStyle attributeValues
        |> addFontFamily attributeValues
        |> addFontSize attributeValues
        |> addStrokeStyle attributeValues
        |> addStrokeWidth attributeValues
        |> addStrokeLineJoin attributeValues
        |> addStrokeLineCap attributeValues
        |> addStrokeDashPattern attributeValues
        |> addTextAnchor attributeValues
        |> addTextColor attributeValues
        |> addShadowFilter attributeValues
        |> addEventHandlers attributeValues


addTextAttributes :
    AttributeValues units coordinates event
    -> List (Svg.Attribute event)
    -> List (Svg.Attribute event)
addTextAttributes attributeValues svgAttributes =
    svgAttributes
        |> addFontFamily attributeValues
        |> addFontSize attributeValues
        |> addTextAnchor attributeValues
        |> addTextColor attributeValues
        |> addShadowFilter attributeValues
        |> addEventHandlers attributeValues


addEventHandlers :
    AttributeValues units coordinates event
    -> List (Svg.Attribute event)
    -> List (Svg.Attribute event)
addEventHandlers attributeValues svgAttributes =
    Dict.foldl addEventHandler svgAttributes attributeValues.eventHandlers
        |> suppressTouchActions attributeValues


addEventHandler : String -> List (Decoder event) -> List (Svg.Attribute event) -> List (Svg.Attribute event)
addEventHandler eventName decoders svgAttributes =
    on eventName (Decode.oneOf decoders) :: svgAttributes


suppressTouchActions :
    AttributeValues units coordinates event
    -> List (Svg.Attribute event)
    -> List (Svg.Attribute event)
suppressTouchActions attributeValues svgAttributes =
    if
        Dict.member "touchstart" attributeValues.eventHandlers
            || Dict.member "touchmove" attributeValues.eventHandlers
            || Dict.member "touchend" attributeValues.eventHandlers
    then
        Html.Attributes.style "touch-action" "none" :: svgAttributes

    else
        svgAttributes


on : String -> Decoder event -> Svg.Attribute event
on eventName decoder =
    Svg.Events.custom eventName (preventDefaultAndStopPropagation decoder)


preventDefaultAndStopPropagation :
    Decoder msg
    -> Decoder { message : msg, preventDefault : Bool, stopPropagation : Bool }
preventDefaultAndStopPropagation =
    Decode.map (\message -> { message = message, preventDefault = True, stopPropagation = True })
