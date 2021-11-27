defmodule AdventOfCode.Day06 do
  @behaviour AdventOfCode

  def run(input) do
    answer_a =
      input
      |> groupify()
      |> Enum.map(fn lines ->
        lines
        |> Enum.join()
        |> String.graphemes()
        |> Enum.uniq()
        |> length()
      end)
      |> Enum.sum()

    answer_b =
      input
      |> groupify()
      |> Enum.map(fn lines ->
        lines
        |> Enum.join()
        |> String.graphemes()
        |> Enum.reduce(%{}, fn char, map ->
          Map.update(map, char, 1, &(&1 + 1))
        end)
        |> Enum.count(fn {_, count} -> count == length(lines) end)
      end)
      |> Enum.sum()

    {to_string(answer_a), to_string(answer_b)}
  end

  defp groupify(input) do
    input
    |> Enum.chunk_by(&(&1 == ""))
    |> Enum.reject(&(&1 == [""]))
  end
end
