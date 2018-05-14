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
  , canEnter : Bool
  }


init : Model
init =
  { lobby =
      { mode = Create
      , name = ""
      , roomId = ""
      }
  , canEnter = False
  }


setLobbyMode : LobbyMode -> Model -> Model
setLobbyMode newMode model =
  let
    lobby = model.lobby
    newLobby = { lobby | mode = newMode }
  in
    { model | lobby = newLobby, canEnter = calculateCanJoin newLobby }


setLobbyName : String -> Model -> Model
setLobbyName newName model =
  let
    lobby = model.lobby
    newLobby = { lobby | name = newName }
  in
    { model | lobby = newLobby, canEnter = calculateCanJoin newLobby }


setLobbyRoomId : String -> Model -> Model
setLobbyRoomId newRoomId model =
  let
    lobby = model.lobby
    newLobby = { lobby | roomId = newRoomId }
  in
    { model | lobby = newLobby, canEnter = calculateCanJoin newLobby }


calculateCanJoin : Lobby -> Bool
calculateCanJoin lobby =
  case lobby.mode of
    Create ->
      not (String.isEmpty lobby.name)

    Join ->
      not <| (String.isEmpty lobby.name) || (String.isEmpty lobby.roomId)
