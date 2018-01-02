defmodule RPS.Room do
  defstruct [:id, :owner, :players, :pid_map, :plays, :status]

  @type t :: %__MODULE__{}
  @type id :: binary
  @type status :: :ready | :playing
  @type result(type) :: {:ok, type} | {:error, term}

  @spec new(id, binary) :: t

  def new(room_id, owner) do
    %__MODULE__{
      id: room_id,
      owner: owner,
      players: [owner],
      pid_map: %{},
      plays: %{owner => nil},
      status: :ready
    }
  end

  @spec add_player(t, binary) :: {binary, t}

  def add_player(room, name) do
    new_name = unique_player_name name, room.players
    updated_room = %__MODULE__{
      room|
      players: [new_name|room.players],
      plays: Map.put(room.plays, new_name, nil)
    }
    {new_name, updated_room}
  end

  @spec remove_player(t, binary) :: result(t)

  def remove_player(room, name) do
    if name in Map.values(room.pid_map) do
      {:error, :assigned}
    else
      updated_room = %__MODULE__{
        room|
        players: List.delete(room.players, name),
        plays: Map.delete(room.plays, name)
      }
      {:ok, updated_room}
    end
  end

  @spec assign_player(t, pid, binary) :: result(t)

  def assign_player(room, process, name) do
    cond do
      name not in room.players -> {:error, :no_player}
      room.pid_map[process] -> {:error, :already_assigned}
      :otherwise ->
        updated_room = %__MODULE__{
          room|
          pid_map: Map.put(room.pid_map, process, name)
        }
        {:ok, updated_room}
    end
  end

  @spec leave(t, pid) :: result(t)

  def leave(room, process) do
    case room.pid_map[process] do
      nil -> {:error, :not_assigned}
      player when is_binary(player) ->
        updated_room = %__MODULE__{
          room|
          players: List.delete(room.players, player),
          pid_map: Map.delete(room.pid_map, process),
          plays: Map.delete(room.plays, player)
        }
        {:ok, updated_room}
    end
  end

  @spec all_assigned?(t) :: boolean

  def all_assigned?(room) do
    all_players = MapSet.new room.players
    assigned_players = room.pid_map |> Map.values() |> MapSet.new()
    0 == all_players |> MapSet.difference(assigned_players) |> MapSet.size()
  end

  @spec start(t) :: result(t)

  def start(%{status: :playing}) do
    {:error, :already_playing}
  end

  def start(room) do
    with n_players when n_players > 1 <- length(room.players),
         true <- all_assigned?(room)
    do
      plays = for {k, _} <- room.plays, into: %{}, do: {k, nil}
      {:ok, %__MODULE__{room|status: :playing, plays: plays}}
    else
      n when n <= 1 -> {:error, :not_enough_players}
      false -> {:error, :not_assigned}
    end
  end

  @spec play(t, pid, RPS.move) :: result(t)

  def play(room, process, move) when move in [:rock, :paper, :scissors] do
    case room.pid_map[process] do
      nil -> {:error, :not_assigned}
      player when is_binary(player) ->
        updated_plays = Map.put room.plays, player, move
        new_status =
          if nil not in (for {_, v} <- updated_plays, do: v) do
            :ready
          else
            :playing
          end
        {:ok, %__MODULE__{room|plays: updated_plays, status: new_status}}
    end
  end

  @spec get_result(t) :: {[binary], %{optional(binary) => RPS.move}}

  def get_result(%{plays: plays}) do
    grouped_by_moves = Enum.group_by plays, &elem(&1, 1), &elem(&1, 0)
    case Map.keys grouped_by_moves do
      [move1, move2] -> {grouped_by_moves[winner(move1, move2)], plays}
      _ -> {[], plays}
    end
  end

  @spec owner?(t, pid) :: boolean

  def owner?(%{owner: owner, pid_map: pid_map}, process) do
    owner == pid_map[process]
  end

  @spec whois(t, pid) :: binary

  def whois(%{pid_map: pid_map}, process), do: pid_map[process]

  #
  # Private Functions
  #

  @spec unique_player_name(binary, [binary]) :: binary

  defp unique_player_name(requested_name, existing_names) do
    if requested_name not in existing_names do
      requested_name
    else
      next_unique_player_name requested_name, 0, existing_names
    end
  end

  @spec next_unique_player_name(binary, integer, [binary]) :: binary

  defp next_unique_player_name(requested_name, count, existing_names) do
    mangled_name = "#{requested_name}_#{count}"
    if mangled_name not in existing_names do
      mangled_name
    else
      next_unique_player_name requested_name, count + 1, existing_names
    end
  end

  @spec winner(RPS.move, RPS.move) :: RPS.move | nil

  defp winner(move1, move2)

  defp winner(move, move), do: nil

  for {x, y} <- [rock: :scissors, paper: :rock, scissors: :paper] do
    defp winner(unquote(x), unquote(y)), do: unquote(x)
    defp winner(unquote(y), unquote(x)), do: unquote(x)
  end
end
