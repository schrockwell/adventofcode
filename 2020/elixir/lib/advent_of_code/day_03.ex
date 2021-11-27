defmodule AdventOfCode.Day03 do
  @behaviour AdventOfCode

  def run(input) do
    answer_a = count_trees(input, 3, 1)

    slopes = [{1, 1}, {3, 1}, {5, 1}, {7, 1}, {1, 2}]

    answer_b =
      Enum.reduce(slopes, 1, fn {x_inc, y_inc}, acc ->
        acc * count_trees(input, x_inc, y_inc)
      end)

    {answer_a, answer_b}
  end

  defp count_trees(lines, x_inc, y_inc) do
    count_trees(lines, x_inc, y_inc, String.length(hd(lines)), 0, 0)
  end

  defp count_trees(lines, x_inc, y_inc, line_length, x, tree_count) do
    case Enum.split(lines, y_inc) do
      {_, []} ->
        tree_count

      {_, [line | _] = next_lines} ->
        x = rem(x + x_inc, line_length)
        tree_inc = if(String.at(line, x) == "#", do: 1, else: 0)
        count_trees(next_lines, x_inc, y_inc, line_length, x, tree_count + tree_inc)
    end
  end
end
