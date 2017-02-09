defmodule TicTacServer.GameChannel do
  use TicTacServer.Web, :channel
  alias TicTacServer.{Game, Game.Board}

  def join("game:" <> game_id, _payload, socket) do
    player_id = socket.assigns.player_id

    case Game.join(game_id, player_id, socket.channel_pid) do
      {:ok, _pid} ->
        {:ok, assign(socket, :game_id, game_id)}
      {:error, reason} ->
        {:error, %{reason: reason}}
    end
  end

  def handle_in("game:start", _message, socket) do
    game_id = socket.assigns.game_id
    game = Game.get_data(game_id)

    broadcast(socket, "game:player:#{game.player_x}:set_turn", %{game: Game.get_data(game_id)})
    {:noreply, socket}
  end

  def handle_in("game:joined", _message, socket) do
    player_id = socket.assigns.player_id
    game_id = socket.assigns.game_id
    board = Board.get_data(game_id)
    game = Game.get_data(game_id)

    broadcast! socket, "game:player_joined", %{player_id: player_id, game: game, board: board}

    {:noreply, socket}
  end

  def handle_in("game:select", %{"x" => x, "y" => y}, socket) do
    player_id = socket.assigns.player_id
    game_id = socket.assigns.game_id

    case Game.player_select(game_id, player_id, x: x, y: y) do
      {:ok, %Game{over: true} = game} ->
        broadcast(socket, "game:over", %{game: Game.get_data(game_id)})
        {:noreply, socket}
      {:ok, game} ->
        opponent_id = Game.get_opponent_id(game, player_id)
        broadcast(socket, "game:player:#{opponent_id}:set_turn", %{game: Game.get_data(game_id)})
        {:reply, {:ok, %{game: Game.get_data(game_id)}}, socket}
      _ ->
        {:error, {:error, %{reason: "Something went wrong."}}, socket}
    end
  end
end
