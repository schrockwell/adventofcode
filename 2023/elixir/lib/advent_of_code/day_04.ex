defmodule AdventOfCode.Day04 do
  @behaviour AdventOfCode

  # Part 1
  def run(_basename, 1, input) do
    input
    |> Enum.map(fn line ->
      line
      |> parse_card()
      |> count_wins()
      |> case do
        0 -> 0
        wins -> 2 ** (wins - 1)
      end
    end)
    |> Enum.sum()
  end

  # Part 2
  def run(_basename, 2, input) do
    input
    |> Enum.map(fn line ->
      line
      |> parse_card()
      |> count_wins()
    end)
    |> play_part_2(0, %{})
    |> Map.values()
    |> Enum.sum()
  end

  defp parse_card(line) do
    ["Card " <> _num, numbers] = String.split(line, ": ")
    [winning, have] = String.split(numbers, " | ")

    winning_numbers =
      Regex.scan(~r/\d+/, winning) |> List.flatten() |> Enum.map(&String.to_integer/1)

    have_numbers = Regex.scan(~r/\d+/, have) |> List.flatten() |> Enum.map(&String.to_integer/1)

    {MapSet.new(winning_numbers), MapSet.new(have_numbers)}
  end

  defp count_wins({winning, have}) do
    Enum.count(MapSet.intersection(winning, have))
  end

  defp play_part_2([wins | rest], index, acc) do
    # Generate one copy of this card, plus all the previous copies
    copies = 1 + Map.get(acc, index, 0)

    # Add this single card
    acc = Map.update(acc, index, 1, &(&1 + 1))

    if wins == 0 do
      # Special case: don't add any copies, just iterate
      play_part_2(rest, index + 1, acc)
    else
      # Add copies to the upcoming cards
      acc =
        Enum.reduce((index + 1)..(index + wins), acc, fn i, a ->
          Map.update(a, i, copies, &(&1 + copies))
        end)

      # Iterate
      play_part_2(rest, index + 1, acc)
    end
  end

  defp play_part_2([], _, acc), do: acc
end
