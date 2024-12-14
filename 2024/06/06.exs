defmodule AOC2024.Day06 do
  @filename "06-input.txt"

  @width @filename |> File.stream!() |> Enum.take(1) |> hd() |> String.length()
  @height @filename |> File.stream!() |> Enum.count()

  @obstacles @filename
             |> File.stream!()
             |> Stream.with_index()
             |> Enum.flat_map(fn {line, y} ->
               line
               |> String.graphemes()
               |> Enum.with_index()
               |> Enum.filter(fn {char, _x} -> char == "#" end)
               |> Enum.map(fn {_char, x} -> {x, y} end)
             end)
             |> MapSet.new()

  @start_coord @filename
               |> File.stream!()
               |> Stream.with_index()
               |> Enum.find_value(fn {line, y} ->
                 line
                 |> String.graphemes()
                 |> Enum.with_index()
                 |> Enum.find(fn {char, _} -> char == "^" end)
                 |> then(fn
                   nil -> nil
                   {_, x} -> {x, y}
                 end)
               end)

  defp patrol(guard_coord) do
    patrol(guard_coord, {0, -1}, MapSet.new([guard_coord]))
  end

  defp patrol({x, y} = guard_coord, {dx, dy} = direction, visited) do
    next_x = x + dx
    next_y = y + dy
    next_coord = {next_x, next_y}

    cond do
      next_x < 0 or next_y < 0 or next_x > @width or next_y > @height ->
        # We've reached the edge of the map, so we're done
        MapSet.size(visited)

      # There's an obstacle in the way
      Enum.member?(@obstacles, next_coord) ->
        patrol(guard_coord, turn_right(direction), visited)

      # Keep on truckin'
      true ->
        patrol(next_coord, direction, MapSet.put(visited, next_coord))
    end
  end

  defp turn_right({0, -1}), do: {1, 0}
  defp turn_right({1, 0}), do: {0, 1}
  defp turn_right({0, 1}), do: {-1, 0}
  defp turn_right({-1, 0}), do: {0, -1}

  def part1 do
    patrol(@start_coord)
  end

  def part2 do
  end
end

IO.puts("Part 1: #{AOC2024.Day06.part1()}")
