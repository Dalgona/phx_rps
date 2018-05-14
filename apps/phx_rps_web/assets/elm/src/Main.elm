module Main exposing (..)


import Html exposing (..)
import Msg exposing (..)
import Model exposing (..)
import UI exposing (..)


main : Program Never Model Msg
main = program
  { init = init
  , update = update
  , view = view
  , subscriptions = subscriptions
  }


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    ChangeLobbyMode lobbyMode ->
      (setLobbyMode lobbyMode model, Cmd.none)

    ChangeName newName ->
      (setLobbyName newName model, Cmd.none)

    ChangeRoomId newRoomId ->
      (setLobbyRoomId newRoomId model, Cmd.none)

    Noop ->
      (model, Cmd.none)


view : Model -> Html Msg
view model =
  div []
    [ lobbyForm model
    ]


subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none


init : (Model, Cmd Msg)
init =
  (Model.init, Cmd.none)
