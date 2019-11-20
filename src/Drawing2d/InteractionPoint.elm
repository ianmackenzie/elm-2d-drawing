module Drawing2d.InteractionPoint exposing
    ( ReferencePoint
    , position
    , referencePoint
    , startPosition
    , updatedPosition
    )

import BoundingBox2d exposing (BoundingBox2d)
import DOM
import Json.Decode as Decode exposing (Decoder)
import Pixels exposing (Pixels, inPixels, pixels)
import Point2d exposing (Point2d)
import Vector2d exposing (Vector2d)


type ReferencePoint
    = ReferencePoint
        { pageX : Float
        , pageY : Float
        , drawingPoint : { x : Float, y : Float }
        , drawingScale : Float
        }


referencePoint :
    { a | clientX : Float, clientY : Float, pageX : Float, pageY : Float }
    -> BoundingBox2d Pixels drawingCoordinates
    -> DOM.Rectangle
    -> ReferencePoint
referencePoint startEvent viewBox container =
    let
        -- Dimensions of the displayed portion of the drawing, in drawing units
        ( drawingWidth, drawingHeight ) =
            BoundingBox2d.dimensions viewBox

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

        -- Center point of the displayed portion of the drawing, in drawing
        -- units; note that since the drawing is centered within its container,
        -- this will be coincident with the center point of the container
        drawingCenterPoint =
            BoundingBox2d.centerPoint viewBox

        -- clientX coordinate of the center point of the container
        centerPointClientX =
            container.left + container.width / 2

        -- clientY coordinate o fthe center point of the container
        centerPointClientY =
            container.top + container.height / 2

        -- displacement from the center point to the reference, in drawing units
        displacementToReference =
            Vector2d.pixels
                ((startEvent.clientX - centerPointClientX) / drawingScale)
                ((centerPointClientY - startEvent.clientY) / drawingScale)

        -- position of the reference point, in drawing units
        drawingPoint =
            drawingCenterPoint |> Point2d.translateBy displacementToReference
    in
    ReferencePoint
        { pageX = startEvent.pageX
        , pageY = startEvent.pageY
        , drawingScale = drawingScale
        , drawingPoint = Point2d.toPixels drawingPoint
        }


startPosition : ReferencePoint -> Point2d Pixels drawingCoordinates
startPosition (ReferencePoint reference) =
    Point2d.fromPixels reference.drawingPoint


position :
    { a | clientX : Float, clientY : Float, pageX : Float, pageY : Float }
    -> BoundingBox2d Pixels drawingCoordinates
    -> DOM.Rectangle
    -> Point2d Pixels drawingCoordinates
position startEvent viewBox container =
    let
        (ReferencePoint reference) =
            referencePoint startEvent viewBox container
    in
    Point2d.fromPixels reference.drawingPoint


updatedPosition :
    ReferencePoint
    -> { a | pageX : Float, pageY : Float }
    -> Point2d Pixels drawingCoordinates
updatedPosition (ReferencePoint reference) { pageX, pageY } =
    let
        displacementFromReference =
            Vector2d.pixels
                ((pageX - reference.pageX) / reference.drawingScale)
                ((reference.pageY - pageY) / reference.drawingScale)
    in
    Point2d.fromPixels reference.drawingPoint |> Point2d.translateBy displacementFromReference
