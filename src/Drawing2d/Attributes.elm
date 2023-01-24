module Drawing2d.Attributes exposing
    ( Attribute(..)
    , AttributeValues
    , assignAttributes
    , collectAttributeValues
    , curveAttributes
    , emptyAttributeValues
    , groupAttributes
    , imageAttributes
    , regionAttributes
    , textAttributes
    )

import BoundingBox2d exposing (BoundingBox2d)
import Color exposing (Color)
import Dict exposing (Dict)
import Drawing2d.Cursor as Cursor exposing (Cursor)
import Drawing2d.Event as Event exposing (Event)
import Drawing2d.FillStyle as FillStyle exposing (FillStyle)
import Drawing2d.FontFamily as FontFamily exposing (FontFamily)
import Drawing2d.Gradient as Gradient
import Drawing2d.LineCap as LineCap exposing (LineCap)
import Drawing2d.LineJoin as LineJoin exposing (LineJoin)
import Drawing2d.MouseInteraction.Protected exposing (MouseInteraction(..))
import Drawing2d.Render as Render
import Drawing2d.RenderedSvg as RenderedSvg exposing (RenderedSvg)
import Drawing2d.Shadow as Shadow exposing (Shadow)
import Drawing2d.StrokeDashPattern as StrokeDashPattern exposing (StrokeDashPattern)
import Drawing2d.StrokeStyle as StrokeStyle exposing (StrokeStyle)
import Drawing2d.TouchInteraction.Protected exposing (TouchInteraction(..))
import Duration exposing (Duration)
import Frame2d exposing (Frame2d)
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


type Attribute units coordinates msg
    = Fill (FillStyle units coordinates) -- Svg.Attributes.fill
    | Stroke (StrokeStyle units coordinates) -- Svg.Attributes.stroke
    | Opacity Float
    | FontSize (Quantity Float units)
    | StrokeWidth (Quantity Float units)
    | StrokeLineJoin LineJoin
    | StrokeLineCap LineCap
    | DashPattern (StrokeDashPattern units)
    | BorderVisibility Bool
    | DropShadow (Shadow units coordinates)
    | TextColor Color -- Svg.Attributes.color
    | FontWeight Int -- Svg.Attributes.fontWeight
    | FontFamily FontFamily -- Svg.Attributes.fontFamily
    | TextAnchor String -- Svg.Attributes.textAnchor
    | DominantBaseline String -- Svg.Attributes.dominantBaseline
    | Cursor Cursor -- Svg.Attributes.cursor
    | EventHandlers (List ( String, Decoder (Event units coordinates msg) ))


type alias AttributeValues units coordinates msg =
    { fillStyle : Maybe (FillStyle units coordinates)
    , strokeStyle : Maybe (StrokeStyle units coordinates)
    , opacity : Maybe Float
    , fontSize : Maybe (Quantity Float units)
    , strokeWidth : Maybe (Quantity Float units)
    , strokeLineJoin : Maybe LineJoin
    , strokeLineCap : Maybe LineCap
    , strokeDashPattern : Maybe (StrokeDashPattern units)
    , borderVisibility : Maybe Bool
    , dropShadow : Maybe (Shadow units coordinates)
    , textColor : Maybe Color
    , fontWeight : Maybe Int
    , fontFamily : Maybe FontFamily
    , textAnchor : Maybe String
    , dominantBaseline : Maybe String
    , cursor : Maybe Cursor
    , eventHandlers : Dict String (List (Decoder (Event units coordinates msg)))
    }


emptyAttributeValues : AttributeValues units coordinates msg
emptyAttributeValues =
    { fillStyle = Nothing
    , strokeStyle = Nothing
    , opacity = Nothing
    , fontSize = Nothing
    , strokeWidth = Nothing
    , strokeLineJoin = Nothing
    , strokeLineCap = Nothing
    , strokeDashPattern = Nothing
    , borderVisibility = Nothing
    , dropShadow = Nothing
    , textColor = Nothing
    , fontWeight = Nothing
    , fontFamily = Nothing
    , textAnchor = Nothing
    , dominantBaseline = Nothing
    , cursor = Nothing
    , eventHandlers = Dict.empty
    }


setAttribute :
    Attribute units coordinates msg
    -> AttributeValues units coordinates msg
    -> AttributeValues units coordinates msg
setAttribute attribute attributeValues =
    case attribute of
        Fill fillStyle ->
            { attributeValues | fillStyle = Just fillStyle }

        Stroke strokeStyle ->
            { attributeValues | strokeStyle = Just strokeStyle }

        Opacity opacity ->
            { attributeValues | opacity = Just opacity }

        FontSize size ->
            { attributeValues | fontSize = Just size }

        StrokeWidth width ->
            { attributeValues | strokeWidth = Just width }

        StrokeLineJoin lineJoin ->
            { attributeValues | strokeLineJoin = Just lineJoin }

        StrokeLineCap lineCap ->
            { attributeValues | strokeLineCap = Just lineCap }

        DashPattern strokeDashPattern ->
            { attributeValues | strokeDashPattern = Just strokeDashPattern }

        BorderVisibility bordersVisible ->
            { attributeValues | borderVisibility = Just bordersVisible }

        DropShadow shadow ->
            { attributeValues | dropShadow = Just shadow }

        TextColor string ->
            { attributeValues | textColor = Just string }

        FontWeight weight ->
            { attributeValues | fontWeight = Just weight }

        FontFamily fontFamily ->
            { attributeValues | fontFamily = Just fontFamily }

        TextAnchor string ->
            { attributeValues | textAnchor = Just string }

        DominantBaseline string ->
            { attributeValues | dominantBaseline = Just string }

        Cursor cursor ->
            { attributeValues | cursor = Just cursor }

        EventHandlers eventHandlers ->
            List.foldl registerEventHandler attributeValues eventHandlers


