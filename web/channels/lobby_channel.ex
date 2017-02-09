defmodule TicTacServer.LobbyChannel do
  use TicTacServer.Web, :channel
  alias TicTacServer.Game.Supervisor, as: GameSupervisor

  def join("lobby", _msg, socket) do
    {:ok, socket}
  end

  def handle_in("new_game", _params, socket) do
    game_id = TicTacServer.generate_game_id
    GameSupervisor.create_game(game_id)

    {:reply, {:ok, %{game_id: game_id}}, socket}
  end
end
