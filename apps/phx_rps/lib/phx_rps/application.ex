defmodule PhxRps.Application do
  @moduledoc """
  The PhxRps Application Service.

  The phx_rps system business domain lives in this application.

  Exposes API to clients such as the `PhxRpsWeb` application
  for use in channels, controllers, and elsewhere.
  """
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    Supervisor.start_link([
      
    ], strategy: :one_for_one, name: PhxRps.Supervisor)
  end
end
