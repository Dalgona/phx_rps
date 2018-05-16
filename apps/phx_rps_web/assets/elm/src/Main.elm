module Main exposing (..)


import Html exposing (..)
import Msg exposing (..)
import Model exposing (..)
import RpsClient exposing (..)
import UI exposing (..)


main : Program Flags Model Msg
main = programWithFlags
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

    SendAjax Create ->
      (model, sendCreateRequest model.lobby)

    SendAjax Join ->
      (model, sendJoinRequest model.lobby)

    GotAjaxResponse (Ok room) ->
      ({model | currentRoom = Just room, lastError = Nothing}, Cmd.none)

    GotAjaxResponse (Err error) ->
      ({model | lastError = Just (getErrorString error)}, Cmd.none)

    Noop ->
      (model, Cmd.none)


view : Model -> Html Msg
view model =
  div []
    [ alert "danger" model.lastError
    , lobbyForm model
    ]


subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none


init : Flags -> (Model, Cmd Msg)
init flags =
  (Model.init flags, Cmd.none)
