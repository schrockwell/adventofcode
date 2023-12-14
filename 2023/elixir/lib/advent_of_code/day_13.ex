defmodule AdventOfCode.Day13 do
  @behaviour AdventOfCode

  # Part 1
  def run(_basename, part, input) do
    smudges = if part == 1, do: 0, else: 1

    input
    |> patterns()
    |> Enum.map(fn pattern ->
      rows = rows(pattern)
      columns = columns(pattern)

      case {find_mirror(rows, smudges), find_mirror(columns, smudges)} do
        {nil, nil} -> raise "oh no"
        {row, nil} -> row * 100
        {nil, col} -> col
      end
    end)
    |> Enum.sum()
  end

  # Look for rows/cols that have exactly N (0 or 1) smudges. (For N = 1, I guess we don't need to verify that it forms
  # a perfect mirror to solve the problem.)
  defp find_mirror(strings, smudges) do
    0..(length(strings) - 2)
    |> Enum.find(fn i ->
      {top, bottom} = Enum.split(strings, i + 1)
      count = min(length(top), length(bottom))
      top_str = top |> Enum.reverse() |> Enum.take(count) |> Enum.join("\n")
      bottom_str = bottom |> Enum.take(count) |> Enum.join("\n")

      count_diffs(top_str, bottom_str) == smudges
    end)
    |> case do
      nil -> nil
      i -> i + 1
    end
  end

  # Basic string diff counter, assuming lengths are the same
  defp count_diffs(str1, str2) do
    str1
    |> String.graphemes()
    |> Enum.with_index()
    |> Enum.reduce(0, fn {grapheme, i}, acc ->
      if String.at(str2, i) == grapheme do
        acc
      else
        acc + 1
      end
    end)
  end

  # Input parsing
  defp patterns(input) do
    input |> Enum.chunk_by(&(&1 != "")) |> Enum.reject(&(&1 == [""]))
  end

  defp rows(pattern) do
    pattern
  end

  defp columns(pattern) do
    width = pattern |> hd |> String.length()

    Enum.map(0..(width - 1), fn i ->
      Enum.map(pattern, fn row ->
        String.at(row, i)
      end)
      |> Enum.join()
    end)
  end
end
