defmodule AdventOfCode.Day06 do
  @behaviour AdventOfCode

  # Part 1
  def run(_basename, 1, input) do
    input
    |> parse_races()
    |> Enum.map(&count_wins/1)
    |> Enum.product()
  end

  # Part 2
  def run(_basename, 2, input) do
    input
    |> Enum.map(&String.replace(&1, " ", ""))
    |> parse_races()
    |> hd()
    |> count_wins()
  end

  # Returns the number of ways to win the race
  defp count_wins({total_time, distance}) do
    Enum.count(1..(total_time - 1), fn held_time ->
      distance_traveled(total_time, held_time) > distance
    end)
  end

  # It's math, baby!
  defp distance_traveled(total_time, held_time) do
    held_time * (total_time - held_time)
  end

  # Returns a list of {total_time, distance} tuples
  defp parse_races([times, distances]) do
    times = parse_numbers(times)
    distances = parse_numbers(distances)

    Enum.zip(times, distances)
  end

  # Parses numbers from a string
  defp parse_numbers(string) do
    ~r/\d+/ |> Regex.scan(string) |> List.flatten() |> Enum.map(&String.to_integer/1)
  end
end
