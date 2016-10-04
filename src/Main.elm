module Main exposing (..)

import Html exposing (Html, Attribute, button, div, text, h2, p, br, pre, code)
import Html.Attributes exposing (style)
import String
import Firewall


main : Html msg
main =
  div [ bodyStyle ]
    [ h2 [] [ text "Input:" ]
    , pre []
        [ code [] [ text input ]
        ]
    , h2 [] [ text "Output:" ]
    , pre []
        [ code [] [ (Firewall.parseLines >> text) input ]
        ]
    ]

bodyStyle : Attribute msg
bodyStyle =
  style
    [ ("margin", "0 auto")
    , ("width", "600px")
    , ("font-family", "Helvetica, Arial, sans-serif")
    ]

input : String
input =
  String.join "\n"
    [
      "10.0.0.1 1025 73.53.53.2 53",
      "10.0.0.1 1025 73.53.53.2 53",
      "10.0.0.1 1027 73.52.51.1 88",
      "10.0.0.2 1027 73.52.51.1 88",
      "10.0.0.2 1027 73.52.51.1 89",
      "10.0.0.1 1026 10.0.0.2 53",
      "10.0.0.1 1026 53.0.0.1 53",
      "73.53.53.2 53 53.0.0.1 1025",
      "73.53.53.2 53 53.0.0.1 53",
      "73.53.53.1 53 53.0.0.1 1025"
    ]
