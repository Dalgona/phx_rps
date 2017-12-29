defmodule RPS.RoomSupervisor do
  use Supervisor
  alias RPS.RoomServer

  def start_link(args) do
    Supervisor.start_link __MODULE__, args, name: __MODULE__
  end

  def init(_args) do
    Supervisor.init [
      Supervisor.child_spec(RoomServer, start: {RoomServer, :start_link, []})
    ], strategy: :simple_one_for_one
  end
end
