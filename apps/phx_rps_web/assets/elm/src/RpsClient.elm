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


formBody : List (String, String) -> Body
formBody params =
  params
  |> List.map kvToParamString
  |> String.join "&"
  |> stringBody "application/x-www-form-urlencoded"


kvToParamString : (String, String) -> String
kvToParamString (k, v) =
  (encodeUri k) ++ "=" ++ (encodeUri v)
