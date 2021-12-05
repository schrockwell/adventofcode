defmodule AdventOfCode.Day05 do
  @behaviour AdventOfCode

  def run(input) do
    lines = Enum.map(input, &parse_line/1)

    answer_a = lines |> filter_ortho() |> count_overlaps()
    answer_b = lines |> count_overlaps()

    {answer_a, answer_b}
  end

  # Returns a two-ple of coordinate two-ples
  defp parse_line(input) do
    input
    |> String.split(" -> ")
    |> Enum.map(fn coord ->
      [x, y] = String.split(coord, ",")
      {String.to_integer(x), String.to_integer(y)}
    end)
    |> List.to_tuple()
  end

  # Returns only orthagonal lines (horizontal or vertical)
  defp filter_ortho(lines) do
    Enum.filter(lines, fn
      {{x, _}, {x, _}} -> true
      {{_, y}, {_, y}} -> true
      _ -> false
    end)
  end

  # Do the thing
  defp count_overlaps(lines) do
    lines
    |> Enum.reduce(%{}, fn {p1, p2}, map ->
      points_between(p1, p2)
      |> Enum.reduce(map, fn point, map ->
        Map.update(map, point, 1, &(&1 + 1))
      end)
    end)
    |> Map.values()
    |> Enum.count(&(&1 > 1))
  end

  # Vertical line (x1 == x2)
  defp points_between({x, y1}, {x, y2}) do
    for y <- y1..y2, do: {x, y}
  end

  # Horizontal line (y1 == y2)
  defp points_between({x1, y}, {x2, y}) do
    for x <- x1..x2, do: {x, y}
  end

  # Diagonal line
  defp points_between({x1, y1}, {x2, y2}) do
    for {x, y} <- Enum.zip(x1..x2, y1..y2), do: {x, y}
  end
end
