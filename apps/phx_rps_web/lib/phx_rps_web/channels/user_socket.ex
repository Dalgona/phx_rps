defmodule PhxRpsWeb.UserSocket do
  use Phoenix.Socket

  ## Channels
  channel "rps_room:*", PhxRpsWeb.RpsRoomChannel

  ## Transports
  transport :websocket, Phoenix.Transports.WebSocket

  def connect(params, socket) do
    new_socket =
      socket
      |> assign(:room_id, params["room_id"])
      |> assign(:player_name, params["player_name"])
      |> assign(:is_owner, params["is_owner"])
    {:ok, new_socket}
  end

  def id(_socket), do: nil
end
