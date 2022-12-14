defmodule AdventOfCode.Day13 do
  @behaviour AdventOfCode

  @dividers [[[6]], [[2]]]

  def run(input) do
    pairs = parse_input(input)

    answer_a =
      pairs
      |> Enum.with_index(1)
      |> Enum.filter(fn {[left, right], _i} -> correct_order?(left, right) end)
      |> Enum.map(fn {_pair, i} -> i end)
      |> Enum.sum()

    [{_, index_1}, {_, index_2}] =
      (Enum.flat_map(pairs, &Function.identity/1) ++ @dividers)
      |> Enum.sort(&correct_order?/2)
      |> Enum.with_index(1)
      |> Enum.filter(fn {item, _} -> item in @dividers end)

    answer_b = index_1 * index_2

    {answer_a, answer_b}
  end

  ### Parsing

  defp parse_input(input) do
    input
    |> String.split("\n\n")
    |> Enum.map(fn lines -> String.split(lines, "\n") end)
    |> Enum.map(fn [first, second | _] ->
      {first, _} = Code.eval_string(first)
      {second, _} = Code.eval_string(second)
      [first, second]
    end)
  end

  ### Comparison

  defp correct_order?(left, right) do
    compare(left, right) == :lt
  end

  # Same is equal
  defp compare(same, same), do: :eq

  # Integers are simple
  defp compare(left, right) when is_integer(left) and is_integer(right) do
    if left < right, do: :lt, else: :gt
  end

  # Unwrap single integers
  defp compare([left], [right]) when is_integer(left) and is_integer(right) do
    compare(left, right)
  end

  # Whichever list runs out first is lesser
  defp compare([], [_ | _]), do: :lt
  defp compare([_ | _], []), do: :gt

  # The general case
  defp compare([left | rest_left], [right | rest_right]) do
    # Ensure bare integers are wrapped as lists
    left = List.wrap(left)
    right = List.wrap(right)

    case compare(left, right) do
      # If elements are still equal, keep comparing
      :eq -> compare(rest_left, rest_right)
      # Otherwise, we're done comparing
      other -> other
    end
  end
end
