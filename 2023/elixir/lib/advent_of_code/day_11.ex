defmodule AdventOfCode.Day11 do
  @behaviour AdventOfCode

  # Parts 1 and 2
  def run(_basename, part, input) do
    image = %{
      width: input |> hd() |> String.length(),
      height: input |> length(),
      galaxies: find_galaxies(input)
    }

    # The only change for part 2
    expansion = if part == 1, do: 1, else: 999_999

    image = expand_universe(image, expansion)
    pairs = unique_pairs(image.galaxies)

    distances = Enum.map(pairs, fn {gal1, gal2} -> distance(gal1, gal2) end)
    Enum.sum(distances)
  end

  # Returns a MapSet of all galaxy coordinates
  defp find_galaxies(input) do
    for {line, y} <- Enum.with_index(input),
        {char, x} <- line |> String.codepoints() |> Enum.with_index(),
        reduce: MapSet.new() do
      acc ->
        case char do
          "#" -> MapSet.put(acc, {x, y})
          _ -> acc
        end
    end
  end

  # Adds empty rows and columns
  defp expand_universe(image, expansion) do
    # NOTE! Loop from HIGH to LOW since we are shifting down and right
    new_image1 =
      Enum.reduce((image.width - 1)..0, image, fn x, acc ->
        if empty_col?(acc.galaxies, x) do
          %{acc | galaxies: shift_right(acc.galaxies, x, expansion), width: acc.width + expansion}
        else
          acc
        end
      end)

    new_image2 =
      Enum.reduce((image.height - 1)..0, new_image1, fn y, acc ->
        if empty_row?(acc.galaxies, y) do
          %{
            acc
            | galaxies: shift_down(acc.galaxies, y, expansion),
              height: acc.height + expansion
          }
        else
          acc
        end
      end)

    %{new_image2 | galaxies: MapSet.new(new_image2.galaxies)}
  end

  defp empty_row?(galaxies, y) do
    Enum.all?(galaxies, fn {_, gal_y} -> gal_y != y end)
  end

  defp empty_col?(galaxies, x) do
    Enum.all?(galaxies, fn {gal_x, _} -> gal_x != x end)
  end

  defp shift_right(galaxies, x, expansion) do
    Enum.map(galaxies, fn {gal_x, gal_y} ->
      if gal_x > x do
        {gal_x + expansion, gal_y}
      else
        {gal_x, gal_y}
      end
    end)
  end

  defp shift_down(galaxies, y, expansion) do
    Enum.map(galaxies, fn {gal_x, gal_y} ->
      if gal_y > y do
        {gal_x, gal_y + expansion}
      else
        {gal_x, gal_y}
      end
    end)
  end

  defp distance({x1, y1}, {x2, y2}) do
    abs(x1 - x2) + abs(y1 - y2)
  end

  # Returns a MapSet of all unique pairs of galaxies
  defp unique_pairs(galaxies) do
    for gal1 <- galaxies,
        gal2 <- galaxies,
        gal1 != gal2,
        reduce: MapSet.new() do
      acc ->
        if Enum.member?(acc, {gal1, gal2}) or Enum.member?(acc, {gal2, gal1}) do
          acc
        else
          MapSet.put(acc, {gal1, gal2})
        end
    end
  end

  def __draw_image__(image) do
    for y <- 0..(image.height - 1) do
      for x <- 0..(image.width - 1) do
        if MapSet.member?(image.galaxies, {x, y}) do
          "#"
        else
          "."
        end
      end
      |> Enum.join()
    end
    |> Enum.join("\n")
    |> IO.puts()
  end
end
