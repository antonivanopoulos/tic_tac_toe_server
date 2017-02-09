defmodule TicTacServer do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec

    # Define workers and child supervisors to be supervised
    children = [
      # Start the Ecto repository
      supervisor(TicTacServer.Repo, []),
      # Start the endpoint when the application starts
      supervisor(TicTacServer.Endpoint, []),
      # Start your own worker by calling: TicTacServer.Worker.start_link(arg1, arg2, arg3)
      supervisor(TicTacServer.Game.Supervisor, []),
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: TicTacServer.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    TicTacServer.Endpoint.config_change(changed, removed)
    :ok
  end

  def generate_player_id do
    10
    |> :crypto.strong_rand_bytes
    |> Base.url_encode64()
    |> binary_part(0, 10)
  end

  def generate_game_id do
    10
    |> :crypto.strong_rand_bytes
    |> Base.url_encode64()
    |> binary_part(0, 10)
  end
end
