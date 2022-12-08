defmodule AdventOfCode.Day08 do
  @behaviour AdventOfCode

  def run(input) do
    # Parse the input into map of %{{x, y} => height}
    height_map =
      for {line, x} <- String.split(input, "\n") |> Enum.with_index(),
          {digit, y} <- String.graphemes(line) |> Enum.with_index(),
          into: %{} do
        {{x, y}, String.to_integer(digit)}
      end

    # Determine map bounds
    {max_x, max_y} = height_map |> Map.keys() |> Enum.max()

    ### Part A

    # Build a list of lists for each row (looking at heights from the left)
    rows =
      for row_x <- 0..max_x do
        Enum.filter(height_map, fn {{x, _}, _} -> x == row_x end) |> Enum.sort()
      end

    # Build a list of lists for each column (looking at heights from the top)
    cols =
      for col_y <- 0..max_y do
        Enum.filter(height_map, fn {{_, y}, _} -> y == col_y end) |> Enum.sort()
      end

    # Build a list of lists for each row (looking at the heights from the right)
    reversed_rows = Enum.map(rows, &Enum.reverse/1)

    # Build a list of lists for each column (looking at heights from the bottom)
    reversed_cols = Enum.map(cols, &Enum.reverse/1)

    # Accumulate unique coords that are visible looking from each direction
    answer_a =
      MapSet.new()
      |> find_all_visible_coords(rows)
      |> find_all_visible_coords(cols)
      |> find_all_visible_coords(reversed_rows)
      |> find_all_visible_coords(reversed_cols)
      |> MapSet.size()

    ### Part B

    # Brute-force the scenic score for each point and find the max
    answer_b =
      height_map
      |> all_scenic_scores(max_x, max_y)
      |> Map.values()
      |> Enum.max()

    {answer_a, answer_b}
  end

  ### Part A

  defp find_all_visible_coords(mapset, rows_or_cols) do
    Enum.reduce(rows_or_cols, mapset, fn heights, mapset_acc ->
      find_visible_coords(heights, mapset_acc)
    end)
  end

  defp find_visible_coords(heights, mapset) do
    {mapset, _max_height} =
      Enum.reduce(heights, {mapset, -1}, fn
        {coord, height}, {mapset_acc, max_height} when height > max_height ->
          {MapSet.put(mapset_acc, coord), height}

        _, acc ->
          acc
      end)

    mapset
  end

  ### Part B

  defp all_scenic_scores(height_map, max_x, max_y) do
    for {coord, _height} <- height_map, into: %{} do
      {coord, scenic_score(height_map, max_x, max_y, coord)}
    end
  end

  defp scenic_score(height_map, max_x, max_y, {x, y}) do
    height = Map.get(height_map, {x, y})

    coords_left = if x == 0, do: [], else: for(xi <- (x - 1)..0//-1, do: {xi, y})
    coords_right = if x == max_x, do: [], else: for(xi <- (x + 1)..max_x, do: {xi, y})
    coords_up = if y == 0, do: [], else: for(yi <- (y - 1)..0//-1, do: {x, yi})
    coords_down = if y == max_y, do: [], else: for(yi <- (y + 1)..max_y, do: {x, yi})

    view_distance(height_map, height, coords_left) *
      view_distance(height_map, height, coords_right) *
      view_distance(height_map, height, coords_up) *
      view_distance(height_map, height, coords_down)
  end

  defp view_distance(height_map, max_height, coords) do
    case Enum.find_index(coords, fn coord -> Map.get(height_map, coord) >= max_height end) do
      nil -> length(coords)
      index -> index + 1
    end
  end
end
