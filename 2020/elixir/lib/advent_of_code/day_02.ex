defmodule AdventOfCode.Day02 do
  @behaviour AdventOfCode

  @regex ~r/^(\d+)-(\d+) (.): (.+)$/

  def run(input) do
    answer_a =
      input
      |> Enum.map(&Regex.run(@regex, &1))
      |> Enum.map(fn [_, min, max, char, password] ->
        {String.to_integer(min)..String.to_integer(max), char, password}
      end)
      |> Enum.count(fn {range, char, password} ->
        char_count = password |> String.codepoints() |> Enum.count(&(&1 == char))
        char_count in range
      end)

    answer_b =
      input
      |> Enum.map(&Regex.run(@regex, &1))
      |> Enum.map(fn [_, pos1, pos2, char, password] ->
        pos1 = String.to_integer(pos1) - 1
        pos2 = String.to_integer(pos2) - 1

        {String.at(password, pos1), String.at(password, pos2), char}
      end)
      |> Enum.count(fn
        {char, char, char} -> false
        {char, _, char} -> true
        {_, char, char} -> true
        _ -> false
      end)

    IO.puts("Answer A: #{answer_a}")
    IO.puts("Answer B: #{answer_b}")

    {to_string(answer_a), to_string(answer_b)}
  end
end
