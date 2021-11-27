defmodule AdventOfCode.Day07 do
  @behaviour AdventOfCode

  def run(input) do
    lut = parse_bags(input)

    answer_a =
      lut
      |> Map.values()
      |> Enum.count(fn subbags ->
        contains_color?(lut, "shiny gold", subbags)
      end)

    answer_b = count_subbags(lut, "shiny gold")

    {answer_a, answer_b}
  end

  defp parse_bags(lines) do
    for line <- lines, into: %{} do
      [src, dest] = String.split(line, " bags contain ")

      dests =
        dest
        |> String.split(" ")
        |> Enum.chunk_every(4)
        |> Enum.flat_map(fn
          ["no", "other", "bags."] ->
            []

          [num, color1, color2, _] ->
            [{String.to_integer(num), color1 <> " " <> color2}]
        end)

      {src, dests}
    end
  end

  defp contains_color?(_lut, _target_color, []), do: false

  defp contains_color?(lut, target_color, subbags) do
    subcolors = for {_num, color} <- subbags, do: color

    if target_color in subcolors do
      true
    else
      Enum.find(subcolors, false, fn color ->
        next_subbags = lut[color]
        contains_color?(lut, target_color, next_subbags)
      end)
    end
  end

  defp count_subbags(lut, target_color) do
    recurse_subbags(lut, lut[target_color])
  end

  defp recurse_subbags(_lut, []), do: 0

  defp recurse_subbags(lut, subbags) do
    subbags
    |> Enum.map(fn {num, color} ->
      num * (1 + count_subbags(lut, color))
    end)
    |> Enum.sum()
  end
end
