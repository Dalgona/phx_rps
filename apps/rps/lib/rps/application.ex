defmodule RPS.Application do
  @moduledoc false

  use Application
  alias RPS.RoomSupervisor

  def start(_type, _args) do
    children = [
      {Registry, keys: :unique, name: RPS.Registry},
      RoomSupervisor
    ]

    opts = [strategy: :one_for_one, name: RPS.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
