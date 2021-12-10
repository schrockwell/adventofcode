defmodule AdventOfCode.Day09 do
  @behaviour AdventOfCode

  def run(input) do
    input_rows = length(input)
    input_cols = String.length(hd(input))
    rows = input_rows + 2
    cols = input_cols + 2

    # Surround the input grid by 9's so that we have a border that is guaranteed not to be a minimum
    input =
      [String.duplicate("9", cols)] ++
        Enum.map(input, &"9#{&1}9") ++ [String.duplicate("9", cols)]

    heightmap = parse_heightmap(input)

    ##### PART 1 #####

    # Find the minimum points in every row
    horizontal_minima =
      0..rows
      |> Enum.flat_map(fn y -> heightmap |> filter_heights(:y, y) |> find_local_minima() end)
      |> MapSet.new()

    # Find the minimum points in every column
    vertical_minima =
      0..cols
      |> Enum.flat_map(fn x -> heightmap |> filter_heights(:x, x) |> find_local_minima() end)
      |> MapSet.new()

    # The intersection of the horizontal and vertical minima will give us all points which are the minima on FOUR sides
    all_minima = MapSet.intersection(horizontal_minima, vertical_minima)
    answer_a = risk_level(all_minima)

    ##### PART 2 #####

    # For part 2, we want the product of the size of the top 3 largest basins, which we can determine by using the
    # minima as starting points for each basin
    answer_b =
      Enum.map(all_minima, fn point ->
        explore_basin(heightmap, point)
      end)
      |> Enum.map(&MapSet.size/1)
      |> Enum.sort(:desc)
      |> Enum.take(3)
      |> Enum.product()

    {answer_a, answer_b}
  end

  # Returns a map of %{{x, y} => %{x: x, y: y, height: height}}
  defp parse_heightmap(input) do
    input
    |> Enum.with_index()
    |> Enum.flat_map(fn {row, y} ->
      row
      |> String.graphemes()
      |> Enum.map(&String.to_integer/1)
      |> Enum.with_index()
      |> Enum.map(fn {height, x} ->
        {{x, y}, %{x: x, y: y, height: height}}
      end)
    end)
    |> Map.new()
  end

  # Dumb linear filtering for part 1
  defp filter_heights(heightmap, ord, index) do
    heightmap
    |> Map.values()
    |> Enum.filter(fn point ->
      Map.fetch!(point, ord) == index
    end)
    |> Enum.sort_by(&{&1.x, &1.y})
  end

  # Returns the min points when filtered by the above function
  defp find_local_minima(row_or_col) do
    left = Enum.slice(row_or_col, 0..-3)
    mid = Enum.slice(row_or_col, 1..-2)
    right = Enum.slice(row_or_col, 2..-1)

    left
    |> Enum.zip(mid)
    |> Enum.zip(right)
    |> Enum.filter(fn {{l, m}, r} -> m < l and m < r end)
    |> Enum.map(fn {{_, p}, _} -> p end)
  end

  # Calculate the score for part 1
  defp risk_level(points) do
    points |> Enum.map(&(&1.height + 1)) |> Enum.sum()
  end

  # Recursive search for part 2
  defp explore_basin(heightmap, point, basin \\ MapSet.new()) do
    # Figure out the top/down/left/right coords
    adjacent_coords = [
      {point.x - 1, point.y},
      {point.x + 1, point.y},
      {point.x, point.y - 1},
      {point.x, point.y + 1}
    ]

    # Find all adjacent points which are not 9 and are not already explored
    next_points =
      adjacent_coords
      |> Enum.map(fn coord -> Map.fetch!(heightmap, coord) end)
      |> Enum.filter(fn p ->
        p.height != 9 and not MapSet.member?(basin, p)
      end)

    # Tack those onto the basin (plus this point, too)
    basin = MapSet.union(basin, MapSet.new(next_points ++ [point]))

    # And I bump again, and I bump again
    Enum.reduce(next_points, basin, fn p, b ->
      explore_basin(heightmap, p, b)
    end)
  end
end
