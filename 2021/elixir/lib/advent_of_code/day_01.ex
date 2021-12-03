defmodule AdventOfCode.Day01 do
  @behaviour AdventOfCode

  def run(input) do
    input = Enum.map(input, &String.to_integer/1)

    answer_a = count_increases(input)

    answer_b =
      input
      |> Enum.chunk_every(3, 1)
      |> Enum.map(&Enum.sum/1)
      |> count_increases()

    {answer_a, answer_b}
  end

  defp count_increases(levels) do
    levels
    |> Enum.chunk_every(2, 1)
    |> Enum.count(fn
      [l, r] -> r > l
      _ -> false
    end)
  end
end
