defmodule AOC2024.Day04 do
  # Build a map like %{{x, y} => char}
  @input "04-input.txt"
         |> File.read!()
         |> String.split("\n")
         |> Enum.with_index()
         |> Enum.flat_map(fn {line, y} ->
           line
           |> String.graphemes()
           |> Enum.with_index()
           |> Enum.map(fn {char, x} -> {{x, y}, char} end)
         end)
         |> Map.new()

  defp word({x, y}, dx, dy) do
    Enum.reduce(0..3, "", fn i, acc ->
      acc <> Map.get(@input, {x + i * dx, y + i * dy}, "")
    end)
  end

  # Part 1 - look for "XMAS" in any cardinal direction from the given coordinate for "X"
  defp count_xmas(coord) do
    adj_words = for dx <- -1..1, dy <- -1..1, !(dx == 0 and dy == 0), do: word(coord, dx, dy)

    Enum.count(adj_words, fn
      "XMAS" -> true
      _ -> false
    end)
  end

  # Part 2 - look for "MAS" in an X shape around the given coordinate for "A"
  defp count_mas_in_x_shape({x, y}) do
    x1 = x - 1
    x2 = x + 1
    y1 = y - 1
    y2 = y + 1

    # TL, TR, BL, BR
    corners = [{x1, y1}, {x2, y1}, {x1, y2}, {x2, y2}]

    corners
    |> Enum.map(fn coord -> Map.get(@input, coord) end)
    |> case do
      ["M", "S", "M", "S"] -> 1
      ["M", "M", "S", "S"] -> 1
      ["S", "M", "S", "M"] -> 1
      ["S", "S", "M", "M"] -> 1
      _ -> 0
    end
  end

  def part1 do
    {max_x, max_y} = @input |> Map.keys() |> Enum.max()

    Enum.reduce(0..max_x, 0, fn x, acc ->
      Enum.reduce(0..max_y, acc, fn y, acc ->
        coord = {x, y}

        # Words must start with "X", so find all X's and count how many XMAS words radiate out from it (out of 8 possibilities)
        case Map.get(@input, coord) do
          "X" -> acc + count_xmas(coord)
          _ -> acc
        end
      end)
    end)
  end

  def part2 do
    {max_x, max_y} = @input |> Map.keys() |> Enum.max()

    Enum.reduce(0..max_x, 0, fn x, acc ->
      Enum.reduce(0..max_y, acc, fn y, acc ->
        coord = {x, y}

        # Look for the "A" at the center
        case Map.get(@input, coord) do
          "A" -> acc + count_mas_in_x_shape(coord)
          _ -> acc
        end
      end)
    end)
  end
end

IO.puts("Part 1: #{AOC2024.Day04.part1()}")
IO.puts("Part 2: #{AOC2024.Day04.part2()}")
