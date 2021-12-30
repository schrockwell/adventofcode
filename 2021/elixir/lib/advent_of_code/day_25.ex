defmodule AdventOfCode.Day25 do
  @behaviour AdventOfCode

  defmodule Seafloor do
    defstruct [:width, :height, :down, :right]
  end

  def run(input) do
    map = parse_map(input)

    answer_a = advance_map(map)

    {answer_a, "todo"}
  end

  defp parse_map(input) do
    herds =
      input
      |> Enum.with_index()
      |> Enum.flat_map(fn {line, y} ->
        line
        |> String.graphemes()
        |> Enum.with_index()
        |> Enum.flat_map(fn
          {"v", x} -> [down: {x, y}]
          {">", x} -> [right: {x, y}]
          _ -> []
        end)
      end)

    width = input |> hd() |> String.length()
    height = length(input)

    down_herd = herds |> Keyword.get_values(:down) |> MapSet.new()
    right_herd = herds |> Keyword.get_values(:right) |> MapSet.new()

    %Seafloor{width: width, height: height, down: down_herd, right: right_herd}
  end

  defp next_position(map, :right, {x, y} = coord) do
    next_coord = {rem(x + 1, map.width), y}
    if occupied?(map, next_coord), do: coord, else: next_coord
  end

  defp next_position(map, :down, {x, y} = coord) do
    next_coord = {x, rem(y + 1, map.height)}
    if occupied?(map, next_coord), do: coord, else: next_coord
  end

  defp occupied?(map, coord) do
    MapSet.member?(map.right, coord) or MapSet.member?(map.down, coord)
  end

  defp advance_herd(map, herd) do
    next_herd =
      map
      |> Map.fetch!(herd)
      |> Enum.map(fn coord ->
        next_position(map, herd, coord)
      end)
      |> MapSet.new()

    %{map | herd => next_herd}
  end

  defp advance_map(map, counter \\ 1) do
    next_map =
      map
      |> advance_herd(:right)
      |> advance_herd(:down)

    if map == next_map do
      counter
    else
      advance_map(next_map, counter + 1)
    end
  end
end
