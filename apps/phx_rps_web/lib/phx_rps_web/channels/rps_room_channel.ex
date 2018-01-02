defmodule PhxRpsWeb.RpsRoomChannel do
  use Phoenix.Channel
  alias PhxRpsWeb.Presence

  def join("rps_room:" <> room_id, _params, socket) do
    :ok = RPS.assign_player room_id, socket.assigns.player_name
    send self(), :after_join
    {:ok, socket}
  end

  def handle_in("rps_start_game", _payload, socket) do
    :ok = RPS.start_game socket.assigns.room_id
    {:noreply, socket}
  end

  def handle_in("rps_play", %{"move" => move}, socket) do
    :ok = RPS.play socket.assigns.room_id, String.to_existing_atom(move)
    {:noreply, socket}
  end

  def terminate(_, socket) do
    RPS.leave socket.assigns.room_id
  end

  #
  # TODO (refactor): broadcast some events directly from channel
  #

  def handle_info(:after_join, socket) do
    push socket, "presence_state", Presence.list(socket)
    {:ok, _} = Presence.track socket, socket.assigns.player_name, %{}
    {:noreply, socket}
  end

  def handle_info({:rps_room_closed, room_id}, socket) do
    push socket, "rps_room_closed", %{room_id: room_id}
    {:stop, :normal, socket}
  end

  def handle_info({:rps_game_started, room_id}, socket) do
    push socket, "rps_game_started", %{room_id: room_id}
    {:noreply, socket}
  end

  def handle_info({:rps_game_finished, {winners, plays}, room_id}, socket) do
    push socket, "rps_game_finished", %{
      winners: winners,
      plays: plays,
      room_id: room_id
    }
    {:noreply, socket}
  end

  def handle_info({:rps_play, who, room_id}, socket) do
    push socket, "rps_play", %{by: who, room_id: room_id}
    {:noreply, socket}
  end
end
