defmodule AdventOfCode.Day04 do
  @behaviour AdventOfCode

  def run(input) do
    [drawn, _ | rest] = input
    drawn = drawn |> String.split(",") |> Enum.map(&String.to_integer/1)

    boards =
      rest
      |> Enum.chunk_every(6)
      |> Enum.map(&parse_board/1)

    {latest_num, boards, [winning_index | _]} = do_drawings(drawn, boards, :first)
    answer_a = final_score(latest_num, Enum.at(boards, winning_index))

    {latest_num, boards, winning_indexes} = do_drawings(drawn, boards, :last)
    answer_b = final_score(latest_num, Enum.at(boards, List.last(winning_indexes)))

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

    indexes =
      boards
      |> Enum.with_index()
      |> Enum.filter(fn {board, _i} -> winning?(board) end)
      |> Enum.map(fn {_, i} -> i end)

    next_indexes =
      Enum.reduce(indexes, winning_indexes, fn i, wi ->
        if i in wi do
          wi
        else
          wi ++ [i]
        end
      end)

    cond do
      which == :first and length(next_indexes) == 1 ->
        {num, boards, next_indexes}

      which == :last and length(next_indexes) == length(boards) ->
        {num, boards, next_indexes}

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
