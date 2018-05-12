module UI exposing (lobbyForm)


import Model exposing (..)
import Msg exposing (Msg(..))
import Html exposing (..)
import Html.Attributes exposing (checked, name, type_)
import Html.Events exposing (onClick, onInput)


lobbyForm : Lobby -> Html Msg
lobbyForm lobby =
  let
    inputFields =
      case lobby.mode of
        Create -> [ nameField ]
        Join -> [ nameField, roomField ]
  in
    div []
      [ div []
          [ button [ onClick (ChangeLobbyMode Create) ] [ text "Create" ]
          , button [ onClick (ChangeLobbyMode Join) ] [ text "Join" ]
          ]
      , table [] inputFields
      , div []
          [ button [] [ text "Go" ]
          ]
      ]


-- Internal Functions


nameField : Html Msg
nameField =
  tr []
    [ th [] [ text "Name" ]
    , td [] [ input [ type_ "text", onInput ChangeName ] [] ]
    ]


roomField : Html Msg
roomField =
  tr []
    [ th [] [ text "Room ID" ]
    , td [] [ input [ type_ "text", onInput ChangeRoomId ] [] ]
    ]
