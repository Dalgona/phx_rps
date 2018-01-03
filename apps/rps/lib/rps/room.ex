defmodule RPS.Room do
  @moduledoc """
  This module defines a struct which holds state information of a single RPS
  game room, and operations which can be applied to that struct.

  ## Struct Information

  Currently, the `RPS.Room` struct has the following keys:

  * `:owner` - The name of the player who owns the game room.
  * `:players` - A list of names of players in the game room.
  * `:pid_map` - Holds association between player names and processes.
  * `:plays` - Contains information about move that each player played.
  * `:status` - The status of the game room. It can hold either `:ready`
    or `:playing`.
  """

  defstruct [:owner, :players, :pid_map, :plays, :status]

  @type t :: %__MODULE__{}
  @type status :: :ready | :playing
  @type plays :: %{optional(binary) => RPS.move}
  @type result(type) :: {:ok, type} | {:error, term}

  @doc """
  Creates a new struct representing an RPS game room owned by `owner`.
  """

  @spec new(binary) :: t

  def new(owner) do
    %__MODULE__{
      owner: owner,
      players: [owner],
      pid_map: %{},
      plays: %{owner => nil},
      status: :ready
    }
  end

  @doc """
  Adds a player `name` to `room` so that it can be assigned to a process later.

  This function returns a tuple with a newly added player name and the updated
  room struct. The returned player name may differ from the `name` parameter
  because this function mangles the name to prevent name collision.
  """

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

  @doc """
  Removes a player `name`, which is not assigned to any process yet.

  Trying to remove an already assigned name will result in error.
  """

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

  @doc """
  Assigns a player `name` to the given `process`.

  At most one player name can be assigned to each process.
  """

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

  @doc """
  Removes information of a player assigned to the given `process`, from `room`.
  """

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

  @doc """
  Starts a new game and changes the status of `room` to `:playing`.

  The following conditions must be met to start the game:

  * The room must be in `:ready` status.
  * There are two or more players in the room.
  * All players are assigned to distinct processes.
  """

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

  @doc """
  Records a move from a player assigned to the given `process`.
  """

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

  @doc """
  Returns the result of the last game.

  This function returns a tuple with a list of names of players who won
  the game, and the value of `:plays` key. This function shall not be called
  until every player plays a move.
  """

  @spec get_result(t) :: {[binary], plays}

  def get_result(%{plays: plays}) do
    grouped_by_moves = Enum.group_by plays, &elem(&1, 1), &elem(&1, 0)
    case Map.keys grouped_by_moves do
      [move1, move2] -> {grouped_by_moves[winner(move1, move2)], plays}
      _ -> {[], plays}
    end
  end

  @doc """
  Checks if the player assigned to the given `process` is owner of `room`.
  """

  @spec owner?(t, pid) :: boolean

  def owner?(%{owner: owner, pid_map: pid_map}, process) do
    owner == pid_map[process]
  end

  @doc """
  Returns the name of a player assigned to the given `process`.

  This function will return `nil` if it cannot find any association.
  """

  @spec whois(t, pid) :: binary

  def whois(%{pid_map: pid_map}, process), do: pid_map[process]

  #
  # Private Functions
  #

  # Tries to generate a unique player name.
  # e.g. PlayerName, PlayerName_0, PlayerName_1, ...

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

  # Checks if all players are assigned to distinct processes.

  @spec all_assigned?(t) :: boolean

  defp all_assigned?(room) do
    all_players = MapSet.new room.players
    assigned_players = room.pid_map |> Map.values() |> MapSet.new()
    0 == all_players |> MapSet.difference(assigned_players) |> MapSet.size()
  end

  @spec winner(RPS.move, RPS.move) :: RPS.move | nil

  defp winner(move1, move2)

  for {x, y} <- [rock: :scissors, paper: :rock, scissors: :paper] do
    defp winner(unquote(x), unquote(y)), do: unquote(x)
    defp winner(unquote(y), unquote(x)), do: unquote(x)
  end
end
