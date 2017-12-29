defmodule RPS.RoomServer do
  use GenServer, restart: :transient
  alias RPS.Room

  @type options :: [owner: pid, owner_name: binary]
  @type result :: :ok | {:error, term}
  @type result(type) :: {:ok, type} | {:error, term}

  #
  # Client Functions
  #

  @spec start_link(binary, options) :: GenServer.on_start

  def start_link(room_id, opts) do
    args = [
      room_id: room_id,
      owner: opts[:owner],
      owner_name: opts[:owner_name]
    ]
    gen_opts = [name: {:via, Registry, {RPS.Registry, "rps_room_" <> room_id}}]
    GenServer.start_link __MODULE__, args, gen_opts
  end

  @spec add_player(pid, binary) :: {:ok, binary}

  def add_player(server, player) do
    GenServer.call server, {:add_player, player}
  end

  @spec remove_player(pid, binary) :: result

  def remove_player(server, player) do
    GenServer.call server, {:remove_player, player}
  end

  @spec assign_player(pid, binary) :: result

  def assign_player(server, player) do
    GenServer.call server, {:assign_player, player}
  end

  @spec leave(pid) :: result

  def leave(server) do
    GenServer.call server, :leave
  end

  @spec start_game(pid) :: result

  def start_game(server) do
    GenServer.call server, :start
  end

  @spec play(pid, RPS.move) :: result

  def play(server, move) when move in [:rock, :paper, :scissors] do
    GenServer.call server, {:play, move}
  end

  #
  # GenServer Callbacks
  #

  def init(args) do
    {:ok, Room.new(args[:room_id], args[:owner], args[:owner_name])}
  end

  def handle_call({:add_player, player}, _, room) do
    {player_name, updated_room} = Room.add_player room, player
    {:reply, {:ok, player_name}, updated_room}
  end

  def handle_call({:remove_player, player}, _, room) do
    case Room.remove_player room, player do
      {:ok, updated_room} -> {:reply, :ok, updated_room}
      {:error, _} = error -> {:reply, error, room}
    end
  end

  def handle_call({:assign_player, player}, {caller, _}, room) do
    case Room.assign_player room, caller, player do
      {:ok, updated_room} -> {:reply, :ok, updated_room}
      {:error, _} = error -> {:reply, error, room}
    end
  end

  def handle_call(:leave, {caller, _}, room) do
    if Room.owner? room, caller do
      broadcast room, {:rps_room_closed, room.id}
      {:stop, :normal, :ok, room}
    else
      case Room.leave room, caller do
        {:ok, updated_room} -> {:reply, :ok, updated_room}
        {:error, _} = error -> {:reply, error, room}
      end
    end
  end

  def handle_call(:start, {caller, _}, room) do
    with true <- Room.owner?(room, caller),
         {:ok, updated_room} <- Room.start(room)
    do
      {:reply, :ok, updated_room}
    else
      false -> {:reply, {:error, :not_owner}, room}
      {:error, _} = error -> {:reply, error, room}
    end
  end

  def handle_call({:play, move}, {caller, _}, room) do
    case Room.play room, caller, move do
      {:ok, updated_room} ->
        if updated_room.status == :ready do
          result = Room.get_result updated_room
          broadcast updated_room, {:rps_game_finished, result, room.id}
        end
        {:reply, :ok, updated_room}
      {:error, _} = error -> {:reply, error, room}
    end
  end

  #
  # Private Functions
  #

  @spec broadcast(Room.t, term) :: :ok

  defp broadcast(room, message) do
    room.pid_map |> Map.keys() |> Enum.each(&send(&1, message))
  end
end
