defmodule AdventOfCode.Day05 do
  @behaviour AdventOfCode

  @dest_types ["soil", "fertilizer", "water", "light", "temperature", "humidity", "location"]

  # Part 1
  def run(_basename, 1, [
        "seeds: " <> seeds
        | maps
      ]) do
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
  def run(_basename, 2, [
        "seeds: " <> seeds
        | maps
      ]) do
    _seed_ranges =
      seeds
      |> String.split(" ")
      |> Enum.map(&String.to_integer/1)
      |> Enum.chunk_every(2)
      |> Enum.map(fn [first, last] -> first..(first + last - 1) end)

    # idk
    0
  end

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
          delta: dest_start - src_start
        }
      end)
    end)
  end

  defp find_next(maps, src_value, dest_type) do
    Enum.find(maps, fn
      %{to: ^dest_type, src_range: src_range} ->
        src_value in src_range

      _ ->
        false
    end)
    |> case do
      %{delta: delta} -> src_value + delta
      nil -> src_value
    end
  end
end
