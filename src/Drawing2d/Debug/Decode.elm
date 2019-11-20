module Drawing2d.Debug.Decode exposing (debug)

import Json.Decode as Decode exposing (Decoder)


debug : Decoder a -> Decoder a
debug decoder =
    Decode.value
        |> Decode.andThen
            (\value ->
                case Decode.decodeValue decoder value of
                    Ok _ ->
                        decoder

                    Err error ->
                        let
                            _ =
                                Debug.log "Decoding failed" error
                        in
                        decoder
            )
