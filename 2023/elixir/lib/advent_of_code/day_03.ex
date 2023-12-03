defmodule AdventOfCode.Day03 do
  @behaviour AdventOfCode

  # Part 1
  def run(_basename, 1, input) do
    map = build_map(input)

    for {line, y} <- Enum.with_index(input),
        {x1, x2, part} <- scan_parts(line),
        adjacent_symbol?(map, x1, x2, y) do
      part
    end
    |> Enum.sum()
  end

  # Part 2
  def run(_basename, 2, input) do
    map = build_map(input)

    # Build a map of %{{x, y} => [...]} mapping gear coords to their adjacent part numbers
    gear_parts =
      for {line, y} <- Enum.with_index(input),
          {x1, x2, part} <- scan_parts(line),
          gear_coord <- adjacent_gear_coords(map, x1, x2, y),
          reduce: %{} do
        acc ->
          Map.update(acc, gear_coord, [part], fn parts -> [part | parts] end)
      end

    # Sum the gear ratios of gears with exactly 2 adjacent parts
    Enum.sum(for {_gear_coord, [part1, part2]} <- gear_parts, do: part1 * part2)
  end

  # Returns a map of %{{x, y} => char}, only for digits and symbols
  defp build_map(input) do
    for {line, y} <- Enum.with_index(input),
        {char, x} <- Enum.with_index(String.codepoints(line)),
        char != ".",
        into: %{} do
      {{x, y}, char}
    end
  end

  # Returns a list of {start_index, end_index, part_number} tuples for parts in the line
  defp scan_parts(line) do
    ~r/\d+/
    |> Regex.scan(line, return: :index)
    |> List.flatten()
    |> Enum.map(fn {index, length} ->
      x1 = index
      x2 = index + length - 1
      {x1, x2, line |> String.slice(x1..x2) |> String.to_integer()}
    end)
  end

  # Returns true if any of the adjacent coords are a symbol
  defp adjacent_symbol?(map, x1, x2, y) do
    coords = adjacent_coords(x1, x2, y)
    Enum.any?(coords, fn coord -> symbol?(Map.get(map, coord)) end)
  end

  # Returns a list of {x, y} coords for nearby gears
  def adjacent_gear_coords(map, x1, x2, y) do
    coords = adjacent_coords(x1, x2, y)
    Enum.filter(coords, fn coord -> gear?(Map.get(map, coord)) end)
  end

  # Returns a list of {x, y} coords surrounding the number
  defp adjacent_coords(x1, x2, y) do
    x_range = (x1 - 1)..(x2 + 1)
    y_range = (y - 1)..(y + 1)
    for x <- x_range, y <- y_range, do: {x, y}
  end

  # IS IT SYMBOL??
  defp symbol?(char) when char in ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"], do: false
  defp symbol?(nil), do: false
  defp symbol?(<<_char>>), do: true

  # IS IT... GEAR?????
  defp gear?("*"), do: true
  defp gear?(_), do: false
end
