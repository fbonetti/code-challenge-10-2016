import Html exposing (Html, button, div, text)
import Html.App as App
import Html.Events exposing (onClick)

main : Program Never
main =
  App.program
    { init = init
    , subscriptions = subscriptions
    , view = view
    , update = update
    }


-- MODEL

type alias Model = Int

type Msg = Increment | Decrement

init : ( Model, Cmd Msg )
init =
  ( 0, Cmd.none )


-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions _ =
  Sub.none


-- UPDATE

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    Increment ->
      ( model + 1, Cmd.none )

    Decrement ->
      ( model - 1, Cmd.none )


-- VIEW

view : Model -> Html Msg
view model =
  div []
    [ button [ onClick Decrement ] [ text "-" ]
    , div [] [ text (toString model) ]
    , button [ onClick Increment ] [ text "+" ]
    ]