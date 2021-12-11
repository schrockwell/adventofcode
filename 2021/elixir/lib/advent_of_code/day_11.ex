defmodule AdventOfCode.Day11 do
  @behaviour AdventOfCode

  @grid_size 10

  def run(input) do
    grid = parse_grid(input)

    answer_a = count_total_flashes(grid, 100)
    answer_b = find_first_synced_flash(grid)

    {answer_a, answer_b}
  end

  # Returns a map of %{{x, y} => %{energy: energy, flashed?: false}}
  defp parse_grid(input) do
    input
    |> Enum.with_index()
    |> Enum.flat_map(fn {line, y} ->
      line
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.map(fn {energy, x} ->
        {{x, y}, %{energy: String.to_integer(energy), flashed?: false}}
      end)
    end)
    |> Map.new()
  end

  # Returns a list of all valid adjacent coordinate tuples (including diagonals)
  defp adjacent_coords({x, y} = coord) do
    x_range = max(x - 1, 0)..min(x + 1, @grid_size - 1)
    y_range = max(y - 1, 0)..min(y + 1, @grid_size - 1)

    for new_x <- x_range, new_y <- y_range, {new_x, new_y} != coord do
      {new_x, new_y}
    end
  end

  # Don't flash an 🐙 that has already flashed
  defp charge(%{flashed?: true} = octopus) do
    {false, octopus}
  end

  # If it's at level 9, indicate the flash and reset back to 0
  defp charge(%{energy: 9} = octopus) do
    {true, %{octopus | energy: 0, flashed?: true}}
  end

  # Otherwise just increment energy
  defp charge(%{energy: energy} = octopus) do
    {false, %{octopus | energy: energy + 1}}
  end

  # Entry point for recursion
  defp step(grid) do
    step(grid, grid |> Map.keys() |> Enum.sort())
  end

  # Recursion is complete (no more coords to check out)
  defp step(grid, []) do
    flash_count = count_flashes(grid)
    grid = reset_flashes(grid)

    {grid, flash_count}
  end

  defp step(grid, [coord | next_coords]) do
    # Charge up this octopus
    {flashed?, octopus} = grid |> Map.fetch!(coord) |> charge()
    grid = Map.put(grid, coord, octopus)

    more_coords =
      if flashed? do
        # Find all adjacent non-flashed octopodes and add their coords to the
        # list of coords to examine for this step
        coord
        |> adjacent_coords()
        |> Enum.filter(fn c -> not grid[c].flashed? end)
      else
        # If we didn't flash, there are no extra coords to examine right now
        []
      end

    step(grid, more_coords ++ next_coords)
  end

  defp count_flashes(grid) do
    grid |> Map.values() |> Enum.count(& &1.flashed?)
  end

  defp reset_flashes(grid) do
    grid
    |> Enum.map(fn {c, o} -> {c, %{o | flashed?: false}} end)
    |> Map.new()
  end

  # Part 1 solution
  defp count_total_flashes(grid, steps_remaining, flash_count \\ 0)

  defp count_total_flashes(_grid, 0, flash_count), do: flash_count

  defp count_total_flashes(grid, steps_remaining, flash_count) do
    {grid, new_flash_count} = step(grid)
    count_total_flashes(grid, steps_remaining - 1, flash_count + new_flash_count)
  end

  # Part 2 solution
  defp find_first_synced_flash(grid, step \\ 1) do
    case step(grid) do
      {_grid, 100} -> step
      {next_grid, _} -> find_first_synced_flash(next_grid, step + 1)
    end
  end
end
