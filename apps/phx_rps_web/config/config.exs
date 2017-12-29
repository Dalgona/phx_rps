# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :phx_rps_web,
  namespace: PhxRpsWeb

# Configures the endpoint
config :phx_rps_web, PhxRpsWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "qRc0px/+bBzHVcsNmaxdCWdNfqKAwH1MJNmmJA49w/s1MlaE5P5yYsJ1RwUYXXHk",
  render_errors: [view: PhxRpsWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: PhxRpsWeb.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phx_rps_web, :generators,
  context_app: :phx_rps

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
