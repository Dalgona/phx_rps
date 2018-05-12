module Msg exposing (..)


import Model exposing (..)


type Msg
  = ChangeLobbyMode LobbyMode
  | ChangeName String
  | ChangeRoomId String
  | Noop
