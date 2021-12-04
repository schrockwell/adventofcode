defmodule AdventOfCode.Day04 do
  @behaviour AdventOfCode

  def run(input) do
    [drawn, _ | rest] = input
    drawn = drawn |> String.split(",") |> Enum.map(&String.to_integer/1)

    boards =
      rest
      |> Enum.chunk_every(6)
      |> Enum.map(&parse_board/1)

    answer_a = do_drawings(drawn, boards, :first)
    answer_b = do_drawings(drawn, boards, :last)

    {answer_a, answer_b}
  end

  defp parse_board(input) do
    input
    |> Enum.join(" ")
    |> String.split()
    |> Enum.with_index()
    |> Enum.map(fn {num, i} ->
      num = String.to_integer(num)
      row = floor(i / 5)
      col = rem(i, 5)

      {num, %{row: row, col: col, picked: false}}
    end)
    |> Map.new()
  end

  defp winning?(board) do
    has_winning?(board, :row) or has_winning?(board, :col)
  end

  defp has_winning?(board, coord) when coord in [:row, :col] do
    !!Enum.find(0..4, fn i ->
      count =
        board
        |> Map.values()
        |> Enum.count(&(&1.picked && &1[coord] == i))

      count == 5
    end)
  end

  defp draw_number(num, boards) do
    Enum.map(boards, fn board ->
      case Map.get(board, num) do
        nil -> board
        entry -> Map.put(board, num, %{entry | picked: true})
      end
    end)
  end

  defp do_drawings([num | rest], boards, which, winning_indexes \\ []) do
    boards = draw_number(num, boards)

    newly_won_indexes =
      boards
      |> Enum.with_index()
      |> Enum.filter(fn {board, i} -> winning?(board) and i not in winning_indexes end)
      |> Enum.map(fn {_, i} -> i end)

    next_indexes = winning_indexes ++ newly_won_indexes

    cond do
      which == :first and length(next_indexes) == 1 ->
        winning_index = hd(next_indexes)
        final_score(num, Enum.at(boards, winning_index))

      which == :last and length(next_indexes) == length(boards) ->
        winning_index = List.last(next_indexes)
        final_score(num, Enum.at(boards, winning_index))

      true ->
        do_drawings(rest, boards, which, next_indexes)
    end
  end

  defp final_score(latest_num, board) do
    unmarked_sum =
      board
      |> Enum.filter(fn {_num, info} -> not info.picked end)
      |> Enum.map(fn {num, _} -> num end)
      |> Enum.sum()

    unmarked_sum * latest_num
  end
end
