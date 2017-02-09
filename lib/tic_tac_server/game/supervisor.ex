defmodule TicTacServer.Game.Supervisor do
  use Supervisor
  alias TicTacServer.{Game, Game.Board}

  def start_link, do: Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)

  def init(:ok) do
    children = [
      worker(Game, [], restart: :temporary)
    ]

    supervise(children, strategy: :simple_one_for_one)
  end

  def create_game(id) do
    Supervisor.start_child(__MODULE__, [id])
    Board.create(id)
  end
end
