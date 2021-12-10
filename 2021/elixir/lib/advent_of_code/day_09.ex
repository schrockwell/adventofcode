defmodule AdventOfCode.Day09 do
  @behaviour AdventOfCode

  def run(input) do
    input_rows = length(input)
    input_cols = String.length(hd(input))
    rows = input_rows + 2
    cols = input_cols + 2

    # Surround the input grid by 9's
    input =
      [String.duplicate("9", cols)] ++
        Enum.map(input, &"9#{&1}9") ++ [String.duplicate("9", cols)]

    heightmap = parse_heightmap(input)

    horizontal_minima =
      0..rows
      |> Enum.flat_map(fn y -> heightmap |> filter_heights(:y, y) |> find_local_minima() end)
      |> MapSet.new()

    vertical_minima =
      0..cols
      |> Enum.flat_map(fn x -> heightmap |> filter_heights(:x, x) |> find_local_minima() end)
      |> MapSet.new()

    all_minima = MapSet.intersection(horizontal_minima, vertical_minima)

    answer_a = risk_level(all_minima)

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

  defp parse_heightmap(input) do
    input
    |> Enum.with_index()
    |> Enum.flat_map(fn {row, y} ->
      row
      |> String.graphemes()
      |> Enum.map(&String.to_integer/1)
      |> Enum.with_index()
      |> Enum.map(fn {height, x} ->
        %{x: x, y: y, height: height}
      end)
    end)
  end

  defp filter_heights(heightmap, ord, index) do
    heightmap
    |> Enum.filter(fn point ->
      Map.fetch!(point, ord) == index
    end)
  end

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

  defp risk_level(points) do
    points |> Enum.map(&(&1.height + 1)) |> Enum.sum()
  end

  defp explore_basin(heightmap, point) do
    explore_basin(heightmap, point, MapSet.new())
  end

  defp explore_basin(heightmap, point, basin) do
    adjacent_points =
      Enum.filter(heightmap, fn p ->
        not MapSet.member?(basin, p) and
          p.height != 9 and
          ((p.x == point.x and p.y in [point.y - 1, point.y + 1]) or
             (p.y == point.y and p.x in [point.x - 1, point.x + 1]))
      end)

    basin = MapSet.union(basin, MapSet.new(adjacent_points ++ [point]))

    Enum.reduce(adjacent_points, basin, fn p, b ->
      explore_basin(heightmap, p, b)
    end)
  end
end
