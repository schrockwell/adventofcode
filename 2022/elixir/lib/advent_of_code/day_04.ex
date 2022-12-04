defmodule AdventOfCode.Day04 do
  @behaviour AdventOfCode

  def run(input) do
    pairs =
      input
      |> String.split("\n")
      |> Enum.map(&parse_section_pairs/1)

    answer_a = Enum.count(pairs, fn {a, b} -> MapSet.intersection(a, b) in [a, b] end)
    answer_b = Enum.count(pairs, fn {a, b} -> MapSet.intersection(a, b) |> MapSet.size() > 0 end)

    {answer_a, answer_b}
  end

  defp parse_section_pairs(line) do
    line
    |> String.split(",")
    |> Enum.map(&parse_section_range/1)
    |> List.to_tuple()
  end

  defp parse_section_range(range) do
    [min, max] =
      range
      |> String.split("-")
      |> Enum.map(&String.to_integer/1)

    MapSet.new(min..max)
  end
end
