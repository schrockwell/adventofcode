defmodule AdventOfCode.Day18 do
  @behaviour AdventOfCode

  def run(input) do
    answer_a = input |> sum() |> magnitude()
    answer_b = input |> largest_magnitude()

    {answer_a, answer_b}
  end

  defp sum([final]), do: final

  defp sum([first, second | rest]) do
    new_first = first |> to_pair(second) |> reduce()

    sum([new_first | rest])
  end

  # Part 1 answer
  defp magnitude(string) when is_binary(string) do
    # Don't do this at home, kids
    {lists, _} = Code.eval_string(string)
    magnitude(lists)
  end

  defp magnitude(num) when is_integer(num), do: num

  defp magnitude([l, r]) do
    3 * magnitude(l) + 2 * magnitude(r)
  end

  # Part 2 answer
  defp largest_magnitude(inputs) do
    for left <- inputs, reduce: 0 do
      acc ->
        rights = Enum.filter(inputs, &(&1 != left))

        for right <- rights, reduce: acc do
          acc ->
            mag1 = magnitude(sum([left, right]))
            mag2 = magnitude(sum([right, left]))

            acc |> max(mag1) |> max(mag2)
        end
    end
  end

  # Returns the first range which should be exploded, or nil if there are none
  defp find_explodable_range(string, nesting \\ 0, index \\ 0)

  defp find_explodable_range("[" <> _rest = string, 4, index) do
    [{_start, length}] = Regex.run(~r/\[\d+,\d+\]/, string, return: :index)
    index..(index + length - 1)
  end

  defp find_explodable_range("[" <> rest, nesting, index) do
    find_explodable_range(rest, nesting + 1, index + 1)
  end

  defp find_explodable_range("]" <> rest, nesting, index) do
    find_explodable_range(rest, nesting - 1, index + 1)
  end

  defp find_explodable_range(<<_char::binary-1>> <> rest, nesting, index) do
    find_explodable_range(rest, nesting, index + 1)
  end

  defp find_explodable_range("", _, _), do: nil

  # Performs explosion
  defp explode_range(string, range) do
    {left, mid, right} = chunkify(string, range)

    # Get the numeric values for this pair
    [left_value, right_value] =
      ~r/\d+/
      |> Regex.scan(mid)
      |> List.flatten()
      |> Enum.map(&String.to_integer/1)

    # Look up neighbors
    left_range = find_left_neighbor_range(left)
    right_range = find_right_neighbor_range(right)

    # Perform explosion into those neighbors
    new_left = explode_into(left, left_range, left_value)
    new_right = explode_into(right, right_range, right_value)

    # This pair is now just 0
    new_left <> "0" <> new_right
  end

  # Find the range of the first neighboring value to the left
  defp find_left_neighbor_range(string) do
    ~r/\d+/
    |> Regex.scan(string, return: :index)
    |> List.last()
    |> case do
      [{index, length}] -> index..(index + length - 1)
      nil -> nil
    end
  end

  # Find the range of the first neighboring value to the right
  defp find_right_neighbor_range(string) do
    ~r/\d+/
    |> Regex.scan(string, return: :index)
    |> List.first()
    |> case do
      [{index, length}] -> index..(index + length - 1)
      nil -> nil
    end
  end

  # Add a value to the leftmost or rightmost neighboring number
  defp explode_into(string, nil, _value), do: string

  defp explode_into(string, range, value) do
    {l, old_value, r} = chunkify(string, range)
    new_value = String.to_integer(old_value) + value

    l <> to_string(new_value) <> r
  end

  # Returns a range which needs to be split, or nil if there is none
  defp find_splittable_range(string) do
    ~r/\d\d+/
    |> Regex.run(string, return: :index)
    |> case do
      [{index, length}] -> index..(index + length - 1)
      nil -> nil
    end
  end

  # Performs splitting
  defp split_range(string, range) do
    {l, value, r} = chunkify(string, range)

    value = String.to_integer(value)
    left = floor(value / 2)
    right = ceil(value / 2)

    l <> to_pair(left, right) <> r
  end

  # Build a pair string
  defp to_pair(left, right) do
    "[#{left},#{right}]"
  end

  # Perform reduction until no longer possible
  defp reduce(string) do
    explodable_range = find_explodable_range(string)
    splittable_range = find_splittable_range(string)

    cond do
      explodable_range -> string |> explode_range(explodable_range) |> reduce()
      splittable_range -> string |> split_range(splittable_range) |> reduce()
      true -> string
    end
  end

  # Generic helper function for chunking string into three substrings: before, desired, and after
  defp chunkify(string, range) do
    left = String.slice(string, 0..(range.first - 1))
    mid = String.slice(string, range)
    right = String.slice(string, (range.last + 1)..-1)

    {left, mid, right}
  end
end
