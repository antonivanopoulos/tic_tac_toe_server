defmodule TicTacServer.Game.Board do
  defstruct [
    game_id: nil,
    grid: %{},
    player_x_score: 0,
    player_o_score: 0,
  ]

  def create(game_id) do
    grid = build_grid()

    Agent.start(fn -> %__MODULE__{game_id: game_id, grid: grid} end, name: ref(game_id))
  end

  def get_data(game_id) do
    Agent.get(ref(game_id), &(&1))
  end

  def select_cell(game_id, symbol, x: x, y: y) do
    coords = Enum.join([y, x], "")

    score = get_score_for_cell(x: x, y: y)

    board = game_id
      |> add_selection_to_board(symbol, coords)
      |> update_score(symbol, score)

    {:ok, board}
  end

  defp build_grid do
    0..2
    |> Enum.reduce([], &build_row/2)
    |> List.flatten
    |> Enum.reduce(%{}, fn item, acc -> Map.put(acc, item, "") end)
  end

  defp build_row(y, rows) do
    row = 0..2
      |> Enum.reduce(rows, fn x, col -> [Enum.join([y, x], "") | col] end)

    [row | rows]
  end

  defp add_selection_to_board(game_id, symbol, coords) do
    Agent.update(ref(game_id), &(put_in(&1.grid[coords], symbol)))

    get_data(game_id)
  end

  defp update_score(board, symbol, score) do
    case symbol do
      "O" ->
        current_score = board |> Map.get(:player_o_score)
        Agent.update(ref(board.game_id), fn(_) -> %{board | player_o_score: current_score + score} end)
      "X" ->
        current_score = board |> Map.get(:player_x_score)
        Agent.update(ref(board.game_id), fn(_) -> %{board | player_x_score: current_score + score} end)
    end

    get_data(board.game_id)
  end

  defp ref(game_id), do: {:global, {:board, game_id}}

  defp grid_scores do
    0..8
    |> Enum.map(fn(x) -> :math.pow(2, x) end)
  end

  defp get_score_for_cell(x: x, y: y) do
    grid_scores()
    |> Enum.at(x + (3 * y))
  end
end