registerEventHandler : ( String, Decoder (Event units coordinates msg) ) -> AttributeValues units coordinates msg -> AttributeValues units coordinates msg
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
    List (Attribute units coordinates msg)
    -> AttributeValues units coordinates msg
collectAttributeValues attributeList =
    assignAttributes attributeList emptyAttributeValues


assignAttributes :
    List (Attribute units coordinates msg)
    -> AttributeValues units coordinates msg
    -> AttributeValues units coordinates msg
assignAttributes attributeList attributeValues =
    List.foldr setAttribute attributeValues attributeList


noStroke : RenderedSvg units coordinates msg
noStroke =
    RenderedSvg.attributes [ Svg.Attributes.stroke "none" ]


noFill : RenderedSvg units coordinates msg
noFill =
    RenderedSvg.attributes [ Svg.Attributes.fill "none" ]


addTextAnchor :
    AttributeValues units coordinates msg
    -> List (Svg.Attribute (Event units coordinates msg))
    -> List (Svg.Attribute (Event units coordinates msg))
addTextAnchor attributeValues svgAttributes =
    case attributeValues.textAnchor of
        Nothing ->
            svgAttributes

        Just string ->
            Svg.Attributes.textAnchor string :: svgAttributes


addDominantBaseline :
    AttributeValues units coordinates msg
    -> List (Svg.Attribute (Event units coordinates msg))
    -> List (Svg.Attribute (Event units coordinates msg))
addDominantBaseline attributeValues svgAttributes =
    case attributeValues.dominantBaseline of
        Nothing ->
            svgAttributes

        Just string ->
            Svg.Attributes.dominantBaseline string :: svgAttributes


addGenericAttributes :
    AttributeValues units coordinates msg
    -> RenderedSvg units coordinates msg
    -> RenderedSvg units coordinates msg
addGenericAttributes attributeValues renderedSvg =
    renderedSvg
        |> RenderedSvg.add Shadow.render attributeValues.dropShadow
        |> RenderedSvg.add Render.cursor attributeValues.cursor
        |> RenderedSvg.add Render.opacity attributeValues.opacity
        |> RenderedSvg.add Render.eventHandlers (Just attributeValues.eventHandlers)


addStrokeAttributes :
    AttributeValues units coordinates msg
    -> RenderedSvg units coordinates msg
    -> RenderedSvg units coordinates msg
addStrokeAttributes attributeValues renderedSvg =
    renderedSvg
        |> RenderedSvg.add StrokeStyle.render attributeValues.strokeStyle
        |> RenderedSvg.add Render.strokeWidth attributeValues.strokeWidth
        |> RenderedSvg.add LineJoin.render attributeValues.strokeLineJoin
        |> RenderedSvg.add LineCap.render attributeValues.strokeLineCap
        |> RenderedSvg.add StrokeDashPattern.render attributeValues.strokeDashPattern


curveAttributes : AttributeValues units coordinates msg -> RenderedSvg units coordinates msg
curveAttributes attributeValues =
    noFill
        |> addGenericAttributes attributeValues
        |> addStrokeAttributes attributeValues


regionAttributes :
    Bool
    -> AttributeValues units coordinates msg
    -> RenderedSvg units coordinates msg
regionAttributes bordersVisible attributeValues =
    let
        commonAttributes =
            RenderedSvg.nothing
                |> addGenericAttributes attributeValues
                |> RenderedSvg.add FillStyle.render attributeValues.fillStyle
    in
    if bordersVisible then
        commonAttributes |> addStrokeAttributes attributeValues

    else
        RenderedSvg.merge [ noStroke, commonAttributes ]


groupAttributes :
    AttributeValues units coordinates msg
    -> RenderedSvg units coordinates msg
groupAttributes attributeValues =
    RenderedSvg.nothing
        |> addGenericAttributes attributeValues
        |> addStrokeAttributes attributeValues
        |> RenderedSvg.add FillStyle.render attributeValues.fillStyle
        |> addTextAttributes attributeValues


addTextAttributes :
    AttributeValues units coordinates msg
    -> RenderedSvg units coordinates msg
    -> RenderedSvg units coordinates msg
addTextAttributes attributeValues renderedSvg =
    renderedSvg
        |> RenderedSvg.add FontFamily.render attributeValues.fontFamily
        |> RenderedSvg.add Render.fontSize attributeValues.fontSize
        |> RenderedSvg.add Render.textAnchor attributeValues.textAnchor
        |> RenderedSvg.add Render.dominantBaseline attributeValues.dominantBaseline
        |> RenderedSvg.add Render.textColor attributeValues.textColor
        |> RenderedSvg.add Render.fontWeight attributeValues.fontWeight


genericTextAttributes : RenderedSvg units coordinates msg
genericTextAttributes =
    RenderedSvg.attributes [ Svg.Attributes.fill "currentColor", Svg.Attributes.stroke "none" ]


textAttributes : AttributeValues units coordinates msg -> RenderedSvg units coordinates msg
textAttributes attributeValues =
    genericTextAttributes
        |> addGenericAttributes attributeValues
        |> addTextAttributes attributeValues


imageAttributes : AttributeValues units coordinates msg -> RenderedSvg units coordinates msg
imageAttributes attributeValues =
    RenderedSvg.nothing
        |> addGenericAttributes attributeValues
