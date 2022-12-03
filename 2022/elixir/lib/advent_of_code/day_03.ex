defmodule AdventOfCode.Day03 do
  @behaviour AdventOfCode

  @lowercase_priorities Map.new(?a..?z, fn ascii -> {ascii, ascii - ?a + 1} end)
  @uppercase_priorities Map.new(?A..?Z, fn ascii -> {ascii, ascii - ?A + 27} end)
  @priorities Map.merge(@lowercase_priorities, @uppercase_priorities)

  def run(input) do
    answer_a =
      input
      |> Enum.flat_map(fn line ->
        line
        |> String.to_charlist()
        |> to_priorities()
        |> to_compartments()
        |> find_common()
      end)
      |> Enum.sum()

    answer_b =
      input
      |> Enum.map(fn line ->
        line
        |> String.to_charlist()
        |> to_priorities()
        |> MapSet.new()
      end)
      |> Enum.chunk_every(3)
      |> Enum.map(&find_common_badge/1)
      |> Enum.sum()

    {answer_a, answer_b}
  end

  defp to_priorities(chars) do
    Enum.map(chars, fn char -> Map.fetch!(@priorities, char) end)
  end

  defp to_compartments(chars) do
    {left, right} = Enum.split(chars, trunc(length(chars) / 2))
    {MapSet.new(left), MapSet.new(right)}
  end

  defp find_common({left, right}) do
    MapSet.intersection(left, right)
  end

  defp find_common_badge([a, b, c]) do
    [common] =
      a
      |> MapSet.intersection(b)
      |> MapSet.intersection(c)
      |> Enum.to_list()

    common
  end
end
