defmodule AOC2024.Day5 do
  @sections "05-input.txt"
            |> File.read!()
            |> String.split("\n\n")

  @rules @sections
         |> Enum.at(0)
         |> String.split("\n")
         |> Enum.map(fn line ->
           [a, b] = String.split(line, "|")
           {String.to_integer(a), String.to_integer(b)}
         end)

  @updates @sections
           |> Enum.at(1)
           |> String.split("\n")
           |> Enum.map(fn line -> line |> String.split(",") |> Enum.map(&String.to_integer/1) end)

  defp rule_valid?({a, b}, update) do
    first_index = Map.get(update, a)
    second_index = Map.get(update, b)

    cond do
      first_index == nil -> true
      second_index == nil -> true
      first_index < second_index -> true
      first_index > second_index -> false
    end
  end

  def part1 do
    @updates
    |> Enum.filter(fn update ->
      update = update |> Enum.with_index() |> Map.new()

      Enum.all?(@rules, fn rule -> rule_valid?(rule, update) end)
    end)
    |> Enum.map(fn update -> Enum.at(update, floor(length(update) / 2)) end)
    |> Enum.sum()
  end
end

IO.puts("Part 1: #{AOC2024.Day5.part1()}")
