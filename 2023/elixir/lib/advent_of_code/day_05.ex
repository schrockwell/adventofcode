defmodule AdventOfCode.Day05 do
  @behaviour AdventOfCode

  @dest_types ["soil", "fertilizer", "water", "light", "temperature", "humidity", "location"]

  # Part 1
  def run(_basename, 1, ["seeds: " <> seeds | maps]) do
    seeds = seeds |> String.split(" ") |> Enum.map(&String.to_integer/1)
    maps = parse_maps(maps)

    seeds
    |> Enum.map(fn seed ->
      Enum.reduce(@dest_types, seed, fn dest_type, seed ->
        find_next(maps, seed, dest_type)
      end)
    end)
    |> Enum.min()
  end

  # Part 2
  def run(_basename, 2, ["seeds: " <> seeds | maps]) do
    seed_ranges =
      seeds
      |> String.split(" ")
      |> Enum.map(&String.to_integer/1)
      |> Enum.chunk_every(2)
      |> Enum.map(fn [start, count] ->
        start..(start + count - 1)
      end)

    maps = parse_maps(maps)

    # Kick off recursion
    find_lowest_loc(0, maps, seed_ranges)
  end

  # Part 1 - Walk the transitions from seed to location
  defp find_next(maps, src_value, dest_type) do
    Enum.find(maps, fn
      %{to: ^dest_type, src_range: src_range} -> src_value in src_range
      _ -> false
    end)
    |> case do
      %{delta: delta} -> src_value + delta
      nil -> src_value
    end
  end

  # Part 2 - Walk the transitions BACKWARDS, from location to seed
  defp find_prev(maps, dest_value, dest_type) do
    Enum.find(maps, fn
      %{to: ^dest_type, dest_range: dest_range} -> dest_value in dest_range
      _ -> false
    end)
    |> case do
      %{delta: delta} -> dest_value - delta
      nil -> dest_value
    end
  end

  # Part 2
  defp find_lowest_loc(loc, maps, seed_ranges) do
    # Walk the transitions backwards, determining the starting seed from the final location
    seed =
      Enum.reverse(@dest_types)
      |> Enum.reduce(loc, fn dest_type, val ->
        find_prev(maps, val, dest_type)
      end)

    if Enum.any?(seed_ranges, fn range -> seed in range end) do
      # We're done!
      loc
    else
      # Display progress, for my own sanity
      if rem(loc, 100_000) == 0, do: IO.inspect(loc)

      # Keep going
      find_lowest_loc(loc + 1, maps, seed_ranges)
    end
  end

  # Parsing
  defp parse_maps(input) do
    chunks =
      Enum.chunk_by(input, fn line ->
        String.ends_with?(line, "map:")
      end)

    Enum.zip(Enum.take_every(chunks, 2), Enum.take_every(Enum.slice(chunks, 1..-1), 2))
    |> Enum.flat_map(fn {[desc], maps} ->
      [from, "to", to, "map:"] = String.split(desc, ~r/[- ]/)

      Enum.map(maps, fn map ->
        [dest_start, src_start, count] =
          map |> String.split(" ") |> Enum.map(&String.to_integer/1)

        %{
          from: from,
          to: to,
          src_range: src_start..(src_start + count - 1),
          dest_range: dest_start..(dest_start + count - 1),
          delta: dest_start - src_start
        }
      end)
    end)
  end
end
