defmodule AdventOfCode.Day15 do
  @behaviour AdventOfCode

  def run(input) do
    readings = parse_readings(input)

    # At y=2000000, count all the free spaces for all known readings, and then substract all known beacons
    answer_a =
      readings
      |> Enum.map(&free_range(&1, :y, 2_000_000))
      |> Enum.reject(&is_nil/1)
      |> combine_ranges()
      |> count_ranges(readings, :y, 2_000_000)

    # For y=0..4000000, look for a gap of 1 along the x axis
    answer_b =
      Enum.reduce_while(0..4_000_000, nil, fn y, _ ->
        readings
        |> Enum.map(&free_range(&1, :y, y))
        |> Enum.reject(&is_nil/1)
        |> combine_ranges()
        |> sort_ranges()
        |> find_gap()
        |> case do
          nil -> {:cont, nil}
          gap_x -> {:halt, {gap_x, y}}
        end
      end)
      |> to_tuning_frequency()

    {answer_a, answer_b}
  end

  defp parse_readings(input) do
    input
    |> String.split("\n")
    |> Enum.map(&prase_reading/1)
  end

  defp prase_reading(line) do
    # "Sensor at x=3523437, y=2746095: closest beacon is at x=3546605, y=2721324"
    [[_, sx], [_, sy], [_, bx], [_, by]] = Regex.scan(~r/[xy]=(-?\d+)/, line)

    sx = String.to_integer(sx)
    sy = String.to_integer(sy)
    bx = String.to_integer(bx)
    by = String.to_integer(by)

    # Manhattan distance - https://en.wikipedia.org/wiki/Taxicab_geometry
    distance = abs(bx - sx) + abs(by - sy)

    %{
      sensor: {sx, sy},
      beacon: {bx, by},
      distance: distance
    }
  end

  ### Range manipulation

  defp combine_ranges(ranges, acc \\ [])
  defp combine_ranges([], acc), do: acc

  defp combine_ranges([range | rest], acc) do
    case Enum.find(rest, fn r -> not Range.disjoint?(range, r) end) do
      nil ->
        # No overlapping ranges at all, so cannot combine any more
        combine_ranges(rest, [range | acc])

      other ->
        # Build a new range that combines the two
        new_range = min(range.first, other.first)..max(range.last, other.last)

        # Drop the overlapping range from the list
        new_rest = rest -- [other]

        # Recurse with the new mega-range in the list (don't accumulate it yet!)
        combine_ranges([new_range | new_rest], acc)
    end
  end

  defp sort_ranges(ranges) do
    Enum.sort_by(ranges, & &1.first)
  end

  defp count_ranges(ranges, readings, axis, axis_at) do
    beacons = readings |> Enum.map(& &1.beacon) |> Enum.uniq()

    ranges
    |> Enum.flat_map(fn range ->
      beacon_count =
        Enum.count(beacons, fn beacon ->
          axis_value(beacon, axis) == axis_at and Enum.member?(range, axis_value(beacon, axis))
        end)

      [Range.size(range), -beacon_count]
    end)
    |> Enum.sum()
  end

  # Part B: Returns a gap of exactly 1 between a list of ranges, or nil if not found
  defp find_gap(ranges) do
    ranges
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.find(fn [r1, r2] ->
      r1.last + 2 == r2.first
    end)
    |> case do
      nil -> nil
      [range, _] -> range.last + 1
    end
  end

  # Part B: Converts a coord to the answer
  defp to_tuning_frequency({x, y}), do: x * 4_000_000 + y

  # Returns a list of coords along a given axis at a particular value that are NOT beacons
  defp free_range(reading, axis, axis_at) do
    this_value = axis_value(reading.sensor, axis)
    that_value = axis_value(reading.sensor, other_axis(axis))

    radius = reading.distance - abs(axis_at - this_value)

    min = that_value - radius
    max = that_value + radius

    if min <= max do
      min..max
    end
  end

  defp axis_value({x, _y}, :x), do: x
  defp axis_value({_x, y}, :y), do: y

  defp other_axis(:x), do: :y
  defp other_axis(:y), do: :x
end
