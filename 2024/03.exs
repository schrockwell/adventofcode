defmodule AOC2024.Day3 do
  @input File.read!("03-input.txt")

  defp scan_for_mul(input) do
    regex = ~r/mul\((\d+),(\d+)\)/

    regex
    |> Regex.scan(input)
    |> Enum.map(fn [_, a, b] -> {String.to_integer(a), String.to_integer(b)} end)
  end

  defp scan_for_all(input) do
    regex = ~r/(don\'t\(\)|do\(\)|mul\((\d+),(\d+)\))/

    Regex.scan(regex, input)
  end

  def part1 do
    @input
    |> scan_for_mul()
    |> Enum.reduce(0, fn {a, b}, acc -> a * b + acc end)
  end

  def part2 do
    @input
    |> scan_for_all()
    |> Enum.reduce({true, 0}, fn
      ["don't()", _], {_, acc} -> {false, acc}
      ["do()", _], {_, acc} -> {true, acc}
      [_, _, a, b], {true, acc} -> {true, String.to_integer(a) * String.to_integer(b) + acc}
      _, {false, acc} -> {false, acc}
    end)
    |> elem(1)
  end
end

IO.puts("Part 1: #{AOC2024.Day3.part1()}")
IO.puts("Part 2: #{AOC2024.Day3.part2()}")
