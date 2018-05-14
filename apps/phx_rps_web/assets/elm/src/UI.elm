module UI exposing (lobbyForm)


import Model exposing (..)
import Msg exposing (Msg(..))
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput, onSubmit)


lobbyForm : Model -> Html Msg
lobbyForm model =
  let
    lobby = model.lobby
    nameField = textField "Player Name" lobby.name ChangeName
    roomIdField = textField "Room ID" lobby.roomId ChangeRoomId
    inputFields =
      case lobby.mode of
        Create -> [ nameField ]
        Join -> [ nameField, roomIdField ]
  in
    phxForm lobby.csrfToken
      [ class "form-horizontal"
      , action "#"
      , method "post"
      , onSubmit Noop
      ] <|
      [ modeTabs lobby ]
      ++ inputFields
      ++ [ goButton model ]


-- Internal Functions


phxForm : String -> List (Attribute Msg) -> List (Html Msg) -> Html Msg
phxForm csrfToken attrs children =
  Html.form attrs <|
    [ input [ type_ "hidden", name "_csrf_token", value csrfToken ] []
    , input [ type_ "hidden", name "_utf8", value "✓" ] []
    ]
    ++ children


modeTabs : Lobby -> Html Msg
modeTabs lobby =
  div [ class "form-group" ]
    [ div [ class "btn-group col-sm-offset-2 col-sm-10" ]
        [ modeTabButton "Create" Create lobby
        , modeTabButton "Join" Join lobby
        ]
    ]


modeTabButton : String -> LobbyMode -> Lobby -> Html Msg
modeTabButton str mode lobby =
  button
    [ type_ "button"
    , classList
        [ ("btn", True)
        , ("btn-default", (lobby.mode /= mode))
        , ("btn-info", (lobby.mode == mode))
        ]
    , onClick (ChangeLobbyMode mode)
    ]
    [ text str ]


textField : String -> String -> (String -> Msg) -> Html Msg
textField title content msg =
  div [ class "form-group" ]
    [ label [ class "col-sm-2 control-label" ] [ text title ]
    , div [ class "col-sm-10" ]
        [ input
          [ class "form-control"
          , placeholder title
          , type_ "text"
          , value content
          , onInput msg
          ]
          []
        ]
    ]


goButton : Model -> Html Msg
goButton model =
  div [ class "form-group" ]
    [ div [ class "col-sm-offset-2 col-sm-10" ]
        [ input
            [ type_ "submit"
            , class "btn btn-primary"
            , disabled (not model.canEnter)
            , value "Go"
            ]
            []
        ]
    ]
