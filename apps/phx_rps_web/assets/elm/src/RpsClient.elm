module RpsClient exposing (..)


import Http exposing (..)
import Json.Decode exposing (..)
import Model exposing (..)
import Msg exposing (..)


roomInfoDecoder : Decoder Room
roomInfoDecoder =
  Json.Decode.map3
    Room
    (field "room_id" string)
    (field "player_name" string)
    (field "is_owner" bool)


sendCreateRequest : Lobby -> Cmd Msg
sendCreateRequest lobby =
  let
    body = formBody [("player_name", lobby.name)]
  in
    roomInfoDecoder
    |> Http.post "/ajax/rps" body
    |> Http.send GotAjaxResponse


sendJoinRequest : Lobby -> Cmd Msg
sendJoinRequest lobby =
  let
    url = "/ajax/rps/" ++ (encodeUri lobby.roomId) ++ "/join"
    body = formBody [("player_name", lobby.name)]
  in
    roomInfoDecoder
    |> Http.post url body
    |> Http.send GotAjaxResponse


getErrorString : Error -> String
getErrorString httpError =
  case httpError of
    BadUrl _ -> "Bad request URL"

    Timeout -> "The server is taking too much time to respond"

    NetworkError -> "Unspecified network error"

    BadPayload _ _ -> "The server sent an unexpected message"

    BadStatus response ->
      let
        errMsg = decodeString (field "error" string) response.body
      in
        case errMsg of
          Ok "no_such_room" ->
            "The specified room is not found"

          Ok "already_playing" ->
            "The game has already started"

          Ok "not_enough_players" ->
            "2 or more players are required to start a game"

          Ok "not_owner" ->
            "Only the owner of this room can perform this action"

          _ ->
            "Unknown error"


formBody : List (String, String) -> Body
formBody params =
  params
  |> List.map kvToParamString
  |> String.join "&"
  |> stringBody "application/x-www-form-urlencoded"


kvToParamString : (String, String) -> String
kvToParamString (k, v) =
  (encodeUri k) ++ "=" ++ (encodeUri v)
