# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :tic_tac_server,
  ecto_repos: [TicTacServer.Repo]

# Configures the endpoint
config :tic_tac_server, TicTacServer.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "GuKjUuMashwBCCd6kolRedaeM5eMjILfmUrRQmL6t51biqZcpVoa3f2WfMXFFKzU",
  render_errors: [view: TicTacServer.ErrorView, accepts: ~w(html json)],
  pubsub: [name: TicTacServer.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
