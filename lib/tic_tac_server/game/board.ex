defmodule TicTacServer.Game.Board do
  defstruct [
    game_id: nil,
    grid: %{},
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

    board = game_id
      |> add_selection_to_board(symbol, coords)

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

  defp ref(game_id), do: {:global, {:board, game_id}}
end
