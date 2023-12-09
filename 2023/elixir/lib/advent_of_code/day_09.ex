defmodule AdventOfCode.Day09 do
  @behaviour AdventOfCode

  # Parts 1 and 2
  def run(_basename, part, input) do
    # For changing behavior of extrapolate/2
    which =
      case part do
        1 -> :last
        2 -> :first
      end

    input
    |> parse_input()
    |> Enum.map(fn seq ->
      [seq]
      |> history()
      |> extrapolate(which)
    end)
    |> Enum.sum()
  end

  # Part 1 - Calculate history
  defp history([seq | _] = seqs) do
    if Enum.all?(seq, &(&1 == 0)) do
      # We're done!
      seqs
    else
      # Calculate next sequence
      next_seq = deltas(seq)
      history([next_seq | seqs])
    end
  end

  # Calculate diffs between sequences
  def deltas(seq) do
    Enum.slice(seq, 0..-2)
    |> Enum.zip(Enum.slice(seq, 1..-1))
    |> Enum.map(fn {a, b} -> b - a end)
  end

  # Recursion
  defp extrapolate(history, which, total \\ 0)

  defp extrapolate([], _, total), do: total

  defp extrapolate([seq | rest], :last, total) do
    total = List.last(seq) + total
    extrapolate(rest, :last, total)
  end

  defp extrapolate([seq | rest], :first, total) do
    total = hd(seq) - total
    extrapolate(rest, :first, total)
  end

  # Parsing
  defp parse_input(input) do
    Enum.map(input, fn i -> i |> String.split(" ") |> Enum.map(&String.to_integer/1) end)
  end
end
