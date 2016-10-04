module Main exposing (..)

import Html exposing (Html, Attribute, button, div, text, h2, p, br, pre, code, textarea)
import Html.Attributes exposing (style, value, rows)
import Html.Events exposing (onClick, onInput)
import String
import Firewall
import Html.App as App


main : Program Never
main =
  App.beginnerProgram
    { model = initModel
    , update = update
    , view = view
    }

type alias Model =
  { input : String
  , tempInput : String
  }

type Msg
  = ParseInput
  | SetTempInput String

initModel : Model
initModel =
  { input = initInput
  , tempInput = initInput
  }

initInput : String
initInput =
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

update : Msg -> Model -> Model
update msg model =
  case msg of
    ParseInput ->
      { model | input = model.tempInput }

    SetTempInput tempInput ->
      { model | tempInput = tempInput }

view : Model -> Html Msg
view { input, tempInput } =
  div [ bodyStyle ]
    [ h2 [] [ text "Input:" ]
    , textarea [ inputTextAreaStyle, value tempInput, rows 10, onInput SetTempInput ] []
    , button [ onClick ParseInput ] [ text "Parse" ]
    , h2 [] [ text "Output:" ]
    , pre []
        [ code [] [ (Firewall.parseLines >> text) input ]
        ]
    ]

bodyStyle : Attribute Msg
bodyStyle =
  style
    [ ("margin", "0 auto")
    , ("width", "600px")
    , ("font-family", "Helvetica, Arial, sans-serif")
    ]

inputTextAreaStyle : Attribute Msg
inputTextAreaStyle =
  style
    [ ("width", "100%")
    , ("font-family", "monospace")
    ]
