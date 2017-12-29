defmodule RPS do
  @type move :: :rock | :paper | :scissors
  @type result :: :ok | {:error, term}
  @type result(type) :: {:ok, type} | {:error, term}

  alias RPS.{Room, RoomServer, RoomSupervisor}

  @spec create_room(Room.id, pid, binary) :: any

  def create_room(room_id, owner, owner_name) do
    Supervisor.start_child RoomSupervisor, [
      room_id,
      [owner: owner, owner_name: owner_name]
    ]
  end

  @spec add_player(Room.id, binary) :: result(binary)

  def add_player(room_id, player) do
    case get_room room_id do
      nil -> {:error, :no_such_room}
      pid -> RoomServer.add_player pid, player
    end
  end

  @spec remove_player(Room.id, binary) :: result

  def remove_player(room_id, player) do
    case get_room room_id do
      nil -> {:error, :no_such_room}
      pid -> RoomServer.remove_player pid, player
    end
  end

  @spec assign_player(Room.id, binary) :: result

  def assign_player(room_id, player) do
    case get_room room_id do
      nil -> {:error, :no_such_room}
      pid -> RoomServer.assign_player pid, player
    end
  end

  @spec leave(Room.id) :: result

  def leave(room_id) do
    case get_room room_id do
      nil -> {:error, :no_such_room}
      pid -> RoomServer.leave pid
    end
  end

  @spec start_game(Room.id) :: result

  def start_game(room_id) do
    case get_room room_id do
      nil -> {:error, :no_such_room}
      pid -> RoomServer.start_game pid
    end
  end

  @spec play(Room.id, move) :: result

  def play(room_id, move) when move in [:rock, :paper, :scissors] do
    case get_room room_id do
      nil -> {:error, :no_such_room}
      pid -> RoomServer.play pid, move
    end
  end

  @spec get_room(Room.id) :: pid | nil

  defp get_room(room_id) do
    case Registry.lookup RPS.Registry, "rps_room_" <> room_id do
      [{pid, _}|_] -> pid
      [] -> nil
    end
  end
end
