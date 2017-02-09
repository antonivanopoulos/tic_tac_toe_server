defmodule TicTacServer.Game do
  use GenServer
  alias TicTacServer.Game.Board

  @winning_numbers [7, 56, 448, 73, 146, 292, 273, 84]

  defstruct [
    id: nil,
    player_x: nil,
    player_o: nil,
    turns: [],
    over: false,
    winner: nil,
    ready: false
  ]

  # CLIENT:

  def start_link(id) do
    GenServer.start_link(__MODULE__, id, name: ref(id))
  end

  def join(id, player_id, pid), do: try_call(id, {:join, player_id, pid})
  def get_data(id), do: try_call(id, {:get_data})
  def player_select(id, player_id, x: x, y: y), do: try_call(id, {:player_select, player_id, x: x, y: y})

  # SERVER:

  def init(id) do
    {:ok, %__MODULE__{id: id}}
  end

  defp ref(id), do: {:global, {:game, id}}

  def handle_call({:join, player_id, pid}, _from, game) do
    cond do
      game.player_x != nil and game.player_o != nil ->
        {:reply, {:error, "No more players allowed"}, game}
      Enum.member?([game.player_x, game.player_o], player_id) ->
        {:reply, {:ok, self()}, game}
      true ->
        Process.flag(:trap_exit, true)
        Process.monitor(pid)

        game = add_player(game, player_id)
        |> check_ready_state()

        {:reply, {:ok, self()}, game}
    end
  end

  def handle_call({:get_data}, _from, game) do
    game_data = Map.put(game, :board, Board.get_data(game.id))

    {:reply, game_data, game}
  end

  def handle_call({:player_select, player_id, x: x, y: y}, _from, game) do
    symbol = get_player_symbol(game, player_id)

    {:ok, board} = Board.select_cell(game.id, symbol, x: x, y: y)

    game = game
    |> update_turns(player_id, x: x, y: y)
    |> check_for_completion

    {:reply, {:ok, game}, game}
  end

  def get_opponent_id(%__MODULE__{player_x: player_id, player_o: nil}, player_id), do: nil
  def get_opponent_id(%__MODULE__{player_x: player_id, player_o: opponent_id}, player_id), do: opponent_id
  def get_opponent_id(%__MODULE__{player_x: opponent_id, player_o: player_id}, player_id), do: opponent_id

  def get_player_symbol(%__MODULE__{player_x: player_id, player_o: opponent_id}, player_id), do: "X"
  def get_player_symbol(%__MODULE__{player_x: opponent_id, player_o: player_id}, player_id), do: "O"

  defp add_player(%__MODULE__{player_x: nil} = game, player_id), do: %{game | player_x: player_id}
  defp add_player(%__MODULE__{player_o: nil} = game, player_id), do: %{game | player_o: player_id}

  defp check_ready_state(%__MODULE__{player_x: nil} = game), do: %{game | ready: false}
  defp check_ready_state(%__MODULE__{player_o: nil} = game), do: %{game | ready: false}
  defp check_ready_state(%__MODULE__{player_x: player_id, player_o: opponent_id} = game), do: %{game | ready: true}

  defp update_turns(game, player_id, x: x, y: y) do
    %{game | turns: [%{player_id: player_id, x: x, y: y} | game.turns]}
  end

  defp check_for_completion(game) do
    board = Board.get_data(game.id)

    IO.inspect(@winning_numbers)
    IO.inspect(board.player_x_score)
    IO.inspect(board.player_o_score)
    cond do
      @winning_numbers |> Enum.member?(round(board.player_x_score)) ->
        %{game | winner: game.player_x, over: true}
      @winning_numbers |> Enum.member?(round(board.player_o_score)) ->
        %{game | winner: game.player_o, over: true}
      check_for_full_board(board) ->
        %{game | over: true}
      true ->
        game
    end
  end

  defp check_for_full_board(board) do
    board
    |> Map.get(:grid)
    |> Enum.filter(fn {k, v} -> v == "" end)
    |> Enum.empty?
  end

  defp try_call(id, message) do
    case GenServer.whereis(ref(id)) do
      nil ->
        {:error, "Game does not exist"}
      pid ->
        GenServer.call(pid, message)
    end
  end
end
