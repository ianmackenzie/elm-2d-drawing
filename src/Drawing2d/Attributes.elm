module Drawing2d.Attributes exposing
    ( Attribute(..)
    , AttributeValues
    , Cursor(..)
    , DrawingCoordinates
    , DrawingUnits
    , Event(..)
    , Fill(..)
    , LineCap(..)
    , LineJoin(..)
    , Stroke(..)
    , assignAttributes
    , collectAttributeValues
    , curveAttributes
    , dashPatternSvgAttribute
    , emptyAttributeValues
    , groupAttributes
    , imageAttributes
    , regionAttributes
    , textAttributes
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


type DrawingUnits
    = DrawingUnits


type DrawingCoordinates
    = DrawingCoordinates


type Event msg
    = Event (Rectangle2d DrawingUnits DrawingCoordinates -> msg)


type Cursor
    = AutoCursor
    | DefaultCursor
    | NoCursor
    | ContextMenuCursor
    | HelpCursor
    | PointerCursor
    | ProgressCursor
    | WaitCursor
    | CellCursor
    | CrosshairCursor
    | TextCursor
    | VerticalTextCursor
    | AliasCursor
    | CopyCursor
    | MoveCursor
    | NoDropCursor
    | NotAllowedCursor
    | GrabCursor
    | GrabbingCursor
    | AllScrollCursor
    | ColResizeCursor
    | RowResizeCursor
    | NResizeCursor
    | EResizeCursor
    | SResizeCursor
    | WResizeCursor
    | NeResizeCursor
    | NwResizeCursor
    | SeResizeCursor
    | SwResizeCursor
    | EwResizeCursor
    | NsResizeCursor
    | NeswResizeCursor
    | NwseResizeCursor
    | ZoomInCursor
    | ZoomOutCursor
    | ImageCursor String Float Float Cursor


type Attribute units coordinates msg
    = FillStyle (Fill units coordinates) -- Svg.Attributes.fill
    | StrokeStyle (Stroke units coordinates) -- Svg.Attributes.stroke
    | Opacity Float
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
    | Cursor Cursor -- Svg.Attributes.cursor
    | EventHandlers (List ( String, Decoder (Event msg) ))


type alias AttributeValues units coordinates msg =
    { fillStyle : Maybe (Fill units coordinates)
    , strokeStyle : Maybe (Stroke units coordinates)
    , opacity : Maybe Float
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
    , cursor : Maybe Cursor
    , eventHandlers : Dict String (List (Decoder (Event msg)))
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
    , fontFamily = Nothing
    , textAnchor = Nothing
    , cursor = Nothing
    , eventHandlers = Dict.empty
    }


setAttribute :
    Attribute units coordinates msg
    -> AttributeValues units coordinates msg
    -> AttributeValues units coordinates msg
setAttribute attribute attributeValues =
    case attribute of
        FillStyle fill ->
            { attributeValues | fillStyle = Just fill }

        StrokeStyle stroke ->
            { attributeValues | strokeStyle = Just stroke }

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

        Cursor cursor ->
            { attributeValues | cursor = Just cursor }

        EventHandlers eventHandlers ->
            List.foldl registerEventHandler attributeValues eventHandlers


registerEventHandler : ( String, Decoder (Event msg) ) -> AttributeValues units coordinates msg -> AttributeValues units coordinates msg
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


noStroke : Svg.Attribute (Event msg)
noStroke =
    Svg.Attributes.stroke "none"


noFill : Svg.Attribute (Event msg)
noFill =
    Svg.Attributes.fill "none"


addFillStyle :
    AttributeValues units coordinates msg
    -> List (Svg.Attribute (Event msg))
    -> List (Svg.Attribute (Event msg))
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
    AttributeValues units coordinates msg
    -> List (Svg.Attribute (Event msg))
    -> List (Svg.Attribute (Event msg))
addStrokeStyle attributeValues svgAttributes =
    case attributeValues.strokeStyle of
        Nothing ->
            svgAttributes

        Just (StrokeColor string) ->
            Svg.Attributes.stroke string :: svgAttributes

        Just (StrokeGradient gradient) ->
            Svg.Attributes.stroke (Gradient.reference gradient) :: svgAttributes


addOpacity :
    AttributeValues units coordinates msg
    -> List (Svg.Attribute (Event msg))
    -> List (Svg.Attribute (Event msg))
addOpacity attributeValues svgAttributes =
    case attributeValues.opacity of
        Nothing ->
            svgAttributes

        Just opacity ->
            Svg.Attributes.opacity (String.fromFloat opacity) :: svgAttributes


addFontSize :
    AttributeValues units coordinates msg
    -> List (Svg.Attribute (Event msg))
    -> List (Svg.Attribute (Event msg))
addFontSize attributeValues svgAttributes =
    case attributeValues.fontSize of
        Nothing ->
            svgAttributes

        Just size ->
            Svg.Attributes.fontSize (String.fromFloat size) :: svgAttributes


addStrokeWidth :
    AttributeValues units coordinates msg
    -> List (Svg.Attribute (Event msg))
    -> List (Svg.Attribute (Event msg))
addStrokeWidth attributeValues svgAttributes =
    case attributeValues.strokeWidth of
        Nothing ->
            svgAttributes

        Just width ->
            Svg.Attributes.strokeWidth (String.fromFloat width) :: svgAttributes


addShadowFilter :
    AttributeValues units coordinates msg
    -> List (Svg.Attribute (Event msg))
    -> List (Svg.Attribute (Event msg))
addShadowFilter attributeValues svgAttributes =
    case attributeValues.dropShadow of
        Nothing ->
            svgAttributes

        Just shadow ->
            Svg.Attributes.filter (Shadow.reference shadow) :: svgAttributes


lineJoinString : LineJoin -> String
lineJoinString lineJoin =
    case lineJoin of
        BevelJoin ->
            "bevel"

        RoundJoin ->
            "round"

        MiterJoin ->
            "miter"


lineCapString : LineCap -> String
lineCapString lineJoin =
    case lineJoin of
        NoCap ->
            "butt"

        SquareCap ->
            "square"

        RoundCap ->
            "round"


addStrokeLineJoin :
    AttributeValues units coordinates msg
    -> List (Svg.Attribute (Event msg))
    -> List (Svg.Attribute (Event msg))
addStrokeLineJoin attributeValues svgAttributes =
    case attributeValues.strokeLineJoin of
        Nothing ->
            svgAttributes

        Just lineJoin ->
            Svg.Attributes.strokeLinejoin (lineJoinString lineJoin) :: svgAttributes


addStrokeLineCap :
    AttributeValues units coordinates msg
    -> List (Svg.Attribute (Event msg))
    -> List (Svg.Attribute (Event msg))
addStrokeLineCap attributeValues svgAttributes =
    case attributeValues.strokeLineCap of
        Nothing ->
            svgAttributes

        Just lineCap ->
            Svg.Attributes.strokeLinecap (lineCapString lineCap) :: svgAttributes


addStrokeDashPattern :
    AttributeValues units coordinates msg
    -> List (Svg.Attribute (Event msg))
    -> List (Svg.Attribute (Event msg))
addStrokeDashPattern attributeValues svgAttributes =
    case attributeValues.strokeDashPattern of
        Nothing ->
            svgAttributes

        Just dashPattern ->
            dashPatternSvgAttribute dashPattern :: svgAttributes


dashPatternSvgAttribute : List Float -> Svg.Attribute (Event msg)
dashPatternSvgAttribute dashPattern =
    case dashPattern of
        [] ->
            Svg.Attributes.strokeDasharray "none"

        _ ->
            Svg.Attributes.strokeDasharray (String.join " " (List.map String.fromFloat dashPattern))


addTextColor :
    AttributeValues units coordinates msg
    -> List (Svg.Attribute (Event msg))
    -> List (Svg.Attribute (Event msg))
addTextColor attributeValues svgAttributes =
    case attributeValues.textColor of
        Nothing ->
            svgAttributes

        Just string ->
            Svg.Attributes.color string :: svgAttributes


addFontFamily :
    AttributeValues units coordinates msg
    -> List (Svg.Attribute (Event msg))
    -> List (Svg.Attribute (Event msg))
addFontFamily attributeValues svgAttributes =
    case attributeValues.fontFamily of
        Nothing ->
            svgAttributes

        Just string ->
            Svg.Attributes.fontFamily string :: svgAttributes


addTextAnchor :
    AttributeValues units coordinates msg
    -> List (Svg.Attribute (Event msg))
    -> List (Svg.Attribute (Event msg))
addTextAnchor attributeValues svgAttributes =
    case attributeValues.textAnchor of
        Nothing ->
            svgAttributes

        Just position ->
            Svg.Attributes.textAnchor position.x
                :: Svg.Attributes.dominantBaseline position.y
                :: svgAttributes


addCursor :
    AttributeValues units coordinates msg
    -> List (Svg.Attribute (Event msg))
    -> List (Svg.Attribute (Event msg))
addCursor attributeValues svgAttributes =
    case attributeValues.cursor of
        Nothing ->
            svgAttributes

        Just cursor ->
            let
                cursorAttribute =
                    Svg.Attributes.cursor (cursorString cursor)
            in
            cursorAttribute :: svgAttributes


cursorString : Cursor -> String
cursorString cursor =
    case cursor of
        AutoCursor ->
            "auto"

        DefaultCursor ->
            "default"

        NoCursor ->
            "none"

        ContextMenuCursor ->
            "context-menu"

        HelpCursor ->
            "help"

        PointerCursor ->
            "pointer"

        ProgressCursor ->
            "progress"

        WaitCursor ->
            "wait"

        CellCursor ->
            "cell"

        CrosshairCursor ->
            "crosshair"

        TextCursor ->
            "text"

        VerticalTextCursor ->
            "vertical-text"

        AliasCursor ->
            "alias"

        CopyCursor ->
            "copy"

        MoveCursor ->
            "move"

        NoDropCursor ->
            "no-drop"

        NotAllowedCursor ->
            "not-allowed"

        GrabCursor ->
            "grab"

        GrabbingCursor ->
            "grabbing"

        AllScrollCursor ->
            "all-scroll"

        ColResizeCursor ->
            "col-resize"

        RowResizeCursor ->
            "row-resize"

        NResizeCursor ->
            "n-resize"

        EResizeCursor ->
            "e-resize"

        SResizeCursor ->
            "s-resize"

        WResizeCursor ->
            "w-resize"

        NeResizeCursor ->
            "ne-resize"

        NwResizeCursor ->
            "nw-resize"

        SeResizeCursor ->
            "se-resize"

        SwResizeCursor ->
            "sw-resize"

        EwResizeCursor ->
            "ew-resize"

        NsResizeCursor ->
            "ns-resize"

        NeswResizeCursor ->
            "nesw-resize"

        NwseResizeCursor ->
            "nwse-resize"

        ZoomInCursor ->
            "zoom-in"

        ZoomOutCursor ->
            "zoom-out"

        ImageCursor url x y fallback ->
            "url"
                ++ "("
                ++ url
                ++ ") "
                ++ String.fromFloat x
                ++ " "
                ++ String.fromFloat y
                ++ ", "
                ++ cursorString fallback


addGenericAttributes :
    AttributeValues units coordinates msg
    -> List (Svg.Attribute (Event msg))
    -> List (Svg.Attribute (Event msg))
addGenericAttributes attributeValues svgAttributes =
    svgAttributes
        |> addShadowFilter attributeValues
        |> addCursor attributeValues
        |> addOpacity attributeValues
        |> addEventHandlers attributeValues


addStrokeAttributes :
    AttributeValues units coordinates msg
    -> List (Svg.Attribute (Event msg))
    -> List (Svg.Attribute (Event msg))
addStrokeAttributes attributeValues svgAttributes =
    svgAttributes
        |> addStrokeStyle attributeValues
        |> addStrokeWidth attributeValues
        |> addStrokeLineJoin attributeValues
        |> addStrokeLineCap attributeValues
        |> addStrokeDashPattern attributeValues


curveAttributes :
    AttributeValues units coordinates msg
    -> List (Svg.Attribute (Event msg))
curveAttributes attributeValues =
    [ noFill ]
        |> addGenericAttributes attributeValues
        |> addStrokeAttributes attributeValues


regionAttributes :
    Bool
    -> AttributeValues units coordinates msg
    -> List (Svg.Attribute (Event msg))
regionAttributes bordersVisible attributeValues =
    let
        commonAttributes =
            []
                |> addGenericAttributes attributeValues
                |> addFillStyle attributeValues
    in
    if bordersVisible then
        addStrokeAttributes attributeValues commonAttributes

    else
        noStroke :: commonAttributes


groupAttributes :
    AttributeValues units coordinates msg
    -> List (Svg.Attribute (Event msg))
groupAttributes attributeValues =
    []
        |> addGenericAttributes attributeValues
        |> addStrokeAttributes attributeValues
        |> addFillStyle attributeValues
        |> addTextAttributes attributeValues


addTextAttributes :
    AttributeValues units coordinates msg
    -> List (Svg.Attribute (Event msg))
    -> List (Svg.Attribute (Event msg))
addTextAttributes attributeValues svgAttributes =
    svgAttributes
        |> addFontFamily attributeValues
        |> addFontSize attributeValues
        |> addTextAnchor attributeValues
        |> addTextColor attributeValues


currentColorFill : Svg.Attribute (Event msg)
currentColorFill =
    Svg.Attributes.fill "currentColor"


textAttributes :
    AttributeValues units coordinates msg
    -> List (Svg.Attribute (Event msg))
textAttributes attributeValues =
    [ currentColorFill, noStroke ]
        |> addGenericAttributes attributeValues
        |> addTextAttributes attributeValues


imageAttributes : AttributeValues units coordinates msg -> List (Svg.Attribute (Event msg))
imageAttributes attributeValues =
    addGenericAttributes attributeValues []


addEventHandlers :
    AttributeValues units coordinates msg
    -> List (Svg.Attribute (Event msg))
    -> List (Svg.Attribute (Event msg))
addEventHandlers attributeValues svgAttributes =
    Dict.foldl addEventHandler svgAttributes attributeValues.eventHandlers
        |> suppressTouchActions attributeValues


addEventHandler :
    String
    -> List (Decoder (Event msg))
    -> List (Svg.Attribute (Event msg))
    -> List (Svg.Attribute (Event msg))
addEventHandler eventName decoders svgAttributes =
    on eventName (Decode.oneOf decoders) :: svgAttributes


suppressTouchActions :
    AttributeValues units coordinates msg
    -> List (Svg.Attribute (Event msg))
    -> List (Svg.Attribute (Event msg))
suppressTouchActions attributeValues svgAttributes =
    if
        Dict.member "touchstart" attributeValues.eventHandlers
            || Dict.member "touchmove" attributeValues.eventHandlers
            || Dict.member "touchend" attributeValues.eventHandlers
    then
        Html.Attributes.style "touch-action" "none" :: svgAttributes

    else
        svgAttributes


on : String -> Decoder (Event msg) -> Svg.Attribute (Event msg)
on eventName decoder =
    Svg.Events.custom eventName (preventDefaultAndStopPropagation decoder)


preventDefaultAndStopPropagation :
    Decoder msg
    -> Decoder { message : msg, preventDefault : Bool, stopPropagation : Bool }
preventDefaultAndStopPropagation =
    Decode.map (\message -> { message = message, preventDefault = True, stopPropagation = True })
