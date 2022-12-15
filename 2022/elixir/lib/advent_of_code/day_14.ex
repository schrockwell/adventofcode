defmodule AdventOfCode.Day14 do
  @behaviour AdventOfCode

  @initial_grain {500, 0}

  def run(input) do
    map = parse_input(input)

    answer_a = map |> drop_all_grains() |> count_sand()
    answer_b = map |> drop_all_grains(floor?: true) |> count_sand()

    {answer_a, answer_b}
  end

  defp count_sand(map) do
    map
    |> Map.values()
    |> Enum.count(fn x -> x == :sand end)
  end

  ### Parsing

  # Return a flat list of rock coords in the entire input
  defp parse_input(input) do
    input
    |> String.split("\n")
    |> Enum.flat_map(&parse_input_line/1)
    |> Map.new(fn coord -> {coord, :rock} end)
  end

  # Return a flat list of coords on this line
  defp parse_input_line(line) do
    line
    |> String.split(" -> ")
    |> Enum.map(fn ords -> ords |> String.split(",") |> Enum.map(&String.to_integer/1) end)
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.flat_map(&parse_input_coords/1)
  end

  # Return a flat list of coords between two points
  defp parse_input_coords([[x, y1], [x, y2]]) do
    for y <- y1..y2, do: {x, y}
  end

  defp parse_input_coords([[x1, y], [x2, y]]) do
    for x <- x1..x2, do: {x, y}
  end

  ### Sand movement

  # Drop every sand grain possible
  defp drop_all_grains(map, opts \\ []) do
    abyss_y = map |> Map.keys() |> Enum.map(fn {_x, y} -> y end) |> Enum.max()
    opts = Map.new(opts)
    drop_grains(map, abyss_y, opts)
  end

  # Recursively drop sand fron the initial coord
  defp drop_grains(map, abyss_y, opts) do
    case next_destination(map, @initial_grain, abyss_y, opts) do
      # Part B end-state
      {:ok, @initial_grain} ->
        Map.put(map, @initial_grain, :sand)

      # Parts A and B iteration
      {:ok, coord} ->
        map
        |> Map.put(coord, :sand)
        |> drop_grains(abyss_y, opts)

      # Part A end-state
      :error ->
        map
    end
  end

  # Part B: If the floor is enabled, stop moving 1 level below the lowest rock
  defp next_destination(_map, {_x, grain_y} = coord, abyss_y, %{floor?: true})
       when grain_y == abyss_y + 1,
       do: {:ok, coord}

  # Part A: We've passed the lowest rock, so we must be in the abyss
  defp next_destination(_map, {_x, grain_y}, abyss_y, _opts) when grain_y > abyss_y,
    do: :error

  # General case
  defp next_destination(map, {x, y} = grain, abyss_y, opts) do
    # Try to move down, then down-left, then down-right
    with :error <- try_move(map, {x, y + 1}),
         :error <- try_move(map, {x - 1, y + 1}),
         :error <- try_move(map, {x + 1, y + 1}) do
      # If all moves fail, the grain is at rest
      {:ok, grain}
    else
      # If one of the moves succeeds, iterate
      {:ok, next_coord} -> next_destination(map, next_coord, abyss_y, opts)
    end
  end

  defp try_move(map, next_coord) do
    if Map.has_key?(map, next_coord) do
      :error
    else
      {:ok, next_coord}
    end
  end
end
