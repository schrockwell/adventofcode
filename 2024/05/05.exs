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

  defp all_rules_valid?(update) do
    update = update |> Enum.with_index() |> Map.new()
    Enum.all?(@rules, fn rule -> rule_valid?(rule, update) end)
  end

  defp sum_middle_pages(updates) do
    updates
    |> Enum.map(fn update -> Enum.at(update, floor(length(update) / 2)) end)
    |> Enum.sum()
  end

  def part1 do
    @updates
    |> Enum.filter(&all_rules_valid?/1)
    |> sum_middle_pages()
  end

  def part2 do
    @updates
    |> Enum.filter(&(not all_rules_valid?(&1)))
    |> Enum.map(&insert_pages/1)
    |> sum_middle_pages()
  end

  # Part 2 - insert the pages one at a time in a way that satisfies every rule at every step
  defp insert_pages(pages, acc \\ [])

  # First page is free
  defp insert_pages([page | rest], []) do
    insert_pages(rest, [page])
  end

  # We're all done
  defp insert_pages([], acc), do: acc

  # Iteration
  defp insert_pages([page | rest], acc) do
    next_acc =
      0..length(acc)
      |> Enum.map(fn i -> List.insert_at(acc, i, page) end)
      |> Enum.find(&all_rules_valid?/1)

    insert_pages(rest, next_acc)
  end
end

IO.puts("Part 1: #{AOC2024.Day5.part1()}")
IO.puts("Part 2: #{AOC2024.Day5.part2()}")
