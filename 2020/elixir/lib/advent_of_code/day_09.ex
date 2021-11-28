defmodule AdventOfCode.Day09 do
  @behaviour AdventOfCode

  def run(input) do
    input = Enum.map(input, &String.to_integer/1)

    answer_a = find_first_invalid(input, 25)

    addends = find_contiguous_addends(input, answer_a)
    answer_b = Enum.min(addends) + Enum.max(addends)

    {answer_a, answer_b}
  end

  defp has_addend_pair?(preamble, num) do
    # Way less efficient (and correct) than permuations, but whatever
    !!Enum.find(preamble, fn x ->
      Enum.find(preamble, fn y ->
        x + y == num
      end)
    end)
  end

  defp find_first_invalid([_ | rest] = list, offset) do
    {preamble, [num | _]} = Enum.split(list, offset)

    if has_addend_pair?(preamble, num) do
      find_first_invalid(rest, offset)
    else
      num
    end
  end

  defp find_contiguous_addends([_ | rest] = input, window \\ 2, target) do
    addends = Enum.take(input, window)
    sum = Enum.sum(addends)

    cond do
      sum < target ->
        # Enlarge the window
        find_contiguous_addends(input, window + 1, target)

      sum == target ->
        # We're done!
        addends

      sum > target ->
        # Overflow, so start over with the next item
        find_contiguous_addends(rest, target)
    end
  end
end
