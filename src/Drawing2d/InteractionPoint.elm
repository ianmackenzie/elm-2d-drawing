module Drawing2d.InteractionPoint exposing
    ( ReferencePoint
    , position
    , referencePoint
    , startPosition
    , updatedPosition
    )

import DOM
import Json.Decode as Decode exposing (Decoder)
import Pixels exposing (Pixels, inPixels, pixels)
import Point2d exposing (Point2d)
import Quantity exposing (Quantity(..))
import Rectangle2d exposing (Rectangle2d)
import Vector2d exposing (Vector2d)


type ReferencePoint drawingUnits drawingCoordinates
    = ReferencePoint
        { pageX : Float
        , pageY : Float
        , viewBox : Rectangle2d drawingUnits drawingCoordinates
        , drawingPoint : Point2d drawingUnits drawingCoordinates
        , drawingScale : Float
        }


referencePoint :
    { a | clientX : Float, clientY : Float, pageX : Float, pageY : Float }
    -> Rectangle2d drawingUnits drawingCoordinates
    -> DOM.Rectangle
    -> ReferencePoint drawingUnits drawingCoordinates
referencePoint startEvent viewBox container =
    let
        -- Dimensions of the displayed portion of the drawing, in drawing units
        ( Quantity drawingWidth, Quantity drawingHeight ) =
            Rectangle2d.dimensions viewBox

        -- Drawing scale assuming the drawing is the full width of its
        -- container
        xScale =
            container.width / drawingWidth

        -- Drawing scale assuming the drawing is the full height of its
        -- container
        yScale =
            container.height / drawingHeight

        -- Actual drawing scale is the minimum of those two (since the
        -- drawing fits within its container)
        drawingScale =
            min xScale yScale

        -- clientX coordinate of the center point of the container
        centerPointClientX =
            container.left + container.width / 2

        -- clientY coordinate of the center point of the container
        centerPointClientY =
            container.top + container.height / 2

        -- position of the reference point, in drawing units
        drawingPoint =
            Point2d.xyIn (Rectangle2d.axes viewBox)
                (Quantity ((startEvent.clientX - centerPointClientX) / drawingScale))
                (Quantity ((centerPointClientY - startEvent.clientY) / drawingScale))
    in
    ReferencePoint
        { pageX = startEvent.pageX
        , pageY = startEvent.pageY
        , viewBox = viewBox
        , drawingScale = drawingScale
        , drawingPoint = drawingPoint
        }


startPosition : ReferencePoint drawingUnits drawingCoordinates -> Point2d drawingUnits drawingCoordinates
startPosition (ReferencePoint reference) =
    reference.drawingPoint


position :
    { a | clientX : Float, clientY : Float, pageX : Float, pageY : Float }
    -> Rectangle2d drawingUnits drawingCoordinates
    -> DOM.Rectangle
    -> Point2d drawingUnits drawingCoordinates
position startEvent viewBox container =
    let
        (ReferencePoint reference) =
            referencePoint startEvent viewBox container
    in
    reference.drawingPoint


updatedPosition :
    ReferencePoint drawingUnits drawingCoordinates
    -> { a | pageX : Float, pageY : Float }
    -> Point2d drawingUnits drawingCoordinates
updatedPosition (ReferencePoint reference) { pageX, pageY } =
    let
        displacementFromReference =
            Vector2d.xyIn (Rectangle2d.axes reference.viewBox)
                (Quantity ((pageX - reference.pageX) / reference.drawingScale))
                (Quantity ((reference.pageY - pageY) / reference.drawingScale))
    in
    reference.drawingPoint |> Point2d.translateBy displacementFromReference
