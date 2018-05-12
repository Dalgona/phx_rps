module Model exposing (..)


type LobbyMode
  = Create
  | Join


type alias Lobby =
  { mode : LobbyMode
  , name : String
  , roomId : String
  }


type alias Model =
  { lobby : Lobby
  }


setLobbyMode : LobbyMode -> Model -> Model
setLobbyMode newMode model =
  let
    lobby = model.lobby
    newLobby = { lobby | mode = newMode }
  in
    { model | lobby = newLobby }


setLobbyName : String -> Model -> Model
setLobbyName newName model =
  let
    lobby = model.lobby
    newLobby = { lobby | name = newName }
  in
    { model | lobby = newLobby }


setLobbyRoomId : String -> Model -> Model
setLobbyRoomId newRoomId model =
  let
    lobby = model.lobby
    newLobby = { lobby | roomId = newRoomId }
  in
    { model | lobby = newLobby }
