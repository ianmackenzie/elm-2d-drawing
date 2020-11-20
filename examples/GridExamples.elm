module GridExamples exposing (main)

import Array
import Circle2d
import Color
import Drawing2d
import Html exposing (Html)
import LineSegment2d
import Pixels
import Point2d
import Rectangle2d
import Round
import TriangularMesh
import Vector2d


main : Html msg
main =
    let
        viewBox =
            Rectangle2d.from Point2d.origin (Point2d.pixels 400 300)

        rectangle =
            Rectangle2d.centeredOn (Rectangle2d.axes viewBox)
                ( Pixels.float 300, Pixels.float 200 )

        format x =
            if x == 0 then
                "0"

            else if x == 0.5 then
                "0.5"

            else if x == 1 then
                "1"

            else
                Round.round 2 x

        vertex u v =
            { position = Rectangle2d.interpolate rectangle u v
            , text = "f " ++ format u ++ " " ++ format v
            }

        indexedVertex i j =
            { position = Rectangle2d.interpolate rectangle (toFloat i / 3) (toFloat j / 2)
            , text = "f " ++ String.fromInt i ++ " " ++ String.fromInt j
            }

        mesh =
            TriangularMesh.indexedGrid 3 2 indexedVertex

        lines =
            TriangularMesh.edgeVertices mesh
                |> List.map
                    (\( v1, v2 ) ->
                        Drawing2d.lineSegment [] (LineSegment2d.from v1.position v2.position)
                    )

        vertices =
            TriangularMesh.vertices mesh
                |> Array.toList
                |> List.map
                    (\{ position, text } ->
                        Drawing2d.group []
                            [ Drawing2d.circle [ Drawing2d.whiteFill ] <|
                                Circle2d.withRadius (Pixels.float 4) position
                            , Drawing2d.text [ Drawing2d.textAnchor Drawing2d.topLeft ]
                                (position |> Point2d.translateBy (Vector2d.pixels 2 -2))
                                text
                            ]
                    )
    in
    Drawing2d.draw
        { viewBox = viewBox
        , background = Drawing2d.noBackground
        , attributes =
            [ Drawing2d.fontSize (Pixels.float 12)
            , Drawing2d.fontFamily [ "monospace" ]
            ]
        , elements =
            [ Drawing2d.group [ Drawing2d.strokeColor Color.darkGrey ] lines
            , Drawing2d.group [ Drawing2d.strokeColor Color.charcoal ] vertices
            ]
        }
