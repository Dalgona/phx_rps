defmodule PhxRpsWeb.RpsRoomChannel do
  use Phoenix.Channel
  alias PhxRpsWeb.Presence

  def join("rps_room:" <> room_id, _params, socket) do
    :ok = RPS.assign_player room_id, socket.assigns.player_name
    send self(), :after_join
    {:ok, socket}
  end

  def handle_in("rps_start_game", _payload, socket) do
    room_id = socket.assigns.room_id
    :ok = RPS.start_game room_id
    broadcast! socket, "rps_game_started", %{room_id: room_id}
    {:noreply, socket}
  end

  def handle_in("rps_play", %{"move" => move}, socket) do
    %{assigns: %{room_id: room_id, player_name: player_name}} = socket
    :ok = RPS.play room_id, String.to_existing_atom(move)
    broadcast! socket, "rps_play", %{by: player_name, room_id: room_id}
    {:noreply, socket}
  end

  def terminate(_, socket) do
    RPS.leave socket.assigns.room_id
  end

  def handle_info(:after_join, socket) do
    push socket, "presence_state", Presence.list(socket)
    {:ok, _} = Presence.track socket, socket.assigns.player_name, %{}
    {:noreply, socket}
  end

  def handle_info(:rps_room_closed, socket) do
    push socket, "rps_room_closed", %{}
    {:stop, :normal, socket}
  end

  def handle_info({:rps_game_finished, {winners, plays}}, socket) do
    push socket, "rps_game_finished", %{
      winners: winners,
      plays: plays,
    }
    {:noreply, socket}
  end
end
