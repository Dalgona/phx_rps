module Msg exposing (..)


import Http
import Model exposing (..)


type Msg
  = ChangeLobbyMode LobbyMode
  | ChangeName String
  | ChangeRoomId String
  | SendAjax LobbyMode
  | GotAjaxResponse (Result Http.Error Room)
  | Noop
