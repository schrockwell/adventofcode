defmodule AdventOfCode.Day08 do
  @behaviour AdventOfCode

  # Part 1
  def run("example1.txt", 1, input) do
    part_1(input)
  end

  def run("input.txt", 1, input) do
    part_1(input)
  end

  # Part 2
  def run("example2.txt", 1, input) do
    part_2(input)
  end

  def run("input.txt", 2, input) do
    part_2(input)
  end

  defp part_1(input) do
    {map, directions} = parse_input(input)

    traverse(map, directions, "AAA", directions)
  end

  defp part_2(input) do
    {map, directions} = parse_input(input)

    # Count the steps from A to Z for each starting node, then calculate the least common multiple
    map
    |> Map.keys()
    |> Enum.filter(&match?(<<_, _, "A">>, &1))
    |> Enum.map(fn node ->
      traverse(map, directions, node, directions)
    end)
    |> lcm()
  end

  # Recursive function time!
  defp traverse(map, directions, node, next, count \\ 0)

  # We've arrived
  defp traverse(_, _, <<_, _, "Z">>, _, count), do: count

  # To the left, to the left
  defp traverse(map, directions, node, ["L" | rest], count) do
    {left, _} = Map.get(map, node)
    traverse(map, directions, left, rest, count + 1)
  end

  defp traverse(map, directions, node, ["R" | rest], count) do
    {_, right} = Map.get(map, node)
    traverse(map, directions, right, rest, count + 1)
  end

  # Repeat the directions (don't increment count!!)
  defp traverse(map, directions, node, [], count) do
    traverse(map, directions, node, directions, count)
  end

  # Part 2 - least common multiple
  defp lcm(numbers) when is_list(numbers) do
    Enum.reduce(numbers, 1, &lcm/2)
  end

  defp lcm(a, b) do
    div(abs(a * b), gcd(a, b))
  end

  # Part 2 - greatest common divisor
  defp gcd(a, 0), do: abs(a)
  defp gcd(a, b), do: gcd(b, rem(a, b))

  # Parsing is boooooringgggggg
  defp parse_input([directions | nodes]) do
    {
      Map.new(nodes, fn <<node::binary-3, " = (", left::binary-3, ", ", right::binary-3, ")">> ->
        {node, {left, right}}
      end),
      String.codepoints(directions)
    }
  end
end
