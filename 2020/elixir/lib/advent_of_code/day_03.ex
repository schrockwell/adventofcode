defmodule AdventOfCode.Day03 do
  @behaviour AdventOfCode

  def run(input) do
    answer_a = count_trees(input)

    answer_b = "todo"

    IO.puts("Answer A: #{answer_a}")
    IO.puts("Answer B: #{answer_b}")

    {to_string(answer_a), to_string(answer_b)}
  end

  defp count_trees([_ | lines]) do
    count_trees(lines, String.length(hd(lines)), 0, 0)
  end

  defp count_trees([line | lines], line_length, x, tree_count) do
    x = x + 3
    char_index = rem(x, line_length)

    tree_inc = if(String.at(line, char_index) == "#", do: 1, else: 0)
    count_trees(lines, line_length, x, tree_count + tree_inc)
  end

  defp count_trees([], _, _, tree_count), do: tree_count
end
