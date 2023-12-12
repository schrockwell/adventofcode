defmodule AdventOfCode.Day10 do
  @behaviour AdventOfCode

  @pipes %{
    "|" => {{0, -1}, {0, 1}},
    "-" => {{-1, 0}, {1, 0}},
    "L" => {{0, -1}, {1, 0}},
    "J" => {{0, -1}, {-1, 0}},
    "7" => {{-1, 0}, {0, 1}},
    "F" => {{1, 0}, {0, 1}},

    # hardcoded "|" for problem
    "S" => {{0, -1}, {0, 1}}
    # "S" => {{1, 0}, {0, 1}}
  }

  # Part 1
  def run(_basename, 1, input) do
    map =
      for {line, y} <- Enum.with_index(input),
          {char, x} <- line |> String.codepoints() |> Enum.with_index(),
          reduce: %{} do
        acc ->
          case @pipes[char] do
            nil ->
              acc

            {{dx1, dy1}, {dx2, dy2}} ->
              Map.put(acc, {x, y}, {{x + dx1, y + dy1}, {x + dx2, y + dy2}})
          end
      end

    starting_coord = {88, 19}
    {start, _} = map[starting_coord]

    loop_length = traverse_pipe(map, starting_coord, starting_coord, start)
    trunc((loop_length + 1) / 2)
  end

  # Part 2
  def run(_basename, 2, _input) do
    0
  end

  defp next_coord({from, other} = _pipe, from), do: other
  defp next_coord({other, from} = _pipe, from), do: other

  defp traverse_pipe(map, starting, from, current, count \\ 0)

  # End condition
  defp traverse_pipe(_, starting, _, starting, count), do: count

  # Regular case
  defp traverse_pipe(map, starting, from, current, count) do
    next = next_coord(map[current], from)
    traverse_pipe(map, starting, current, next, count + 1)
  end
end
