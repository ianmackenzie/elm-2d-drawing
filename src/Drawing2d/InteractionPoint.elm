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
import Rectangle2d exposing (Rectangle2d)
import Vector2d exposing (Vector2d)


type ReferencePoint drawingCoordinates
    = ReferencePoint
        { pageX : Float
        , pageY : Float
        , drawingPoint : Point2d Pixels drawingCoordinates
        , drawingScale : Float
        }


referencePoint :
    { a | clientX : Float, clientY : Float, pageX : Float, pageY : Float }
    -> Rectangle2d Pixels drawingCoordinates
    -> DOM.Rectangle
    -> ReferencePoint drawingCoordinates
referencePoint startEvent viewBox container =
    let
        -- Dimensions of the displayed portion of the drawing, in drawing units
        ( drawingWidth, drawingHeight ) =
            Rectangle2d.dimensions viewBox

        -- Drawing scale assuming the drawing is the full width of its
        -- container
        xScale =
            container.width / inPixels drawingWidth

        -- Drawing scale assuming the drawing is the full height of its
        -- container
        yScale =
            container.height / inPixels drawingHeight

        -- Actual drawing scale is the minimum of those two (since the
        -- drawing fits within its container)
        drawingScale =
            min xScale yScale

        -- clientX coordinate of the center point of the container
        centerPointClientX =
            container.left + container.width / 2

        -- clientY coordinate o fthe center point of the container
        centerPointClientY =
            container.top + container.height / 2

        -- position of the reference point, in drawing units
        drawingPoint =
            Point2d.xyIn (Rectangle2d.axes viewBox)
                (pixels ((startEvent.clientX - centerPointClientX) / drawingScale))
                (pixels ((centerPointClientY - startEvent.clientY) / drawingScale))
    in
    ReferencePoint
        { pageX = startEvent.pageX
        , pageY = startEvent.pageY
        , drawingScale = drawingScale
        , drawingPoint = drawingPoint
        }


startPosition : ReferencePoint drawingCoordinates -> Point2d Pixels drawingCoordinates
startPosition (ReferencePoint reference) =
    reference.drawingPoint


position :
    { a | clientX : Float, clientY : Float, pageX : Float, pageY : Float }
    -> Rectangle2d Pixels drawingCoordinates
    -> DOM.Rectangle
    -> Point2d Pixels drawingCoordinates
position startEvent viewBox container =
    let
        (ReferencePoint reference) =
            referencePoint startEvent viewBox container
    in
    reference.drawingPoint


updatedPosition :
    ReferencePoint drawingCoordinates
    -> { a | pageX : Float, pageY : Float }
    -> Point2d Pixels drawingCoordinates
updatedPosition (ReferencePoint reference) { pageX, pageY } =
    let
        displacementFromReference =
            Vector2d.pixels
                ((pageX - reference.pageX) / reference.drawingScale)
                ((reference.pageY - pageY) / reference.drawingScale)
    in
    reference.drawingPoint |> Point2d.translateBy displacementFromReference
