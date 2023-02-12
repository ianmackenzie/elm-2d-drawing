module Drawing2d.Wheel exposing
    ( Delta(..)
    , decoder
    , inPixels
    )

import Json.Decode as Decode exposing (Decoder)


type Delta
    = Pixels Float
    | Lines Float
    | Pages Float


{-| Normalize deltaY property of 'wheel' event to a reasonable value in pixels;
adapted from <https://gist.github.com/akella/11574989a9f3cc9e0ad47e401c12ccaf>
-}
inPixels : Delta -> Float
inPixels delta =
    case delta of
        Pixels pixels ->
            pixels

        Lines lines ->
            40 * lines

        Pages pages ->
            800 * pages


deltaMode : Decoder (Float -> Delta)
deltaMode =
    Decode.field "deltaMode" Decode.int
        |> Decode.andThen
            (\value ->
                case value of
                    0 ->
                        Decode.succeed Pixels

                    1 ->
                        Decode.succeed Lines

                    2 ->
                        Decode.succeed Pages

                    _ ->
                        Decode.fail ("Unrecognized deltaMode value: " ++ String.fromInt value ++ " (expected 0, 1 or 2)")
            )


decoder : Decoder Delta
decoder =
    Decode.map2 (<|) deltaMode deltaY


deltaY : Decoder Float
deltaY =
    Decode.field "deltaY" Decode.float
